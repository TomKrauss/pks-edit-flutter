//
// match_result_list.dart
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

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sprintf/sprintf.dart';

///
/// Captures the result of a match of a find operation.
///
class MatchedFileLocation {
  static const String _grepFileFormat = '"%s", line %d: %s';

  final String fileName;
  /// 0 based line number, where the match was found
  final int lineNumber;
  /// Column where the match was found
  final int? column;
  /// The length of the match
  final int? matchLength;
  /// The text of the matched line
  final String? matchedLine;
  /// If the matched file location was created from a compiler output, this is the error message.
  final String? comment;

  MatchedFileLocation({required this.fileName, required this.lineNumber, required this.column, required this.matchLength, this.matchedLine, this.comment});

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
    var col = column;
    var length = matchLength;
    if (line == null || col == null || length == null) {
      return [""];
    }
    var maxLength = line.length;
    if (col > maxLength) {
      col = maxLength;
      length = 0;
    } else if (col+length > maxLength) {
      length = maxLength-col;
    }
    return [line.substring(0,col), line.substring(col, col+length), line.substring(col+length)];
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
/// Maintains a list of "matches" - i.e. file locations, which might be navigated or jumped to.
/// A match result list may be created as part of a search in files operation of by parsing the
/// output of a build tool.
///
class MatchResultList {
  final StreamController<List<MatchedFileLocation>> _resultController = BehaviorSubject();
  final List<MatchedFileLocation> _matches = [];
  Stream<List<MatchedFileLocation>> get results => _resultController.stream;
  /// The title describing the contents of the result list.
  ValueNotifier<String> title = ValueNotifier("");

  ///
  /// The match currently selected. Can be used for next-match and previous-match operations for instance.
  ///
  final ValueNotifier<MatchedFileLocation?> selectedMatch = ValueNotifier(null);

  static final MatchResultList _current = MatchResultList._();

  ///
  /// Returns a handle to the current match result list.
  ///
  static MatchResultList get current => _current;
  MatchResultList._();

  ///
  /// The index of the currently selected element or -1 if non was selected.
  int get selectedIndex {
    var v = selectedMatch.value;
    return v == null ? -1 : _matches.indexOf(v);
  }

  ///
  /// The number of matches found.
  ///
  int get length => _matches.length;

  ///
  /// The matches as a fixed list not intended for dynamic update.
  ///
  List<MatchedFileLocation> get resultList => _matches;

  ///
  /// Reset this match result list.
  ///
  void reset() {
    _matches.clear();
    _resultController.add(_matches);
    selectedMatch.value = null;
  }

  void addAll(List<MatchedFileLocation> matches) {
    _matches.addAll(matches);
    _resultController.add(_matches);
  }

  void add(MatchedFileLocation match) {
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

