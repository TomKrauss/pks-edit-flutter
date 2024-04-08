//
// pks_ini.dart
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

///
/// Represents the configuration as defined in file $PKS_SYS/pkseditini.json
///
class EditorConfiguration {
  final String themeName;
  final List<String> includes;
  final String defaultLanguage;
  final String defaultFontFace;
  final String searchEngine;
  final int maximumOpenWindows;

  EditorConfiguration({
    required this.themeName,
    required this.includes,
    required this.defaultLanguage,
    required this.maximumOpenWindows,
    required this.defaultFontFace, required this.searchEngine});

  static EditorConfiguration get defaultConfiguration => EditorConfiguration(
    defaultFontFace: Platform.isWindows ? "Consolas" : "Courier",
    searchEngine: "Google",
    includes: [],
    maximumOpenWindows: 10,
    themeName: "default",
    defaultLanguage: "English"
  );

  static EditorConfiguration from(Map<String, dynamic> json) {
    String path = json["include-path"] ?? "include;inc";
    var defaultConfig = defaultConfiguration;
    var nested = json["configuration"];
    if (nested is Map) {
      json = Map<String,dynamic>.from(nested);
    } else {
      return defaultConfig;
    }
    return EditorConfiguration(themeName: json["theme"] ?? defaultConfig.themeName, includes: path.split(";"),
        defaultLanguage: json["language"] ?? defaultConfig.defaultLanguage,
        maximumOpenWindows: json["maximum-open-windows"] ?? defaultConfig.maximumOpenWindows,
        defaultFontFace: json["default-font"] ?? defaultConfig.defaultFontFace,
        searchEngine: json["search-engine"] ?? defaultConfig.searchEngine);
  }
}
