//
// search_in_files_controller.dart
//
// PKS-EDIT - Flutter
//
// Last modified: 2025
// Author: Tom Krauß
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:glob/glob.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:pks_edit_flutter/bloc/file_io.dart';
import 'package:pks_edit_flutter/bloc/match_location_parser.dart';
import 'package:pks_edit_flutter/bloc/match_result_list.dart';
import 'package:pks_edit_flutter/config/pks_ini.dart';
import 'package:pks_edit_flutter/config/pks_sys.dart';
import 'package:pks_edit_flutter/util/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sprintf/sprintf.dart';

///
/// The action to perform.
///
enum SearchInFilesAction { openFile, replaceInFiles }

///
/// Parameterizes the search(and replace) in files operation
///
class SearchAndReplaceInFilesOptions {
  String directory = File(".").absolute.path;
  String fileNamePattern = "*.txt";
  String search = "";
  String replace = "";
  SearchAndReplaceOptions options = SearchAndReplaceOptions();
  Glob get fileNamePatterns {
    var matchString = fileNamePattern;
    if (matchString.indexOf(RegExp("[,;|]")) > 0) {
      matchString = matchString.replaceAll(";", ",").replaceAll("|", ",");
      if (matchString[0] != '{') {
        matchString = "{$matchString}";
      }
    }
    return Glob(matchString.isEmpty ? "*" : matchString);
  }
}

// TODO(alphacentauri4711): need an efficient way to exclude hidden directories like ".git" to speed up.
class DirectoryWalker {
  final Directory root;
  final String prunedDirectories;
  int directoryCount = 0;
  int processing = 0;

  DirectoryWalker(this.root, {required this.prunedDirectories});

  StreamController<FileSystemEntity> _controller = BehaviorSubject();

  bool _findFolderMatches(String match, String folderName) {
    var ml = match.length;
    var fl = folderName.length;
    if (ml == 0) {
      return false;
    }
    for (int j = 0, m = 0;; j++, m++) {
      if (j >= fl ||
          m >= ml ||
          match[m] == '*' ||
          match[m] == ';' ||
          match[m] == ':') {
          return true;
      }
      if (match[m] != folderName[j]) {
        while (m < ml && match[m] != ';' && match[m] != ':') {
          m++;
        }
        if (m >= ml) {
          return false;
        }
        j = -1;
      }
    }
  }

  Future<void> _walk(Directory directory, bool isRoot) async {
    processing++;
    directory.list().listen((file) {
      _controller.add(file);
      if (file is Directory) {
        var base = basename(file.path);
        if (!_findFolderMatches(prunedDirectories, base)) {
          _walk(file, false);
        }
      }
    }, onDone: () {
      processing--;
      if (processing <= 0) {
        _controller.close();
      }
    });
  }

  Stream<FileSystemEntity> walk() {
    _controller = BehaviorSubject();
    processing = 0;
    _walk(root, true);
    return _controller.stream;
  }
}

///
/// The controller performing the search in files operation.
///
class SearchInFilesController {
  final Logger logger = createLogger("SearchInFilesController");
  final ValueNotifier<bool> _running = ValueNotifier(false);
  final ValueNotifier<String> progressInfo = ValueNotifier("");
  final MatchResultList _results = MatchResultList.current;
  bool _initialized = false;
  StreamSubscription<FileSystemEntity>? _directoryWalk;

  SearchInFilesController._();

  ///
  /// The search in files controller is accessed as a singleton.
  ///
  static final SearchInFilesController instance = SearchInFilesController._();

  ValueNotifier<bool> get running => _running;

  void _updateProgressInfo(Stopwatch clock, int nDirectoriesProcessed) {
    if (clock.elapsedMilliseconds > 250) {
      clock.reset();
      progressInfo.value = sprintf("%d matches, %d directories processed",
          [_results.length, nDirectoriesProcessed]);
    }
  }

  Stream<FileSystemEntity> createFileListFromResults() {
    final files =
        _results.resultList.map((r) => r.fileName).toSet().map(File.new);
    return Stream.fromIterable(files);
  }

