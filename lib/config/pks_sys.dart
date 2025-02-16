//
// pks_sys.dart
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

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pks_edit_flutter/actions/action_bindings.dart';
import 'package:pks_edit_flutter/bloc/editor_bloc.dart';
import 'package:pks_edit_flutter/config/editing_configuration.dart';
import 'package:pks_edit_flutter/config/pks_ini.dart';
import 'package:pks_edit_flutter/config/theme_configuration.dart';
import 'package:pks_edit_flutter/util/logger.dart';
import 'package:window_manager/window_manager.dart';

part 'pks_sys.g.dart';

///
/// Represents the state of an opened editor window as read from the sessions.
///
class OpenEditorPanel {
  static final pksEditSearchListFormat =
      RegExp('"([^"]+)", line ([0-9]+): *(.*)');
  ///
  /// The file path of the file edited.
  ///
  final String path;
  ///
  /// The line number on which the caret was placed.
  ///
  final int lineNumber;
  ///
  /// Whether this panel had been active.
  ///
  final bool active;
  ///
  /// Whether this panel is the one finally focussed.
  ///
  final bool focus;
  ///
  /// Whether this panel displays a 'cloned' window.
  ///
  final bool cloned;
  ///
  /// The name of the docking slot, where the window ist placed
  ///
  final String dock;
  ///
  /// The display mode of the window.
  ///
  final int displayMode;

  OpenEditorPanel(
      {required this.path, required this.lineNumber, required this.dock, this.active = false, this.focus = false, this.cloned = false, this.displayMode = -1});

  String encodeJson() => '"$path", line $lineNumber: $dock ${active ? 'active': '-'} ${focus ? 'focus': '-'} ${cloned ? 'cloned': '-'} ${displayMode.toRadixString(16)}';

  static OpenEditorPanel? parse(String string) {
    var match = pksEditSearchListFormat.firstMatch(string);
    if (match == null) {
      return null;
    }
    var openHint = match.group(3)!;
    var hints = openHint.split(" ");
    while (hints.length < 5) {
      hints.add("-");
    }
    return OpenEditorPanel(
        path: match.group(1)!,
        lineNumber: int.tryParse(match.group(2)!) ?? 0,
        dock: hints.first,
        active: hints[1] == "active",
        focus: hints[2] == "focus",
        cloned: hints[3] == "cloned",
        displayMode: int.tryParse(hints[4], radix: 16) ?? -1
    );
  }
}

///
/// Captures the previous saved state of the main window.
///
@JsonSerializable(includeIfNull: false)
class MainWindowPlacement {
  static const swShowMaximized = 3;
  final int flags;
  final int show;
  final int top;
  final int bottom;
  final int left;
  final int right;
  MainWindowPlacement(
      {this.flags = 0,
      this.show = 1,
      this.top = 0,
      this.left = 0,
      this.right = 1000,
      this.bottom = 1000});

  static MainWindowPlacement fromJson(Map<String, dynamic> map) =>
      _$MainWindowPlacementFromJson(map);
  Map<String, dynamic> toJson() => _$MainWindowPlacementToJson(this);
}

///
/// Describes on main frame docking area.
///
@JsonSerializable(includeIfNull: false)
class MainFrameDock {
  final String name;
  final double x;
  final double y;
  final double w;
  final double h;
  MainFrameDock(
      {required this.name,
      required this.x,
      required this.y,
      required this.w,
      required this.h});

  ///
  /// Load the PaymentReceipt object from a JSON data structure.
  ///
  factory MainFrameDock.fromJson(Map<String, dynamic> json) =>
      _$MainFrameDockFromJson(json);

  ///
  /// Convert the MainFrameDock to JSON
  ///
  Map<String, dynamic> toJson() => _$MainFrameDockToJson(this);
}

///
/// Small utility for lists.
///
extension ListExtension<T> on List<T> {
  ///
  /// Add [item] to the list. If it is in the list move it to the front of
  /// the list. If [maxLength] was specified, ensure, that the list does not
  /// grow beyond the given length.
  ///
  void addOrMoveFirst(T item, {int? maxLength}) {
    int idx = indexOf(item);
    if (idx == 0) {
      return;
    }
    if (idx > 0) {
      remove(item);
    } else if (maxLength != null && length >= maxLength) {
      removeLast();
    }
    insert(0, item);
  }
}

