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
import 'package:sound_library/sound_library.dart';

part 'pks_ini.g.dart';

///
/// Definition of a Regular Expression Pattern, which is used by PKS EDIT to analyze the error output
/// of a compiler / build so it can navigate to lines with errors.
///
@JsonSerializable(includeIfNull: false)
class CompilerOutputPattern {
  final String name;
  final String pattern;
  @JsonKey(name: "filename-capture")
  final int filenameCapture;
  @JsonKey(name: "linenumber-capture")
  final int lineNumberCapture;
  @JsonKey(name: "comment-capture")
  final int commentCapture;

  CompilerOutputPattern({
    required this.name,
    required this.pattern,
    this.filenameCapture = 1,
    this.lineNumberCapture = 2,
    this.commentCapture = 3});

  static CompilerOutputPattern fromJson(Map<String, dynamic> map) =>
      _$CompilerOutputPatternFromJson(map);
  Map<String, dynamic> toJson() => _$CompilerOutputPatternToJson(this);
}

///
/// Selectable icon sizes.
///
enum IconSize {
  small(24),
  medium(32),
  big(48),
  large(64);
  final int size;
  const IconSize(this.size);
}

///
/// Represents the configuration settings related to editing and the appearance of PKS EDIT
/// defined in $PKS_SYS/pkseditini.json.
///
@JsonSerializable(includeIfNull: false)
class ApplicationConfiguration {
  static const supportedLanguages = ["Deutsch", "English"];
  static List<String> get supportedFonts => [
    if (Platform.isWindows)
    "Consolas",
    "Courier New",
    "Lucida Sans Typewriter",
    "JetBrainsMono"
  ];
  //// Appearance
  /// The application theme (colors etc...)
  String theme;
  /// The application language (Deutsch, English)
  String language;

  /// Returns the selected locale
  String get locale {
    if (language == "English") {
      return "en";
    }
    return "de";
  }
  /// The default font used in editors.
  @JsonKey(name: "default-font")
  String defaultFont;
  /// The size of the icons (small, medium, big, large)
  @JsonKey(name: "icon-size")
  IconSize iconSize;

  /// Whether the status bar will be displayed.
  @JsonKey(name: "show-statusbar")
  bool showStatusbar;
  /// Whether the function key bar will be displayed.
  @JsonKey(name: "show-functionkeys")
  bool showFunctionKeys;
  /// Whether the option bar will be displayed.
  @JsonKey(name: "show-optionbar")
  bool showOptionBar;
  /// Whether the tool bar will be displayed.
  @JsonKey(name: "show-toolbar")
  bool showToolbar;
  @JsonKey(name: "compact-editor-tabs")
  bool compactEditorTabs;
  /// Whether all forms/dialogs are opened close to the mouse position.
  @JsonKey(name: "forms-follow-mouse")
  final bool formsFollowMouse;

  @JsonKey(name: "show-error-toast")
  final bool showErrorsInToast;
  /// The name of the sound to play on errors.
  @JsonKey(name: "sound-name")
  final String soundName;
  ///
  /// The error sound to play, when an error occurs.
  ///
  Sounds get errorSound {
    try {
      return Sounds.values.byName(soundName);
    } catch(_) {

    }
    return Sounds.deleted;
  }
  @JsonKey(name: "sound-on-error")
  final bool playSoundOnError;

  /// The maximum number of open windows before starting to close windows automatically. If <= 0 - not limit.
  @JsonKey(name: "maximum-open-windows")
  int maximumOpenWindows;
  /// Restore previously opened files.
  @JsonKey(name: "preserve-history")
  final bool preserveHistory;
  /// Whether we should enforce to re-use the single running instance of PKS-Edit
  @JsonKey(name: "reuse-application-running-instance")
  final bool reuseApplicationRunningInstance;
  /// Whether recent copy edits should be saved in a history.
  @JsonKey(name: "maintain-clipboard-history")
  final bool maintainClipboardHistory;

  //// File editing and saving related options
  /// Whether automatic saves should save files to a temporary directory from where the
  /// files are restored after a crash.
  @JsonKey(name: "autosave-to-temp")
  final bool autoSaveToTemp;
  /// Automatically save changed files when closing editor / exiting PKS-Edit.
  @JsonKey(name: "autosave-on-exit")
  final bool autoSaveOnExit;
  @JsonKey(name: "create-back-in-temp-path")
  final bool createBackInTempPath;
  /// Whether opened files will be locked.
  @JsonKey(name: "lock-files-for-edit")
  final bool lockFilesForEdit;
  /// Whether the selection should be removed, when the caret moves.
  @JsonKey(name: "hide-selection-on-move")
  final bool hideSelectionOnMove;
  /// The time in seconds after which changed files are automatically saved.
  @JsonKey(name: "autosave-time")
  final int? autosaveTimeSeconds;
  @JsonKey(name: "undo-enabled")
  final bool undoEnabled;
  /// The number of undo steps available
  @JsonKey(name: "undo-history")
  final int undoHistory;
  /// Whether autosaved files should be deleted on exit.
  @JsonKey(name: "cleanup-autosave-files")
  final bool cleanupAutosaveFiles;

  //// Searching and handling compiler output formats
  /// The default search engine for performing a search for editor words.
  @JsonKey(name: "search-engine")
  final String searchEngine;
  /// Used for include searches, when editing c-/c++ files.
  List<String> get includes => includePath.split(PlatformExtension.filePathSeparator);
  @JsonKey(name: "include-path")
  final String includePath;
  /// Used for navigating errors from compiler outputs.
  @JsonKey(name: "compiler-output-patterns")
  final List<CompilerOutputPattern> compilerOutputPatterns;

