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
import 'package:json_annotation/json_annotation.dart';

part 'theme_configuration.g.dart';

///
/// Configuration of one theme of PKS EDIT.
///
@JsonSerializable(includeIfNull: false)
class ThemeConfiguration {
  final String name;
  @JsonKey()
  final int darkMode;
  bool get isDark => darkMode != 0;
  @JsonKey(fromJson: _parseColor, toJson: _printColor)
  final Color backgroundColor;
  @JsonKey(fromJson: _parseColor, toJson: _printColor)
  final Color iconColor;
  @JsonKey(fromJson: _parseColor, toJson: _printColor)
  final Color changedLineColor;
  @JsonKey(fromJson: _parseColor, toJson: _printColor)
  final Color dialogLightBackground;
  @JsonKey(name: "dialogBackground", fromJson: _parseOptColor, toJson: _printOptColor)
  late final Color? optDialogBackground;
  Color get dialogBackground => optDialogBackground ?? (isDark ? const Color(0xFF303030) : const Color(0xFFefefef));
  @JsonKey(fromJson: _parseColor, toJson: _printColor)
  final Color dialogLight;
  @JsonKey(fromJson: _parseColor, toJson: _printColor)
  final Color dialogBorder;

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
      colorName = "FF$colorName";
    }
    int colorValue = int.tryParse(colorName, radix: 16) ?? 0;
    return Color(colorValue);
  }

  static String? _printOptColor(Color? color) => color == null ? null : _printColor(color);

  static String _printColor(Color color) => color.value.toRadixString(16);

  ThemeConfiguration({this.name = "default",
    this.backgroundColor = Colors.black,
    this.darkMode = 0,
    this.dialogLightBackground = Colors.black26,
    this.optDialogBackground,
    this.dialogLight = Colors.white38,
    this.dialogBorder = Colors.black12,
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
      throw "At least one theme configuration must be defined.";
    }
    for (var t in themes) {
      _themeMap[t.name] = t;
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
