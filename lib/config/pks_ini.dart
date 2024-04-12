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

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pks_edit_flutter/bloc/editor_bloc.dart';
import 'package:pks_edit_flutter/util/platform_extension.dart';

part 'pks_ini.g.dart';

///
/// Represents the UI configuration port of $PKS_SYS/pkseditini.json.
///
@JsonSerializable(includeIfNull: false)
class ApplicationConfiguration {
  /// The application theme (colors etc...)
  String theme;
  /// Used for include searches, when editing c-/c++ files.
  List<String> get includes => includePath.split(PlatformExtension.filePathSeparator);
  @JsonKey(name: "include-path")
  final String includePath;
  /// The application language (German, English)
  String language;
  /// The default font used in editors.
  @JsonKey(name: "default-font")
  String defaultFont;
  /// The size of the icons (small, medium, big, large)
  @JsonKey(name: "icon-size")
  String iconSizeName;
  ///
  /// The size of the icons in the toolbar.
  ///
  int get iconSize => switch(iconSizeName) {
    "medium" => 32,
    "big" => 48,
    "large" => 64,
    _ => 24
  };

  /// The default search engine for performing a search for editor words.
  @JsonKey(name: "search-engine")
  final String searchEngine;
  /// The maximum number of open windows before starting to close windows automatically. If <= 0 - not limit.
  @JsonKey(name: "maximum-open-windows")
  final int maximumOpenWindows;
  /// Whether the status bar will be displayed.
  @JsonKey(name: "show-statusbar")
  final bool showStatusbar;
  /// Whether the function key bar will be displayed.
  @JsonKey(name: "show-functionkeys")
  final bool showFunctionKeys;
  /// Whether the option bar will be displayed.
  @JsonKey(name: "show-optionbar")
  final bool showOptionBar;
  /// Whether the tool bar will be displayed.
  @JsonKey(name: "show-toolbar")
  final bool showToolbar;
  @JsonKey(name: "autosave-to-temp")
  final bool autoSaveToTemp;
  /// Automatically save changed files when closing editor / exiting PKS-Edit.
  @JsonKey(name: "autosave-on-exit")
  final bool autoSaveOnExit;
  /// Restore previously opened files.
  @JsonKey(name: "preserve-history")
  final bool preserveHistory;
  @JsonKey(name: "create-back-in-temp-path")
  final bool createBackInTempPath;
  /// Whether opened files will be locked.
  @JsonKey(name: "lock-files-for-edit")
  final bool lockFilesForEdit;
  /// Whether we should enforce to re-use the single running instance of PKS-Edit
  @JsonKey(name: "reuse-application-running-instance")
  final bool reuseApplicationRunningInstance;
  /// The time in seconds after which changed files are automatically saved.
  @JsonKey(name: "autosave-time")
  final int? autosaveTimeSeconds;

  ApplicationConfiguration({
    this.theme = "dark",
    this.includePath = "includes;inc",
    this.language = "English",
    this.maximumOpenWindows = -1,
    this.iconSizeName = "small",
    this.autosaveTimeSeconds,
    this.showStatusbar = true,
    this.showToolbar = true,
    this.showFunctionKeys = true,
    this.showOptionBar = true,
    this.autoSaveOnExit = false,
    this.autoSaveToTemp = false,
    this.preserveHistory = true,
    this.createBackInTempPath = true,
    this.lockFilesForEdit = false,
    this.reuseApplicationRunningInstance = true,
    String? defaultFont,
    this.searchEngine = "Google"}) :
      defaultFont = defaultFont ?? (Platform.isWindows ? "Consolas" : "Courier New")
  ;

  static ApplicationConfiguration get defaultConfiguration => ApplicationConfiguration();

  static ApplicationConfiguration fromJson(Map<String, dynamic> map) =>
      _$ApplicationConfigurationFromJson(map);
  Map<String, dynamic> toJson() => _$ApplicationConfigurationToJson(this);
}

///
/// Represents the print configuration port of file $PKS_SYS/pkseditini.json.
///
@JsonSerializable(includeIfNull: false)
class PrintConfiguration {
  final bool wrap;
  PrintConfiguration({required this.wrap});

  static PrintConfiguration fromJson(Map<String, dynamic> map) =>
      _$PrintConfigurationFromJson(map);
  Map<String, dynamic> toJson() => _$PrintConfigurationToJson(this);
}

///
/// Represents the configuration as defined in file $PKS_SYS/pkseditini.json.
///
@JsonSerializable(includeIfNull: false)
class PksIniConfiguration {
  static PksIniConfiguration of(BuildContext context) => PksIniProvider.of(context);
  final ApplicationConfiguration configuration;
  @JsonKey(name: "print-configuration")
  final PrintConfiguration printConfiguration;

  PksIniConfiguration({required this.configuration, required this.printConfiguration});

  static PksIniConfiguration fromJson(Map<String, dynamic> map) =>
      _$PksIniConfigurationFromJson(map);
  Map<String, dynamic> toJson() => _$PksIniConfigurationToJson(this);
}

///
/// Widget providing the application configuration (PksIni) allowing to access the application configuration from an inherited widget.
///
class PksIniContextWidget extends InheritedWidget {
  const PksIniContextWidget({
    super.key,
    required this.configuration,
    required super.child,
  });

  final PksIniConfiguration configuration;

  @override
  bool updateShouldNotify(PksIniContextWidget oldWidget) => true;
}

///
/// This stateful widget provides access to the Business Logic Components (BLOC)
/// of PKS Edit.
///
class PksIniProvider extends StatelessWidget {
  final Widget Function() createChild;
  const PksIniProvider({super.key, required this.createChild});

  static PksIniContextWidget _contextWidget(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PksIniContextWidget>()!;

  static PksIniConfiguration of(BuildContext context) => _contextWidget(context).configuration;

  @override
  Widget build(BuildContext context) =>
      StreamBuilder(stream: EditorBloc.of(context).pksIniStream, builder: (context, snapshot) {
        var configuration = snapshot.data;
        if (configuration != null) {
            return PksIniContextWidget(configuration: configuration, child: createChild());
        }
        return const CircularProgressIndicator();
  });
}

