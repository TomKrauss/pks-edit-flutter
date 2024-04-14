//
// shortcuts.dart
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

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:re_editor/re_editor.dart';

const Map<CodeShortcutType, List<ShortcutActivator>> _kDefaultCommonCodeShortcutsActivators = {
  CodeShortcutType.cut: [
    SingleActivator(LogicalKeyboardKey.keyX, control: true)
  ],
  CodeShortcutType.copy: [
    SingleActivator(LogicalKeyboardKey.keyC, control: true)
  ],
  CodeShortcutType.paste: [
    SingleActivator(LogicalKeyboardKey.keyV, control: true)
  ],
  CodeShortcutType.delete: [
    SingleActivator(LogicalKeyboardKey.delete,),
    SingleActivator(LogicalKeyboardKey.delete, shift: true),
    SingleActivator(LogicalKeyboardKey.delete, control: true),
    SingleActivator(LogicalKeyboardKey.delete, control: true, shift: true),
    SingleActivator(LogicalKeyboardKey.delete, alt: true),
    SingleActivator(LogicalKeyboardKey.delete, alt: true, shift: true),
  ],
  CodeShortcutType.backspace: [
    SingleActivator(LogicalKeyboardKey.backspace,),
    SingleActivator(LogicalKeyboardKey.backspace, shift: true),
    SingleActivator(LogicalKeyboardKey.backspace, control: true),
    SingleActivator(LogicalKeyboardKey.backspace, control: true, shift: true),
    SingleActivator(LogicalKeyboardKey.backspace, alt: true),
    SingleActivator(LogicalKeyboardKey.backspace, alt: true, shift: true),
  ],
  CodeShortcutType.lineSelect: [
    SingleActivator(LogicalKeyboardKey.keyL, control: true)
  ],
  CodeShortcutType.lineDelete: [
    SingleActivator(LogicalKeyboardKey.keyD, control: true)
  ],
  CodeShortcutType.lineMoveUp: [
    SingleActivator(LogicalKeyboardKey.arrowUp, alt: true)
  ],
  CodeShortcutType.lineMoveDown: [
    SingleActivator(LogicalKeyboardKey.arrowDown, alt: true)
  ],
  CodeShortcutType.cursorMoveUp: [
    SingleActivator(LogicalKeyboardKey.arrowUp)
  ],
  CodeShortcutType.cursorMoveDown: [
    SingleActivator(LogicalKeyboardKey.arrowDown)
  ],
  CodeShortcutType.cursorMoveForward: [
    SingleActivator(LogicalKeyboardKey.arrowRight)
  ],
  CodeShortcutType.cursorMoveBackward: [
    SingleActivator(LogicalKeyboardKey.arrowLeft)
  ],
  CodeShortcutType.cursorMoveLineStart: [
    SingleActivator(LogicalKeyboardKey.home)
  ],
  CodeShortcutType.cursorMoveLineEnd: [
    SingleActivator(LogicalKeyboardKey.end)
  ],
  CodeShortcutType.cursorMovePageStart: [
    SingleActivator(LogicalKeyboardKey.home, control: true)
  ],
  CodeShortcutType.cursorMovePageEnd: [
    SingleActivator(LogicalKeyboardKey.end, control: true)
  ],
  CodeShortcutType.cursorMoveWordBoundaryForward: [
    SingleActivator(LogicalKeyboardKey.arrowLeft, control: true)
  ],
  CodeShortcutType.cursorMoveWordBoundaryBackward: [
    SingleActivator(LogicalKeyboardKey.arrowRight, control: true)
  ],
  CodeShortcutType.selectionExtendUp: [
    SingleActivator(LogicalKeyboardKey.arrowUp, shift: true)
  ],
  CodeShortcutType.selectionExtendDown: [
    SingleActivator(LogicalKeyboardKey.arrowDown, shift: true)
  ],
  CodeShortcutType.selectionExtendForward: [
    SingleActivator(LogicalKeyboardKey.arrowRight, shift: true)
  ],
  CodeShortcutType.selectionExtendBackward: [
    SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true)
  ],
  CodeShortcutType.selectionExtendPageStart: [
    SingleActivator(LogicalKeyboardKey.home, shift: true, control: true)
  ],
  CodeShortcutType.selectionExtendPageEnd: [
    SingleActivator(LogicalKeyboardKey.end, shift: true, control: true)
  ],
  CodeShortcutType.selectionExtendLineStart: [
    SingleActivator(LogicalKeyboardKey.home, shift: true)
  ],
  CodeShortcutType.selectionExtendLineEnd: [
    SingleActivator(LogicalKeyboardKey.end, shift: true)
  ],
  CodeShortcutType.indent: [
    SingleActivator(LogicalKeyboardKey.tab)
  ],
  CodeShortcutType.outdent: [
    SingleActivator(LogicalKeyboardKey.tab, shift: true)
  ],
  CodeShortcutType.newLine: [
    SingleActivator(LogicalKeyboardKey.enter),
    SingleActivator(LogicalKeyboardKey.enter, shift: true),
    SingleActivator(LogicalKeyboardKey.enter, control: true),
    SingleActivator(LogicalKeyboardKey.enter, control: true, shift: true)
  ],
  CodeShortcutType.singleLineComment: [
    SingleActivator(LogicalKeyboardKey.slash, control: true)
  ],
  CodeShortcutType.multiLineComment: [
    SingleActivator(LogicalKeyboardKey.slash, control: true, shift: true)
  ],
  CodeShortcutType.esc: [
    SingleActivator(LogicalKeyboardKey.escape)
  ],
};

///
/// Enforce PKS EDIT specific shortcut definitions (for now hard-coded).
///
class PksEditCodeShortcutsActivatorsBuilder extends CodeShortcutsActivatorsBuilder {
  static bool initialized = false;
  const PksEditCodeShortcutsActivatorsBuilder();

  @override
  List<ShortcutActivator>? build(CodeShortcutType type) {
    if (!initialized) {
      if (Platform.isMacOS) {
        for (var entry in _kDefaultCommonCodeShortcutsActivators.entries) {
          _kDefaultCommonCodeShortcutsActivators[entry.key] = entry.value.map((e) {
            if ((e as SingleActivator).control) {
              return SingleActivator(e.trigger, shift: e.shift, meta: true, control: false, alt: e.alt);
            }
            return e;
          }).toList();
        }
      }
      initialized = true;
    }
    return  _kDefaultCommonCodeShortcutsActivators[type];
  }
}

