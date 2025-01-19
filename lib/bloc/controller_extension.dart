//
// controller_extension.dart
//
// PKS-EDIT - Flutter
//
// Last modified: 2024
// Author: Tom Krauß
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import 'package:re_editor/re_editor.dart';

///
/// Provides additional methods in the text controller to modify text etc...
///
extension TextEditingControllerExtension on CodeLineEditingController {
  static final RegExp _wordExpression = RegExp('[a-zA-Z0-9_-]');

  ///
  /// Returns the current word/identifier, where the caret is located.
  /// If text is selected, use the selection, otherwise the word under the caret.
  ///
  String get currentWord {
    var sel = selectedText;
    if (sel.isEmpty) {
      var text = baseLine.text;
      int i = selection.baseOffset;
      for (; --i >= 0; ) {
        if (!_wordExpression.hasMatch(text[i])) {
          i++;
          break;
        }
      }
      int j = i+1;
      while(j < text.length) {
        if (!_wordExpression.hasMatch(text[j])) {
          break;
        }
        j++;
      }
      return text.substring(i, j);
    }
    return sel;
  }
  void _upperLowerCase(String Function(String) replace) {
    var text = selectedText;
    if (text.trim().isEmpty) {
      return;
    }
    var result = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      result.write(replace(text[i]));
    }
    var originalSelection = selection.copyWith();
    replaceSelection(result.toString());
    selection = originalSelection;
  }

  void charToUpper() {
    _upperLowerCase((p0) => p0.toUpperCase());
  }

  void charToLower() {
    _upperLowerCase((p0) => p0.toLowerCase());
  }

  void charToggleUpperLower() {
    _upperLowerCase((p0) {
      var p = p0.toLowerCase();
      return p != p0 ? p : p0.toUpperCase();
    });
  }
}

