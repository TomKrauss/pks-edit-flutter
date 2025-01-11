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
import 'package:pks_edit_flutter/config/pks_sys.dart';
import 'package:pks_edit_flutter/util/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sprintf/sprintf.dart';

///
/// Captures the result of a match of a find operation.
///
class SearchInFilesMatch {
  static const String _grepFileFormat = '"%s", line %d: %s';

  final String fileName;
  /// 0 based line number, where the match was found
  final int lineNumber;
  /// Column where the match was found
  final int column;
  /// The length of the match
  final int matchLength;
  /// The text of the matched line
  final String? matchedLine;

  SearchInFilesMatch({required this.fileName, required this.lineNumber, required this.column, required this.matchLength, this.matchedLine});

  String get shortenedFileName {
    var n = fileName;
    var l = n.length;
    if (l > 30) {
      return "...${n.substring(l-30)}";
    }
    return n;
  }

  List<String> get matchedSegments {
    var line = matchedLine;
    if (line == null) {
      return [""];
    }
    return [line.substring(0,column), line.substring(column, column+matchLength), line.substring(column+matchLength)];
  }

  String printMatch() {
    String matchComment = "";
    var segments = matchedSegments;
    if (segments.isNotEmpty) {
      matchComment = " - ${segments[0]}~${segments[1]}~${segments[2]}";
    }
    return sprintf(_grepFileFormat, [fileName, lineNumber+1, "$column/$matchLength$matchComment"]);
  }
}

///
/// The action to perform.
///
enum SearchInFilesAction {
  openFile,
  replaceInFiles
}

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
    return Glob(matchString);
  }
}

///
/// Maintains a list of "matches" - i.e. file locations, which might be navigated or jumped to.
/// A match result list may be created as part of a search in files operation of by parsing the
/// output of a build tool.
///
class MatchResultList {
  final StreamController<List<SearchInFilesMatch>> _resultController = BehaviorSubject();
  final List<SearchInFilesMatch> _matches = [];
  Stream<List<SearchInFilesMatch>> get results => _resultController.stream;
  ///
  /// The match currently selected. Can be used for next-match and previous-match operations for instance.
  ///
  final ValueNotifier<SearchInFilesMatch?> selectedMatch = ValueNotifier(null);

  ///
  /// The index of the currently selected element or -1 if non was selected.
  int get selectedIndex {
    var v = selectedMatch.value;
    return v == null ? -1 : _matches.indexOf(v);
  }

  ///
  /// Reset this match result list.
  ///
  void reset() {
    _matches.clear();
    _resultController.add(_matches);
    selectedMatch.value = null;
  }

  void add(SearchInFilesMatch match) {
    _matches.add(match);
    _resultController.add(_matches);
  }

  ///
  /// Move the current selection in the match result list one item down. Return [true] if this was successful.
  ///
  bool moveSelectionNext() {
    var idx = selectedIndex;
    if (idx+1 < _matches.length) {
      selectedMatch.value = _matches[idx+1];
      return true;
    }
    return false;
  }

  ///
  /// Move the current selection in the match result list one item up. Return [true] if this was successful.
  ///
  bool moveSelectionPrevious() {
    var idx = selectedIndex;
    if (idx-1 >= 0) {
      selectedMatch.value = _matches[idx-1];
      return true;
    }
    return false;
  }
}

///
/// The controller performing the search in files operation.
///
class SearchInFilesController {
  final Logger logger = createLogger("SearchInFilesController");
  final ValueNotifier<bool> _running = ValueNotifier(false);
  final MatchResultList results = MatchResultList();

  SearchInFilesController._();

  ///
  /// The search in files controller is accessed as a singleton.
  ///
  static final SearchInFilesController instance = SearchInFilesController._();

  ValueNotifier<bool> get running => _running;

  Future<void> _traverseDirectories(Directory baseDirectory, Glob pattern, SearchAndReplaceInFilesOptions options,
      Future<void> Function(File file, SearchAndReplaceInFilesOptions options) foundMatch) async {
    baseDirectory.list(recursive: true).listen((f) {
      if (f is File) {
        String baseName = basename(f.path);
        if (pattern.matches(baseName)) {
          foundMatch(f, options);
        }
      }
    }, onDone: () {
      _running.value = false;
    });
  }

  Future<void> run(SearchAndReplaceInFilesOptions options) async {
    if (_running.value) {
      return;
    }
    _running.value = true;
    final dir = Directory(options.directory);
    if (!dir.existsSync()) {
      logger.w("Directory ${options.directory} does not exist");
      return;
    }
    results.reset();
    Pattern? searchPattern = options.search.isEmpty ? null :
        (options.options.regex ? RegExp(options.search, caseSensitive: !options.options.ignoreCase) : options.search);
    unawaited(_traverseDirectories(dir, options.fileNamePatterns, options, (file, option) async {
      unawaited(file.readAsLines().then(((lines) {
        int lineNumber = 0;
        var singleMatched = false;
        for (final line in lines) {
          if (searchPattern == null) {
            results.add(SearchInFilesMatch(fileName: file.absolute.path, lineNumber: lineNumber, column: 0, matchLength: line.length, matchedLine: line));
            break;
          } else {
            for (final m in searchPattern.allMatches(line)) {
              results.add(SearchInFilesMatch(fileName: file.absolute.path, lineNumber: lineNumber, column: m.start, matchLength: m.end-m.start, matchedLine: line));
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
      })));
    }));
  }

}
