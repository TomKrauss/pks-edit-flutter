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

///
/// Brings up a dialog to ask for a confirmation with actions and the possible outcome of
/// the confirmation as selected by the user.
///
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Map<String, String?> actions;

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
          builder: (context) => ConfirmationDialog(
              title: title,
              message: message,
              actions: actions,
              icon: icon ?? Icons.question_mark));

  const ConfirmationDialog(
      {String? title,
      required this.message,
      this.icon = Icons.question_mark,
      Map<String, String?>? actions,
      super.key})
      : title = title ?? "Confirmation",
        actions = actions ?? const {"Yes": "yes", "No": "no", "Cancel": null};

  @override
  Widget build(BuildContext context) =>
      SimpleDialog(title: Text(title),
          contentPadding: const EdgeInsets.all(25),
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
              const SizedBox(height: 20),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: actions.entries
                      .mapIndexed((idx, e) => ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(e.value);
                          },
                          autofocus: idx == 0,
                          child: Text(e.key)))
                      .toList())
      ]);
}
