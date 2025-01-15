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

import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:pks_edit_flutter/bloc/grammar.dart';
import 'package:pks_edit_flutter/config/copyright.dart';

class Template {
  final String text;
  Template({required this.text});
}

class _TemplateCaretPosition {
  final int row;
  final int column;

  _TemplateCaretPosition({required this.row, required this.column});
}

class _TemplateContext {
  final String filename;
  _TemplateCaretPosition? caretPosition;
  _TemplateCaretPosition? selectionEndPosition;
  int currentRow = 0;
  int currentColumn = 0;

  void saveCaretPosition() {
    caretPosition = _TemplateCaretPosition(row: currentRow, column: currentColumn);
  }
  void saveSelectionEndPosition() {
    selectionEndPosition = _TemplateCaretPosition(row: currentRow, column: currentColumn);
  }
  _TemplateContext({required this.filename});
}

class Templates {
  static final Templates singleton = Templates._();
  Templates._();
  final Map<RegExp, Template> _templates = {
    RegExp(r".*\.java"): Template(text: ' \${copyright}\npublic void main(String[] args)\n    System.out.println("hello world");\n}'),
    RegExp(r".*\.dart"): Template(text: "\${copyright}\nvoid main(args) {\n   print('hello world');\n}"),
    RegExp(r".*\.(yaml|yml)"): Template(text: "sample:\n  property: hello"),
    RegExp(r".*\.(html|xhtml|htm)"): Template(text: '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">\n<html>\n</html>'),
    RegExp(r".*\.py"): Template(text:""),
  };

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
  String _evaluateVariable(String variable, _TemplateContext context) {
    if (variable == "copyright") {
      var copyright = CopyrightManager.current.getCopyrightFormatted(Grammar(scopeName: "default",
          commentDescriptor: CommentDescriptor(commentStart: "/*", commentEnd: "*/", commentSingle: "//")));
      return _evaluateVariablesIn(copyright, context);
    }
    if (variable == "user") {
      return Platform.environment["USERNAME"] ?? Platform.environment["USER"] ?? "unknown";
    }
    if (variable == "file_name") {
      return basename(context.filename);
    }
    if (variable.startsWith("today.")) {
      var time = DateTime.now();
      return _timeVariable(time, variable.substring(6));
    }
    // probably not yet supported.
    return "";
  }

  String _evaluateVariablesIn(String s, _TemplateContext context) {
    var result = StringBuffer();
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
        context.currentColumn = 0;
        context.currentRow++;
      } else {
        context.currentColumn++;
      }
    }
    return result.toString();
  }

  String generateInitialContent(String fileName) {
    for (final e in _templates.entries) {
      if (e.key.hasMatch(fileName)) {
        return _evaluateVariablesIn(e.value.text, _TemplateContext(filename: fileName));
      }
    }
    return "";
  }
}
