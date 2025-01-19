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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pks_edit_flutter/bloc/editor_bloc.dart';
import 'package:pks_edit_flutter/util/platform_extension.dart';

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

class SearchEngine {
  final String name;
  final String command;

  SearchEngine({required this.name, required this.command});
}

///
/// Represents the configuration settings related to editing and the appearance of PKS EDIT
/// defined in $PKS_SYS/pkseditini.json.
///
@JsonSerializable(includeIfNull: false)
class ApplicationConfiguration {
  static const supportedLanguages = ["Deutsch", "English"];
  static final List<SearchEngine> defaultSearchEngines = [
    SearchEngine(name: "Google", command: "https://www.google.com/search?q=\$1"),
    SearchEngine(name: "Bing", command: "https://www.bing.com/search?q=\$1"),
    SearchEngine(name: "Yahoo", command: "https://search.yahoo.com/search?q=\$1"),
    SearchEngine(name: "DuckDuckGo", command: "https://duckduckgo.com/?q=\$1"),
    SearchEngine(name: "Ecosia", command: "https://www.ecosia.org/search?q=\$1"),
    SearchEngine(name: "Ask", command: "https://www.ask.com/web?q=\$1"),
    SearchEngine(name: "Startpage", command: "https://www.startpage.com/sp/search?q=\$1"),
    SearchEngine(name: "Infinity Search", command: "https://infinitysearch.co/results?q=\$1"),
    SearchEngine(name: "Aol", command: "https://search.aol.com/aol/search?q=\$1"),
    SearchEngine(name: "excite", command: "https://results.excite.com/serp?q=\$1"),
    SearchEngine(name: "Search", command: "https://www.search.com/web?q=\$1"),
    SearchEngine(name: "Answers", command: "https://www.answers.com/search?q=\$1"),
    SearchEngine(name: "Lycos", command: "https://search20.lycos.com/web/?q=\$1"),
    SearchEngine(name: "Infospace", command: "https://infospace.com/serp?q=\$1"),
    SearchEngine(name: "WebCrawler", command: "https://www.webcrawler.com/serp?q=\$1"),
    SearchEngine(name: "Babylon", command: "http://search.babylon.com/?q=\$1"),
    SearchEngine(name: "Kiddle", command: "https://www.kiddle.co/s.php?q=\$1"),
    SearchEngine(name: "Yandex", command: "https://yandex.com/search/?text=\$1"),
    SearchEngine(name: "Wolfram|Alpha", command: "https://www.wolframalpha.com/input/?i=\$1"),
  ];
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
  @JsonKey(name: "pruned-search-directories")
  String prunedSearchDirectories = ".*:build:target";
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
  bool formsFollowMouse;

  /// Whether PKS-Edit displays in full screen mode (not menu-/statusbar etc..)
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool fullscreen = false;

  /// The font-size used in the code editor.
  @JsonKey(includeToJson: false, includeFromJson: false)
  int fontSize = 14;

  @JsonKey(name: "show-error-toast")
  bool showErrorsInToast;
  /// The name of the sound to play on errors.
  @JsonKey(name: "sound-name")
  final String soundName;
  ///
  /// The error sound to play, when an error occurs.
  ///
  SystemSoundType get errorSound {
    try {
      return SystemSoundType.values.byName(soundName);
    } catch(_) {

    }
    return SystemSoundType.alert;
  }

  @JsonKey(name: "sound-on-error")
  bool playSoundOnError;

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
  bool autoSaveOnExit;
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
  int? autosaveTimeSeconds;
  @JsonKey(name: "undo-enabled")
  final bool undoEnabled;
  /// The number of undo steps available
  @JsonKey(name: "undo-history")
  final int undoHistory;
  /// Whether autosaved files should be deleted on exit.
  @JsonKey(name: "cleanup-autosave-files")
  final bool cleanupAutosaveFiles;
  /// Whether files changed externally should be silently reloaded.
  @JsonKey(name: "silently-reload-changed-files")
  bool silentlyReloadChangedFiles;

  //// Searching and handling compiler output formats
  /// The default search engine for performing a search for editor words.
  @JsonKey(name: "search-engine")
  String searchEngine;
  /// Used for include searches, when editing c-/c++ files.
  List<String> get includes => includePath.split(PlatformExtension.filePathSeparator);
  @JsonKey(name: "include-path")
  final String includePath;
  @JsonKey(name: "temp-path")
  String? pksEditTempPath;
  /// Used for navigating errors from compiler outputs.
  @JsonKey(name: "compiler-output-patterns")
  final List<CompilerOutputPattern> compilerOutputPatterns;

  ApplicationConfiguration({
    this.compactEditorTabs = true,
    this.showErrorsInToast = true,
    this.playSoundOnError = false,
    this.silentlyReloadChangedFiles = true,
    this.soundName = "default",
    this.pksEditTempPath,
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

  ///
  /// Get the search engine command to be used to perform internet searches of selected words.
  ///
  String getSearchEngineCommand() => (defaultSearchEngines.firstWhereOrNull((s) => s.name == searchEngine) ?? defaultSearchEngines.first).command;
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

