//
// theme_configuration.dart
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
import 'package:flutter/scheduler.dart';
import 'package:json_annotation/json_annotation.dart';

part 'theme_configuration.g.dart';

///
/// Configuration of one theme of PKS EDIT.
///
@JsonSerializable(includeIfNull: false)
class ThemeConfiguration {
  final String name;
  @JsonKey()
  final int? darkMode;
  bool get isDark {
    if (darkMode == 1) {
      return true;
    }
    if (darkMode == 0) {
      return false;
    }
    var brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }
  @JsonKey(fromJson: _parseColor, toJson: _printColor)
  final Color backgroundColor;
  @JsonKey(fromJson: _parseColor, toJson: _printColor)
  final Color iconColor;
  @JsonKey(fromJson: _parseColor, toJson: _printColor)
  final Color changedLineColor;
  @JsonKey(fromJson: _parseOptColor, toJson: _printOptColor)
  final Color? dialogLightBackground;
  @JsonKey(name: "dialogBackground", fromJson: _parseOptColor, toJson: _printOptColor)
  late final Color? optDialogBackground;
  Color get dialogBackground => optDialogBackground ?? (isDark ? const Color(0xFF303030) : const Color(0xFFefefef));
  @JsonKey(fromJson: _parseColor, toJson: _printColor)
  final Color dialogLight;
  @JsonKey(fromJson: _parseOptColor, toJson: _printOptColor)
  final Color? dialogBorder;

  static Color? _parseOptColor(String? colorName) {
    if (colorName == null) {
      return null;
    }
    return _parseColor(colorName);
  }

  static Color _parseColor(String colorName) {
    if (colorName.startsWith("#")) {
      colorName = colorName.substring(1);
    }
    if (colorName.length == 6) {
      colorName = "ff$colorName";
    }
    var colorValue = int.tryParse(colorName, radix: 16);
    return Color(colorValue ?? 0);
  }

  static String? _printOptColor(Color? color) => color == null ? null : _printColor(color);

  // ignore: deprecated_member_use
  static String _printColor(Color color) => color.value.toRadixString(16);

  ThemeConfiguration({this.name = "system default",
    this.backgroundColor = Colors.white,
    this.darkMode,
    this.dialogLightBackground,
    this.dialogBorder,
    this.optDialogBackground,
    this.dialogLight = Colors.white38,
    this.changedLineColor = Colors.white30, this.iconColor = Colors.blueAccent});


  static ThemeConfiguration fromJson(Map<String, dynamic> map) =>
      _$ThemeConfigurationFromJson(map);
  Map<String, dynamic> toJson() => _$ThemeConfigurationToJson(this);
}

///
/// The Themes as read from a file.
///
@JsonSerializable(includeIfNull: false)
class Themes {
  final List<ThemeConfiguration> themes;
  final _themeMap = <String, ThemeConfiguration>{};
  late ThemeConfiguration _currentTheme;
  List<String> get supportedThemeNames => themes.map((e) => e.name).toList();

  Themes({required this.themes}) {
    if (themes.isEmpty) {
      throw Exception("At least one theme configuration must be defined.");
    }
    for (final t in themes) {
      _themeMap[t.name] = t;
    }
    final sysDefault = ThemeConfiguration();
    if (!_themeMap.containsKey(sysDefault.name)) {
      themes.insert(0, sysDefault);
      _themeMap[sysDefault.name] = sysDefault;
    }
    _currentTheme = themes.first;
  }

  static Themes fromJson(Map<String, dynamic> map) =>
      _$ThemesFromJson(map);
  Map<String, dynamic> toJson() => _$ThemesToJson(this);

  ///
  /// Returns the current PKS EDIT theme.
  ///
  ThemeConfiguration get currentTheme => _currentTheme;

  ///
  /// Return the theme with the given name.
  ///
  void selectTheme(String theme) {
    _currentTheme = _themeMap[theme] ?? themes.first;
  }
}