  Future<void> _traverseDirectories(
      {required Stream<FileSystemEntity> walker,
      required String inputDescription,
      required Glob pattern,
      required SearchAndReplaceInFilesOptions options,
      required Future<void> Function(
              File file, SearchAndReplaceInFilesOptions options)
          foundMatch}) async {
    int nDir = 0;
    var clock = Stopwatch();
    clock.start();
    _directoryWalk = walker.listen((f) {
      if (!running.value) {
        return;
      }
      if (f is File) {
        String baseName = basename(f.path);
        if (pattern.matches(baseName)) {
          foundMatch(f, options);
          _updateProgressInfo(clock, nDir);
        }
      } else {
        _updateProgressInfo(clock, nDir);
        nDir++;
      }
    }, onDone: () {
      progressInfo.value = "";
      _running.value = false;
      saveSearchResults(options);
      _directoryWalk = null;
    }, onError: (Object? e, s) {
      logger.w("Error when listing files in directory $inputDescription: $e");
    });
  }

  void abortSearch() {
    if (running.value) {
      _directoryWalk?.cancel();
      _directoryWalk = null;
      running.value = false;
    }
  }

  Future<File> get _grepFile async {
    var p = await PksConfiguration.singleton.pksEditTempPath;
    return File(join(p, PksConfiguration.searchResultsFilename));
  }

  ///
  /// Save the search results.
  ///
  Future<void> saveSearchResults(SearchAndReplaceInFilesOptions options) async {
    var f = await _grepFile;
    f.createSync();
    logger.i("Saving search results in file ${f.path}");
    var title = _results.title;
    if (title.value.trim().isNotEmpty) {
      f.writeAsStringSync(title.value);
    }
    for (final r in await _results.results.first) {
      f.writeAsStringSync("${r.printMatch()}\n", mode: FileMode.append);
    }
  }

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    var f = await _grepFile;
    if (!f.existsSync()) {
      return;
    }
    logger.i("Restoring search results from file ${f.path}");
    var parser = searchInFilesResultParser;
    bool titleFound = false;
    var matches = <MatchedFileLocation>[];
    for (final s in f.readAsLinesSync()) {
      var match = parser.parse(s);
      if (match != null) {
        matches.add(match);
      } else if (!titleFound && s.isNotEmpty) {
        _results.title.value = s;
        titleFound = true;
      }
    }
    _results.addAll(matches);
  }

  Future<void> run(SearchAndReplaceInFilesOptions options,
      PksIniConfiguration configuration) async {
    if (_running.value) {
      return;
    }
    _running.value = true;
    final dir = Directory(options.directory);
    if (!dir.existsSync()) {
      logger.w("Directory ${options.directory} does not exist");
      return;
    }
    final walker = options.options.searchInSearchResults
        ? createFileListFromResults()
        : DirectoryWalker(dir,
                prunedDirectories: options.options.ignoreBinaryFiles
                    ? configuration.configuration.prunedSearchDirectories
                    : "")
            .walk();
    final inputDescription =
        options.options.searchInSearchResults ? 'File List' : dir.path;
    if (!options.options.appendToSearchList) {
      _results.reset();
    }
    _results.title.value = sprintf(
        "Matches of '%s' in '%s'\n", [options.search, options.directory]);
    var fileHelper = const FileIO();
    Pattern? searchPattern = options.search.isEmpty
        ? null
        : (options.options.regex
            ? RegExp(options.search, caseSensitive: !options.options.ignoreCase)
            : options.search);
    unawaited(_traverseDirectories(
        walker: walker,
        inputDescription: inputDescription,
        pattern: options.fileNamePatterns,
        options: options,
        foundMatch: (file, option) async {
          var encoding = await fileHelper.detectEncoding(file);
          unawaited(
              file.readAsLines(encoding: encoding.encoding).then(((lines) {
            int lineNumber = 0;
            var singleMatched = false;
            for (final line in lines) {
              if (searchPattern == null) {
                _results.add(MatchedFileLocation(
                    fileName: file.absolute.path,
                    lineNumber: lineNumber,
                    column: 0,
                    matchLength: line.length,
                    matchedLine: line));
                break;
              } else {
                for (final m in searchPattern.allMatches(line)) {
                  _results.add(MatchedFileLocation(
                      fileName: file.absolute.path,
                      lineNumber: lineNumber,
                      column: m.start,
                      matchLength: m.end - m.start,
                      matchedLine: line));
                  if (option.options.singleMatchInFile) {
                    singleMatched = true;
                    break;
                  }
                }
              }
              if (singleMatched) {
                break;
              }
              lineNumber++;
            }
          })).onError((ex, stack) {
            logger.e("Cannot search in file $file. Exception: $ex",
                stackTrace: stack);
          }));
        }));
  }
}
