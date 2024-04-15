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
      RegExp(r'"([^"]+)", line ([0-9]+): *(.*)');
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

  String encodeJson() => "\"$path\", line $lineNumber: $dock ${active ? 'active': '-'} ${focus ? 'focus': '-'} ${cloned ? 'cloned': '-'} ${displayMode.toRadixString(16)}";

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
/// Represents the last store PksEditSession.
///
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class PksEditSession {
  @JsonKey(name: "screen-width")
  final int screenWidth;
  @JsonKey(name: "screen-height")
  final int screenHeight;
  @JsonKey(name: "search-replace-options")
  final int searchReplaceOptions;
  @JsonKey(name: "open-files")
  final List<String> openFiles;
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
      this.openEditors = const []}) :
      openFiles = openFiles ?? [],
      searchPatterns = searchPatterns ?? [],
      replacePatterns = replacePatterns ?? [],
      filePatterns = filePatterns ?? [];

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
    var view = View.of(context);
    var bounds = await windowManager.getBounds();
    return PksEditSession(
        screenWidth: view.physicalSize.width.toInt(),
        screenHeight: view.physicalSize.height.toInt(),
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
        openFiles: openFiles,
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

class PksConfiguration {
  PksConfiguration._();
  static const sessionFilename = "pkssession.json";
  static const configFilename = "pkseditini.json";
  static const themeFilename = "themeconfig.json";
  static const editingConfigurationFilename = "pkseditconfig.json";
  static const actionBindingsFilename = "pksactionbindings.json";
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
      var themeFile = File(join(pksSysDirectory, themeFilename));
      if (themeFile.existsSync()) {
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
      var configFile = File(join(pksSysDirectory, actionBindingsFilename));
      if (configFile.existsSync()) {
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
  Future<EditingConfigurations> get editingConfigurations async {
    if (_editingConfigurations == null) {
      var configFile = File(join(pksSysDirectory, editingConfigurationFilename));
      if (configFile.existsSync()) {
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
      var configFile = File(join(pksSysDirectory, configFilename));
      if (configFile.existsSync()) {
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
      var sessionFile = File(join(pksSysDirectory, sessionFilename));
      if (sessionFile.existsSync()) {
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
    sessionFile.writeAsStringSync(
        const JsonEncoder.withIndent("  ").convert(session.toJson()));
  }

  ///
  /// Save the current PKS EDIT settings.
  ///
  Future<void> saveSettings(PksIniConfiguration configuration) async {
    var settingsFile = File(join(pksSysDirectory, configFilename));
    settingsFile.writeAsStringSync(
        const JsonEncoder.withIndent("  ").convert(configuration.toJson()));
  }
}