  ApplicationConfiguration({
    this.compactEditorTabs = true,
    this.showErrorsInToast = true,
    this.playSoundOnError = false,
    this.soundName = "default",
    this.compilerOutputPatterns = const [],
    this.formsFollowMouse = false,
    this.maintainClipboardHistory = false,
    this.hideSelectionOnMove = true,
    this.theme = "dark",
    this.cleanupAutosaveFiles = true,
    this.undoHistory = 100,
    this.includePath = "includes;inc",
    this.language = "English",
    this.maximumOpenWindows = -1,
    this.iconSize = IconSize.small,
    this.autosaveTimeSeconds,
    this.undoEnabled = true,
    this.showStatusbar = true,
    this.showToolbar = true,
    this.showFunctionKeys = true,
    this.showOptionBar = true,
    this.autoSaveOnExit = false,
    this.autoSaveToTemp = true,
    this.preserveHistory = true,
    this.createBackInTempPath = true,
    this.lockFilesForEdit = false,
    this.reuseApplicationRunningInstance = true,
    String? defaultFont,
    this.searchEngine = "Google"}) :
      defaultFont = defaultFont ?? (Platform.isWindows ? "Consolas" : "Roboto Mono")
  ;

  ApplicationConfiguration copyWith({
    bool? compactEditorTabs,
    bool? showErrorsInToast,
    bool? playSoundOnError,
    String? soundName,
    List<CompilerOutputPattern>? compilerOutputPatterns,
    bool? formsFollowMouse,
    bool? maintainClipboardHistory,
    bool? hideSelectionOnMove,
    String? theme,
    String? searchEngine,
    bool? cleanupAutosaveFiles,
    int? undoHistory,
    String? includePath,
    String? language,
    int? maximumOpenWindows,
    IconSize? iconSize,
    int? autosaveTimeSeconds,
    bool? undoEnabled,
    bool? showStatusbar,
    bool? showToolbar,
    bool? showFunctionKeys,
    bool? showOptionBar,
    bool? autoSaveOnExit,
    bool? autoSaveToTemp,
    bool? preserveHistory,
    bool? createBackInTempPath,
    bool? lockFilesForEdit,
    bool? reuseApplicationRunningInstance,
    String? defaultFont,
  }) => ApplicationConfiguration(
    maintainClipboardHistory: maintainClipboardHistory ?? this.maintainClipboardHistory,
    compilerOutputPatterns: compilerOutputPatterns ?? this.compilerOutputPatterns,
    theme: theme ?? this.theme,
    formsFollowMouse: formsFollowMouse ?? this.formsFollowMouse,
    soundName: soundName ?? this.soundName,
    playSoundOnError: playSoundOnError ?? this.playSoundOnError,
    showErrorsInToast: showErrorsInToast ?? this.showErrorsInToast,
    compactEditorTabs: compactEditorTabs ?? this.compactEditorTabs,
    hideSelectionOnMove: hideSelectionOnMove ?? this.hideSelectionOnMove,
    cleanupAutosaveFiles: cleanupAutosaveFiles ?? this.cleanupAutosaveFiles,
    undoHistory: undoHistory ?? this.undoHistory,
    includePath: includePath ?? this.includePath,
    language: language ?? this.language,
    maximumOpenWindows: maximumOpenWindows ?? this.maximumOpenWindows,
    searchEngine: searchEngine ?? this.searchEngine,
    defaultFont: defaultFont ?? this.defaultFont,
    autoSaveOnExit: autoSaveOnExit ?? this.autoSaveOnExit,
    autoSaveToTemp: autoSaveToTemp ?? this.autoSaveToTemp,
    showOptionBar: showOptionBar ?? this.showOptionBar,
    showFunctionKeys: showFunctionKeys ?? this.showFunctionKeys,
    showToolbar: showToolbar ?? this.showToolbar,
    showStatusbar: showStatusbar ?? this.showStatusbar,
    undoEnabled: undoEnabled ?? this.undoEnabled,
    autosaveTimeSeconds: autosaveTimeSeconds ?? this.autosaveTimeSeconds,
    iconSize: iconSize ?? this.iconSize,
      reuseApplicationRunningInstance: reuseApplicationRunningInstance ?? this.reuseApplicationRunningInstance,
      lockFilesForEdit: lockFilesForEdit ?? this.lockFilesForEdit,
      createBackInTempPath: createBackInTempPath ?? this.createBackInTempPath,
      preserveHistory: preserveHistory ?? this.preserveHistory,
  );
  static ApplicationConfiguration get defaultConfiguration => ApplicationConfiguration();

  static ApplicationConfiguration fromJson(Map<String, dynamic> map) =>
      _$ApplicationConfigurationFromJson(map);
  Map<String, dynamic> toJson() => _$ApplicationConfigurationToJson(this);
}

///
/// Represents the configuration as defined in file $PKS_SYS/pkseditini.json.
///
@JsonSerializable(includeIfNull: false)
class PksIniConfiguration {
  static PksIniConfiguration of(BuildContext context) => PksIniProvider.of(context);
  final ApplicationConfiguration configuration;
  @JsonKey(name: "print-configuration")
  final Map<String,dynamic> printConfiguration;

  PksIniConfiguration({required this.configuration, this.printConfiguration = const {}});

  PksIniConfiguration copyWith({ApplicationConfiguration? applicationConfiguration, Map<String,dynamic>? printConfiguration}) =>
    PksIniConfiguration(configuration: applicationConfiguration ?? configuration.copyWith(), printConfiguration: printConfiguration ?? this.printConfiguration);

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

