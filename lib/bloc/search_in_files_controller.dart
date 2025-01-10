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
  search,
  replace
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
  SearchInFilesAction action = SearchInFilesAction.search;
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
/// The controller performing the search in files operation.
///
class SearchInFilesController {
  final Logger logger = createLogger("SearchInFilesController");
  final StreamController<List<SearchInFilesMatch>> _resultController = BehaviorSubject();
  Stream<List<SearchInFilesMatch>> get results => _resultController.stream;
  final ValueNotifier<bool> _running = ValueNotifier(false);

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
    var found = <SearchInFilesMatch>[];
    _resultController.add(found);
    final dir = Directory(options.directory);
    if (!dir.existsSync()) {
      logger.w("Directory ${options.directory} does not exist");
      return;
    }
    Pattern? searchPattern = options.search.isEmpty ? null :
        (options.options.regex ? RegExp(options.search, caseSensitive: !options.options.ignoreCase) : options.search);
    unawaited(_traverseDirectories(dir, options.fileNamePatterns, options, (file, option) async {
      unawaited(file.readAsLines().then(((lines) {
        int lineNumber = 0;
        var singleMatched = false;
        for (final line in lines) {
          if (searchPattern == null) {
            found.add(SearchInFilesMatch(fileName: file.absolute.path, lineNumber: lineNumber, column: 0, matchLength: line.length, matchedLine: line));
            break;
          } else {
            for (final m in searchPattern.allMatches(line)) {
              found.add(SearchInFilesMatch(fileName: file.absolute.path, lineNumber: lineNumber, column: m.start, matchLength: m.end-m.start, matchedLine: line));
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
      _resultController.add(found);
    }));
  }

}
