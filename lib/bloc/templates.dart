//
// templates.dart
//
// PKS-EDIT - Flutter
//
// Last modified: 07.04.24, 08:07
// Author: Tom Krauß
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:pks_edit_flutter/bloc/grammar.dart';
import 'package:pks_edit_flutter/config/copyright.dart';
import 'package:re_editor/re_editor.dart';

///
/// The position of a caret / selection position *after*
/// a template had been inserted.
///
class TemplateCaretPosition {
  final int row;
  final int column;

  TemplateCaretPosition({required this.row, required this.column});
}

///
/// Context to pass for template insertion. Contains values to use in the template and
/// contains some additional information to be used after the insertion.
///
class TemplateContext {
  final String filename;
  final Grammar grammar;
  final int tabSize;
  final CodeLineEditingController? controller;
  TemplateCaretPosition? caretPosition;
  TemplateCaretPosition? selectionEndPosition;
  int _currentRow = 0;
  int _currentColumn = 0;

  void saveCaretPosition() {
    caretPosition = TemplateCaretPosition(row: _currentRow, column: _currentColumn);
  }
  void saveSelectionEndPosition() {
    selectionEndPosition = TemplateCaretPosition(row: _currentRow, column: _currentColumn);
  }
  TemplateContext({required this.filename, required this.grammar, required this.tabSize, this.controller});
}

class Templates {
  static final Templates singleton = Templates._();
  Templates._();

  String _timeVariable(DateTime time, String variable) {
    if (variable == "year") {
      return "${time.year}";
    }
    if (variable == "year2") {
      return "${time.year - 2000}";
    }
    if (variable == "month") {
      return "${time.month+1}";
    }
    if (variable == "day") {
      return "${time.day+1}";
    }
    if (variable == "month_name") {
      return DateFormat('MMMM').format(time);
    }
    if (variable == "month_abbr") {
      return DateFormat('MMM').format(time);
    }
    if (variable == "date") {
      return DateFormat.yMd(Intl.getCurrentLocale()).format(time);
    }
    if (variable == "time") {
      return DateFormat.jm(Intl.getCurrentLocale()).format(time);
    }
    return "unknown date format $variable";
  }
  String _evaluateVariable(String variable, TemplateContext context) {
    if (variable.startsWith("today.")) {
      var time = DateTime.now();
      return _timeVariable(time, variable.substring(6));
    }
    int idx = variable.indexOf('.');
    if (idx > 0) {
      var res = _evaluateVariable(variable.substring(0, idx), context);
      var remainder = variable.substring(idx+1);
      if (remainder == 'toUpper()') {
        return res.toUpperCase();
      }
      if (remainder == 'toLower()') {
        return res.toLowerCase();
      }
      return res;
    }
    if (variable == "copyright") {
      var copyright = CopyrightManager.current.getCopyrightFormatted(context.grammar);
      return evaluateTemplate(copyright, context);
    }
    if (variable == "user") {
      return Platform.environment["USERNAME"] ?? Platform.environment["USER"] ?? "unknown";
    }
    if (variable == "file_name") {
      return basename(context.filename);
    }
    if (variable == "file_name_no_suffix") {
      var res = basename(context.filename);
      var ext = extension(res);
      return res.substring(0, res.length-ext.length);
    }
    // probably not yet supported.
    return "";
  }

  String evaluateTemplate(String s, TemplateContext context) {
    var result = StringBuffer();
    var controller = context.controller;
    for (int i = 0; i < s.length; i++) {
      var c = s[i];
      if (c == r'$' && i < s.length-1 && s[i+1] == '{') {
        var variable = StringBuffer();
        var j = i+2;
        for (; j < s.length; j++) {
          c = s[j];
          if (c == '}') {
            var v = variable.toString();
            if (v == 'cursor') {
              context.saveCaretPosition();
            } else if (v == 'selection_end') {
              context.saveSelectionEndPosition();
            } else if (v == 'tab') {
              for (int i = 0; i < context.tabSize; i++) {
                result.write(' ');
              }
            } else if (v == 'indent' && controller != null) {
              final String text = controller.baseLine.text;
              int col = 0;
              for (int i = 0; i < text.length; i++) {
                if (text[i] == ' ') {
                  col++;
                } else if (text[i] == '\t') {
                  col = (col + context.tabSize) ~/ context.tabSize * context.tabSize;
                } else {
                  break;
                }
              }
              for (int i = 0; i < col; i++) {
                result.write(' ');
              }
            } else {
              result.write(_evaluateVariable(v, context));
            }
            break;
          }
          variable.write(c);
        }
        i = j;
        continue;
      }
      result.write(c);
      if (c == '\n') {
        context._currentColumn = 0;
        context._currentRow++;
      } else {
        context._currentColumn++;
      }
    }
    return result.toString();
  }

  String generateInitialContent(TemplateContext context) {
    var ext = extension(context.filename);
    if (ext.startsWith(".")) {
      ext = ext.substring(1);
    }
    var fileTemplate = context.grammar.templates.firstWhereOrNull((t) => t.name == "file_$ext");
    fileTemplate ??= context.grammar.templates.firstWhereOrNull((t) => t.name == "file");
    if (fileTemplate != null) {
      return evaluateTemplate(fileTemplate.contents, context);
    }
    return "";
  }
}
