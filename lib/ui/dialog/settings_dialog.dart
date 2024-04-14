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
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pks_edit_flutter/bloc/editor_bloc.dart';
import 'package:pks_edit_flutter/config/pks_ini.dart';
import 'package:pks_edit_flutter/generated/l10n.dart';

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
  late PksIniConfiguration configuration;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    configuration = PksIniConfiguration.of(context).copyWith();
  }

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

  Widget property(String label, IconData? icon, Widget editor) =>
      Row(children: [SizedBox(width: 300, child: Row(children: [Icon(icon), const SizedBox(width: 10), Text(label,
            style: Theme.of(context).listTileTheme.titleTextStyle)])), Expanded(child: editor)]);

  Widget intProperty(String label, IconData? icon, int originalValue, void Function(int newValue) assignValue) =>
    property(label, icon, TextField(controller: TextEditingController(text: "$originalValue"), inputFormatters: [FilteringTextInputFormatter.digitsOnly], onChanged: (newValue) {
      var newIntValue = int.tryParse(newValue);
      if (newIntValue != null) {
        changed = true;
        assignValue(newIntValue);
      }
    },));

  Widget booleanProperty(String label, IconData? icon, bool checked, void Function(bool newValue) onCheck) =>
    CheckboxListTile(
        secondary: Icon(icon),
        title: Text(label), contentPadding: EdgeInsets.zero, value: checked, onChanged: (val) {
      if (val != null) {
        changed = true;
        onCheck(val);
      }
    });

  ///
  /// Create an editor to edit a config value consisting of enumeratable options.
  ///
  Widget enumProperty<T>(String label, IconData? icon, List<T> values, T selected, void Function(T value) onSelect, {String Function(T)? toString}) =>
      property(
          label,
          icon,
          DropdownButton<T>(
              items: values
                  .map((e) => DropdownMenuItem(
                value: e,
                child: Text(toString != null ? toString(e) : e.toString()),
              ))
                  .toList(),
              value: selected,
              onChanged: (value) {
                if (value != null) {
                  changed = true;
                  onSelect(value);
                }
              }));

  Widget createButton(String text, void Function()? onPressed) => ElevatedButton(onPressed: onPressed, child: Text(text));

  @override
  Widget build(BuildContext context) {
    final bloc = EditorBloc.of(context);
    final themes = bloc.themes.supportedThemeNames;
    const iconSizes = IconSize.values;
    final conf = configuration.configuration;
    return SimpleDialog(
        contentPadding: const EdgeInsets.all(25),
        children: [
      enumProperty(
          S.of(context).language, Icons.language, ApplicationConfiguration.supportedLanguages, conf.language, (newLang) => conf.language = newLang),
      enumProperty(
          "Theme", Icons.palette, themes, bloc.themes.currentTheme.name, (newTheme) => conf.theme = newTheme),
      enumProperty(
          "Text Font", Icons.font_download_rounded, ApplicationConfiguration.supportedFonts, conf.defaultFont, (newFont) => conf.defaultFont = newFont),
      enumProperty(
        S.of(context).iconSize, FontAwesomeIcons.arrowUp91, iconSizes, conf.iconSize, (newIconSize) => conf.iconSize = newIconSize, toString: (s) => s.name),
      booleanProperty(S.of(context).compactEditorTabs, FontAwesomeIcons.tableColumns, conf.compactEditorTabs, (newValue) {conf.compactEditorTabs = newValue; }),
      booleanProperty(S.of(context).showToolbar, Icons.border_top, conf.showToolbar, (newValue) {conf.showToolbar = newValue; }),
      booleanProperty(S.of(context).showStatusbar, Icons.border_bottom, conf.showStatusbar, (newValue) {conf.showStatusbar = newValue; }),
      intProperty(S.of(context).maximumNumberOfWindows, FontAwesomeIcons.windowMaximize, conf.maximumOpenWindows, (newValue) { conf.maximumOpenWindows = newValue; }),
      Padding(padding: const EdgeInsets.only(top: 40), child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
        createButton(S.of(context).apply, _changed ? () {
          bloc.updateConfiguration(configuration);
          configuration = configuration.copyWith();
          changed = false;
        } : null),
        createButton("OK", _changed ? () {
          bloc.updateConfiguration(configuration);
          Navigator.of(context).pop();
        } : null),
        createButton(S.of(context).cancel, () {
          Navigator.of(context).pop();
        }),
      ],))
    ]);
  }
}