///
/// Options used during search and replace. Are stored internally in compatibility to PKS-Edit for
/// Windows as a bitmask.
///
class SearchAndReplaceOptions {
  int _flags;
  bool get regex => (_flags & 0x1) != 0;
  bool get ignoreCase => (_flags & 0x2) != 0;
  bool get shellWildCards => (_flags & 0x4) != 0;
  bool get preserveCase => (_flags & 0x8) != 0;
  bool get ignoreBinaryFiles => (_flags & 0x10) != 0;
  bool get appendToSearchList => (_flags & 0x80) != 0;
  bool get searchInSearchResults => (_flags & 0x100) != 0;
  bool get singleMatchInFile => (_flags & 0x40) != 0;
  void _setFlag(int mask, bool value) {
    if (value) {
      _flags |= mask;
    } else {
      _flags = _flags & ~mask;
    }
  }
  set regex(bool flag) => _setFlag(0x1, flag);
  set ignoreCase(bool flag) => _setFlag(0x2, flag);
  set singleMatchInFile(bool flag) => _setFlag(0x40, flag);
  set preserveCase(bool flag) => _setFlag(0x8, flag);
  set shellWildCards(bool flag) => _setFlag(0x4, flag);
  set ignoreBinaryFiles(bool flag) => _setFlag(0x10, flag);
  set searchInSearchResults(bool flag) => _setFlag(0x100, flag);
  set appendToSearchList(bool flag) => _setFlag(0x80, flag);
  SearchAndReplaceOptions([this._flags = 0]);
}

///
/// Represents the last store PksEditSession.
///
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class PksEditSession {
  @JsonKey(name: "screen-width")
  final int? screenWidth;
  @JsonKey(name: "screen-height")
  final int? screenHeight;
  @JsonKey(name: "search-replace-options")
  int searchReplaceOptions;
  @JsonKey(name: "open-files")
  final List<String> openFiles;
  ///
  /// Folders used in e.g. search in files or when opening files.
  ///
  @JsonKey(name: "folders")
  final List<String> folders;
  @JsonKey(name: "search-patterns")
  final List<String> searchPatterns;
  @JsonKey(name: "replace-patterns")
  final List<String> replacePatterns;
  @JsonKey(name: "file-patterns")
  final List<String> filePatterns;
  @JsonKey(
      name: "open-editors",
      fromJson: _panelsFromString,
      toJson: _panelsToString)
  final List<OpenEditorPanel> openEditors;
  @JsonKey(name: "main-window-placement")
  final MainWindowPlacement mainWindowPlacement;
  @JsonKey(fromJson: _dockFromJson)
  final MainFrameDock? dock1;
  @JsonKey(fromJson: _dockFromJson)
  final MainFrameDock? dock2;
  @JsonKey(fromJson: _dockFromJson)
  final MainFrameDock? dock3;

  static Size? _screenSize;

  static Size get screenSize {
    _screenSize ??= WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
    return _screenSize!;
  }

  PksEditSession(
      {required this.screenWidth,
      required this.screenHeight,
      required this.searchReplaceOptions,
      required this.mainWindowPlacement,
      this.dock1,
      this.dock2,
      this.dock3,
        List<String>? openFiles,
        List<String>? filePatterns,
        List<String>? searchPatterns,
        List<String>? replacePatterns,
        List<String>? folders,
      this.openEditors = const []}) :
      openFiles = openFiles ?? [],
      folders = folders ?? [],
      searchPatterns = searchPatterns ?? [],
      replacePatterns = replacePatterns ?? [],
      filePatterns = filePatterns ?? [];

  ///
  /// Maximum number of entries in a "history" entry of type list of strings.
  ///
  static const int maxHistoryListSize = 32;

  @JsonKey(includeToJson: false, includeFromJson: false)
  SearchAndReplaceOptions get searchAndReplaceOptions => SearchAndReplaceOptions(searchReplaceOptions);
  set searchAndReplaceOptions(SearchAndReplaceOptions options) => searchReplaceOptions = options._flags;

  ///
  /// Prepare the current PKSEdit session for being saved, when we exit PKS EDIT.
  ///
  Future<PksEditSession> prepareSave(
      {required BuildContext context,
      MainFrameDock? dock1,
      MainFrameDock? dock2,
      MainFrameDock? dock3,
      required OpenFileState state}) async {
    final openEditors = state.files;
    var bounds = await windowManager.getBounds();
    var screenSize = PksEditSession.screenSize;
    return PksEditSession(
        screenWidth: screenSize.width.toInt(),
        screenHeight: screenSize.height.toInt(),
        mainWindowPlacement: MainWindowPlacement(
            left: bounds.left.toInt(),
            right: bounds.right.toInt(),
            top: bounds.top.toInt(),
            bottom: bounds.bottom.toInt(),
            flags: mainWindowPlacement.flags,
            show: await windowManager.isMaximized() ? 3 : 0),
        searchPatterns: searchPatterns,
        searchReplaceOptions: searchReplaceOptions,
        dock1: dock1 ?? this.dock1,
        dock2: dock2 ?? this.dock2,
        dock3: dock3 ?? this.dock3,
        filePatterns: filePatterns,
        replacePatterns: replacePatterns,
        openFiles: openFiles,
        folders: folders,
        openEditors: openEditors
            .map((e) => OpenEditorPanel(
                path: e.filename,
                dock: e.dock,
                lineNumber: e.controller.selection.baseIndex,
                active: e == state.currentFile,
                focus: e == state.currentFile))
            .toList());
  }

  static List<OpenEditorPanel> _panelsFromString(List<dynamic> list) => list
      .map((e) => e is String ? OpenEditorPanel.parse(e) : null)
      .whereType<OpenEditorPanel>()
      .toList();
  static List<String> _panelsToString(List<OpenEditorPanel> list) =>
      list.map((e) => e.encodeJson()).toList();
  static MainFrameDock? _dockFromJson(Map<String, dynamic>? json) =>
      json == null || json["name"] == null ? null : MainFrameDock.fromJson(json);

  static PksEditSession fromJson(Map<String, dynamic> jsonInput) =>
      _$PksEditSessionFromJson(jsonInput);
  Map<String, dynamic> toJson() => _$PksEditSessionToJson(this);
}

