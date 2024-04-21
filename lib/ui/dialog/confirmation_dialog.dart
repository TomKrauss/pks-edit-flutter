//
// confirmation_dialog.dart
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


import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pks_edit_flutter/generated/l10n.dart';
import 'package:pks_edit_flutter/ui/dialog/dialog.dart';

///
/// Brings up a dialog to ask for a confirmation with actions and the possible outcome of
/// the confirmation as selected by the user.
///
class ConfirmationDialog extends StatelessWidget {
  static const actionCancel = "cancel";
  static const actionSave = "save";
  static const actionClose = "close";
  static const actionYes = "yes";
  static const actionNo = "no";
  final String? title;
  final String message;
  final IconData? icon;
  final Map<String, String?>? actions;
  static Map<String, String?> get yesNoActions => {S.current.yes: actionYes, S.current.no: actionNo};
  static Map<String, String?> get yesNoCancelActions => {S.current.yes: actionYes, S.current.no: actionNo, S.current.cancel: actionCancel};

  ///
  /// Show a confirmation dialog with the given [title], [message] and [actions] and an optional [icon]. The result is the value of the
  /// action association from te actions map.
  ///
  static Future<String?> show(
          {required BuildContext context,
          String? title,
          required String message,
          Map<String, String?>? actions,
          IconData? icon}) =>
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ConfirmationDialog(
              title: title,
              message: message,
              actions: actions,
              icon: icon ?? Icons.question_mark));

  const ConfirmationDialog(
      {this.title,
      required this.message,
      this.icon = Icons.question_mark,
      this.actions,
      super.key});

  SingleActivator? forAction(String? action) {
    switch(action) {
      case actionYes:
        return const SingleActivator(LogicalKeyboardKey.keyY);
      case actionNo:
        return const SingleActivator(LogicalKeyboardKey.keyN);
      case actionCancel:
        return const SingleActivator(LogicalKeyboardKey.escape);
      case actionClose:
        return const SingleActivator(LogicalKeyboardKey.keyC);
      case actionSave:
        return const SingleActivator(LogicalKeyboardKey.keyS);
    }
    return null;
  }
  @override
  Widget build(BuildContext context) =>
      PksDialog(
          title: Text(title ?? S.of(context).confirmation),
          actions: (actions ?? yesNoCancelActions).entries
              .mapIndexed((idx, e) => DialogAction(
              text: e.key,
              shortcut: forAction(e.value),
              onPressed: () {
                Navigator.of(context).pop(e.value);
              },
              autofocus: idx == 0))
              .toList(),
          children: [
              Row(children: [
                if (icon != null)
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Icon(icon!),
                  ),
                Flexible(
                    child: Text(
                  message,
                  maxLines: 10,
                  softWrap: true,
                )),
              ]),
      ]);
}
