//
// dialog.dart
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pks_edit_flutter/generated/l10n.dart';

///
/// Represents one action in a dialog.
///
class DialogAction {
  final String text;
  final VoidCallback? onPressed;
  final bool? autofocus;
  final SingleActivator? shortcut;

  ///
  /// Create an action to cancel / close the dialog.
  ///
  static DialogAction createCancelAction(BuildContext context) {
    void cancel() {
      Navigator.of(context).pop();
    }
    return DialogAction(text: S.of(context).cancel, onPressed: cancel, shortcut: const SingleActivator(LogicalKeyboardKey.escape));
  }
  DialogAction({required this.text, this.onPressed, this.shortcut, this.autofocus});
}

///
/// Ensure consistent look & feel of PKS Edits dialogs.
///
class PksDialog extends StatelessWidget {
  final Widget? title;
  final List<Widget> children;
  final List<DialogAction> actions;

  const PksDialog({this.title, required this.children, required this.actions, super.key});

  @override
  Widget build(BuildContext context) {
    final shortcuts = <ShortcutActivator,VoidCallback>{};
    for (final action in actions) {
      if (action.shortcut != null && action.onPressed != null) {
        shortcuts[action.shortcut!] = action.onPressed!;
      }
    }
    return CallbackShortcuts(bindings: shortcuts, child: SimpleDialog(
      title: title,
      contentPadding: const EdgeInsets.all(25),
      children: [
        ...children,
        const SizedBox(height: 25),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: actions.map((e) => Padding(padding: const EdgeInsets.only(left: 10, bottom: 10),
            child: ConstrainedBox(constraints: const BoxConstraints(minWidth: 100),
                child: ElevatedButton(onPressed: e.onPressed, autofocus: e.autofocus ?? false,
                  child: Text(e.text),)))).toList(),)
      ],));
  }
}