///
/// Represents all configuration related files.
///
class PksConfiguration {
  PksConfiguration._();
  static const copyrightProfilesFilename = "copyright_profiles.json";
  static const sessionFilename = "pkssession.json";
  static const configFilename = "pkseditini.json";
  static const themeFilename = "themeconfig.json";
  static const editingConfigurationFilename = "pkseditconfig.json";
  static const actionBindingsFilename = "pksactionbindings.json";
  static const searchResultsFilename = "pksedit.grep";
  static const pksSysVariable = "PKS_SYS";
  static PksConfiguration singleton = PksConfiguration._();
  final Logger _logger = createLogger("PksConfiguration");
  String? _pksSysDirectory;
  PksEditSession? _pksEditSession;
  PksIniConfiguration? _pksIniConfiguration;
  EditingConfigurations? _editingConfigurations;
  ActionBindings? _actionBindings;
  Themes? _themes;

  set pksSysDirectory(String newDir) {
    _logger.i("Assigning new PKS_SYS directory to $newDir");
    _pksSysDirectory = newDir;
  }

  ///
  /// Get the PKS_SYS directory as configured in win.ini (on Windows Platforms).
  ///
  String? getPksSysFromWinIni() {
    if (!Platform.isWindows) {
      return null;
    }
    final winIni = File(join("c:", "windows", "win.ini"));
    if (winIni.existsSync()) {
      for (final line in winIni.readAsLinesSync()) {
        if (line.startsWith("PKS_SYS=")) {
          final result = line.substring(8).trim();
          _logger.i("PKS_SYS directory defined in $winIni to $result.");
          return result;
        }
      }
    }
    return null;
  }

  ///
  /// Returns the temporary path of PKS Edit, where temporary files like backup files
  /// or search results are saved.
  ///
  Future<String> get pksEditTempPath async {
    var p = Platform.environment["PKS_TMP"];
    if (p != null) {
      return p;
    }
    var d = await getTemporaryDirectory();
    if (!d.existsSync()) {
      d = Directory("temp");
    }
    d = Directory(join(d.absolute.path, "pksedit"));
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return d.absolute.path;
  }

  ///
  /// Get the config directory, where the PKS EDIT config files are located.
  ///
  String get pksSysDirectory {
    if (_pksSysDirectory == null) {
      var pksSys =
          Platform.environment[pksSysVariable] ?? pksSysVariable.toLowerCase();
      if (File(join(pksSys, configFilename)).existsSync()) {
        _pksSysDirectory = pksSys;
      } else {
        var systemDir = getPksSysFromWinIni();
        _pksSysDirectory = systemDir != null
            ? File(systemDir).absolute.path
            : File(pksSys).absolute.path;
      }
      _logger.i("Assuming PKS_SYS directory in $_pksSysDirectory");
    }
    return _pksSysDirectory ?? pksSysVariable;
  }

