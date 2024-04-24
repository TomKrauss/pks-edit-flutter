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

