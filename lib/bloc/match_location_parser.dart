//
// match_location_parser.dart
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

import 'package:pks_edit_flutter/bloc/match_result_list.dart';

///
/// Implemented by classes allowing to parse a build output or any other kind of string representation of a
/// *match location* (e.g. the results of a search in files operation).
///
abstract interface class MatchLocationParser {
  ///
  /// To be implemented to parse an [input] string and return te parsed matched file location object.
  ///
  MatchedFileLocation? parse(String input);
}

MatchLocationParser searchInFilesResultParser = RegexBasedLocationParser(expression: RegExp('"([^"]+)", line ([0-9]+): *([0-9]+)/([0-9]+) - (.*)'),
    filenameCapture: 1, lineNumberCapture: 2, columnCapture: 3, matchLengthCapture: 4, commentCapture: 5);

class RegexBasedLocationParser implements MatchLocationParser {
  final RegExp expression;
  final int filenameCapture;
  final int lineNumberCapture;
  final int? columnCapture;
  final int? matchLengthCapture;
  final int? commentCapture;

  RegexBasedLocationParser({required this.expression, required this.filenameCapture, required this.lineNumberCapture,
    this.columnCapture,
    this.matchLengthCapture,
    this.commentCapture});

  @override
  MatchedFileLocation? parse(String input) {
    var match = expression.firstMatch(input);
    if (match == null || match.groupCount < filenameCapture || match.groupCount < lineNumberCapture) {
      return null;
    }
    var fileName = match.group(filenameCapture);
    var lineNumber = match.group(lineNumberCapture);
    if (fileName == null || lineNumber == null) {
      return null;
    }
    var cc = commentCapture;
    var comment = cc == null || cc > match.groupCount ? null : match.group(cc);
    cc = columnCapture;
    var column = cc == null || cc > match.groupCount ? null : match.group(cc);
    cc = matchLengthCapture;
    var matchLength = cc == null || cc > match.groupCount ? null : match.group(cc);
    return MatchedFileLocation(fileName: fileName, lineNumber: (int.tryParse(lineNumber) ?? 1)-1,
        column: column == null ? null : int.tryParse(column), matchLength: matchLength == null ? null : int.tryParse(matchLength),
        matchedLine: comment?.replaceAll("~", ""));
  }
}