  ///
  /// Returns and reads the themes
  /// 
  Future<Themes> get themes async {
    if (_themes == null) {
      var themeFile = findFile(themeFilename);
      if (themeFile != null) {
        _logger.i("Reading theme configuration file ${themeFile.path}.");
        var string = themeFile.readAsStringSync();
        _themes = Themes.fromJson(jsonDecode(string));
      } else {
        _themes = Themes(themes: [ThemeConfiguration(name: "default")]);
      }
    }
    return _themes!;
  }

  ///
  /// Returns the current action bindings configuration.
  ///
  Future<ActionBindings> get actionBindings async {
    if (_actionBindings == null) {
      var configFile = findFile(actionBindingsFilename);
      if (configFile != null) {
        _logger.i("Reading action bindings configuration file ${configFile.path}.");
        var string = configFile.readAsStringSync();
        _actionBindings = ActionBindings.fromJson(jsonDecode(string));
      } else {
        _actionBindings = ActionBindings();
      }
    }
    return _actionBindings!;
  }


  ///
  /// Returns the current editing configuration.
  ///
  EditingConfigurations get editingConfigurations {
    if (_editingConfigurations == null) {
      var configFile = findFile(editingConfigurationFilename);
      if (configFile != null) {
        _logger.i("Reading editing configuration file ${configFile.path}.");
        var string = configFile.readAsStringSync();
        _editingConfigurations = EditingConfigurations.fromJson(jsonDecode(string));
      } else {
        _editingConfigurations = EditingConfigurations();
      }
    }
    return _editingConfigurations!;
  }


  ///
  /// Returns the current application configuration.
  ///
  Future<PksIniConfiguration> get configuration async {
    if (_pksIniConfiguration == null) {
      var configFile = findFile(configFilename);
      if (configFile != null) {
        _logger.i("Reading application configuration file ${configFile.path}.");
        var string = configFile.readAsStringSync();
        _pksIniConfiguration = PksIniConfiguration.fromJson(jsonDecode(string));
      } else {
        _pksIniConfiguration = PksIniConfiguration(configuration: ApplicationConfiguration.defaultConfiguration);
      }
    }
    return _pksIniConfiguration!;
  }

  ///
  /// Returns and optionally reads before the last saved edit session config file.
  ///
  Future<PksEditSession> get currentSession async {
    if (_pksEditSession == null) {
      var sessionFile = findFile(sessionFilename);
      if (sessionFile != null) {
        _logger.i(
            "Reading session file ${sessionFile.path} to restore last editor session.");
        var string = sessionFile.readAsStringSync();
        _pksEditSession = PksEditSession.fromJson(jsonDecode(string));
      } else {
        var bounds = await windowManager.getBounds();
        _pksEditSession = PksEditSession(
            screenWidth: bounds.width.toInt(),
            screenHeight: bounds.height.toInt(),
            searchPatterns: [],
            searchReplaceOptions: 0,
            mainWindowPlacement: MainWindowPlacement(
                left: bounds.left.toInt(),
                right: bounds.right.toInt(),
                top: bounds.top.toInt(),
                bottom: bounds.bottom.toInt()));
      }
    }
    return _pksEditSession!;
  }

  ///
  /// Save the current PKS EDIT session.
  ///
  Future<void> saveSession(PksEditSession session) async {
    var sessionFile = File(join(pksSysDirectory, sessionFilename));
    _logger.i("Saving current session in $sessionFile.");
    sessionFile.writeAsStringSync(
        const JsonEncoder.withIndent("  ").convert(session.toJson()));
  }

  ///
  /// Save the current PKS EDIT settings.
  ///
  Future<void> saveSettings(PksIniConfiguration configuration) async {
    var settingsFile = File(join(pksSysDirectory, configFilename));
    try {
      settingsFile.createSync(recursive: true);
      settingsFile.writeAsStringSync(
          const JsonEncoder.withIndent("  ").convert(configuration.toJson()));
    } catch(ex) {
      _logger.e("Cannot save settings file $settingsFile");
    }
  }

  ///
  /// Finds a file with the given [filename] in the PKS_SYS directories.
  /// If a file can be found and exists, return it, otherwise return null.
  ///
  File? findFile(String filename) {
    final f = File(join(pksSysDirectory, filename));
    return f.existsSync() ? f : null;
  }
}
