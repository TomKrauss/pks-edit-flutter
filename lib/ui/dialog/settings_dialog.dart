//
// settings_dialog.dart
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
import 'package:pks_edit_flutter/bloc/editor_bloc.dart';
import 'package:pks_edit_flutter/config/pks_ini.dart';

///
/// Display the settings to edit in PKS Edit.
///
class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  static Future<void> show(
      {required BuildContext context}) =>
      showDialog(
          context: context,
          builder: (context) => const SettingsDialog());
  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  bool _changed = false;

  ///
  /// Invoke to mark the current settings as (not) dirty depending on [newValue].
  ///
  set changed(bool newValue) {
    if (_changed != newValue) {
      setState(() {
        _changed = newValue;
      });
    }
  }
  Widget property(String label, Widget editor) =>
      Row(children: [SizedBox(width: 200, child: Text(label)), Expanded(child: editor)]);

  Widget createButton(String text, void Function()? onPressed) => ElevatedButton(onPressed: onPressed, child: Text(text));

  @override
  Widget build(BuildContext context) {
    final bloc = EditorBloc.of(context);
    final themes = bloc.themes.supportedThemeNames;
    final iconSizes = <String>["small", "medium", "big", "large"];
    final configuration = PksIniConfiguration.of(context);
    return SimpleDialog(
        contentPadding: const EdgeInsets.all(25),
        children: [
      property(
          "Theme",
          DropdownButton(
              items: themes
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              value: bloc.themes.currentTheme.name,
              onChanged: (newTheme) {
                if (newTheme != null) {
                  changed = true;
                  configuration.configuration.theme = newTheme;
                }
              })),
      property(
        "Icon Size",
        DropdownButton(items: iconSizes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            value: configuration.configuration.iconSizeName,
            onChanged: (newIconSize) {
              if (newIconSize != null) {
                changed = true;
                configuration.configuration.iconSizeName = newIconSize;
              }
            })),
      Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
        createButton("Apply", _changed ? () {
          bloc.updateConfiguration(configuration);
          changed = false;
        } : null),
        createButton("OK", _changed ? () {
          bloc.updateConfiguration(configuration);
          Navigator.of(context).pop();
        } : null),
        createButton("Cancel", () {
          Navigator.of(context).pop();
        }),
      ],))
    ]);
  }
}
