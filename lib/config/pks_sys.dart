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

import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:pks_edit_flutter/config/pks_ini.dart';
import 'package:window_manager/window_manager.dart';

class OpenEditor {
  static final pksEditSearchListFormat = RegExp(r'"([^"]+)", line ([0-9]+): *(.*)');
  final String path;
  final int lineNumber;
  final String openHint;

  OpenEditor({required this.path, required this.lineNumber, required this.openHint});

  static OpenEditor? parse(String string) {
    var match = pksEditSearchListFormat.firstMatch(string);
    if (match == null) {
      return null;
    }
    return OpenEditor(path: match.group(1)!, lineNumber: int.tryParse(match.group(2)!) ?? 0, openHint: match.group(3)!);
  }
}

///
/// Captures the previous saved state of the main window.
///
class MainWindowPlacement {
  static const swShowMaximized = 3;
  final int flags;
  final int show;
  final int top;
  final int bottom;
  final int left;
  final int right;
  MainWindowPlacement({this.flags = 0, this.show = 1, this.top = 0, this.left = 0, this.right = 1000, this.bottom = 1000});

  static MainWindowPlacement from(Map<String, dynamic> map) =>
      MainWindowPlacement(flags: map["flags"], show: map["show"], top: map["top"], bottom: map["bottom"], right: map["right"]);
}

///
/// Represents the last store PksEditSession.
///
class PksEditSession {
  final int screenWidth;
  final int screenHeight;
  final int searchReplaceOptions;
  final List<String> openFiles;
  final List<String> searchPatterns;
  final List<OpenEditor> openEditors;
  final MainWindowPlacement mainWindowPlacement;
  /// Not yet supported in Flutter version: window "Docks".
  final Map<String, Map<String,dynamic>> docks;
  PksEditSession({
    required this.screenWidth,
    required this.screenHeight,
    required this.searchPatterns,
    required this.searchReplaceOptions,
    required this.mainWindowPlacement,
    this.docks = const{},
    this.openFiles = const[],
    this.openEditors = const []});

  static PksEditSession from(Map<String,dynamic> jsonInput) {
    final h = jsonInput["screen-height"];
    final w = jsonInput["screen-width"];
    final options = jsonInput["search-replace-options"];
    final openFiles = jsonInput["open-files"];
    final searchPatterns = jsonInput["search-patterns"];
    final openEditors = jsonInput["open-editors"];
    final mainWindowPlacement = jsonInput["main-window-placement"];
    final docks = <String,Map<String,dynamic>>{};
    for (int i = 1; i < 10; i++) {
      var dock = jsonInput["dock$i"];
      if (dock is Map) {
        docks["dock$i"] = Map<String,dynamic>.from(dock);
      } else {
        break;
      }
    }
    return PksEditSession(
        screenHeight: h is int ? h : 1200,
        screenWidth: w is int ? w : 1960,
        searchReplaceOptions: options ?? 0,
        docks: docks,
        mainWindowPlacement: mainWindowPlacement is Map<String,dynamic> ? MainWindowPlacement.from(mainWindowPlacement) : MainWindowPlacement(),
        openFiles: openFiles is List ? List<String>.from(openFiles) : const[],
        searchPatterns: searchPatterns is List ? List<String>.from(searchPatterns) : const[],
        openEditors: openEditors is List ?
          openEditors.map((e) => OpenEditor.parse(e)).whereType<OpenEditor>().toList() : const[]);
  }
}

class PksConfiguration {
  PksConfiguration._();
  static const sessionFilename = "pkssession.json";
  static const defaultConfigFilename = "pkseditini.json";
  static const pksSysVariable = "PKS_SYS";
  static PksConfiguration singleton = PksConfiguration._();
  final Logger _logger = Logger(printer: SimplePrinter(printTime: true, colors: false));
  String? _pksSysDirectory;
  PksEditSession? _pksEditSession;
  EditorConfiguration? _editorConfiguration;

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
      var pksSys = Platform.environment[pksSysVariable] ?? pksSysVariable.toLowerCase();
      if (File(join(pksSys, defaultConfigFilename)).existsSync()) {
        _pksSysDirectory = pksSys;
      } else {
        var systemDir = getPksSysFromWinIni();
        _pksSysDirectory = systemDir != null ? File(systemDir).absolute.path : File(pksSys).absolute.path;
      }
      _logger.i("Assuming PKS_SYS directory in $_pksSysDirectory");
    }
    return _pksSysDirectory ?? pksSysVariable;
  }

  ///
  /// Returns the current editor configuration.
  ///
  Future<EditorConfiguration> get configuration async {
    if (_editorConfiguration == null) {
      var sessionFile = File(join(pksSysDirectory, defaultConfigFilename));
      if (sessionFile.existsSync()) {
        _logger.i("Reading configuration file ${sessionFile.path}.");
        var string = sessionFile.readAsStringSync();
        _editorConfiguration = EditorConfiguration.from(jsonDecode(string));
      } else {
        _editorConfiguration = EditorConfiguration.defaultConfiguration;
      }
    }
    return _editorConfiguration!;
  }

  ///
  /// Returns and optionally reads before the last saved edit session config file.
  ///
  Future<PksEditSession> get currentSession async {
    if (_pksEditSession == null) {
      var sessionFile = File(join(pksSysDirectory, sessionFilename));
      if (sessionFile.existsSync()) {
        _logger.i("Reading session file ${sessionFile.path} to restore last setting.");
        var string = sessionFile.readAsStringSync();
        _pksEditSession = PksEditSession.from(jsonDecode(string));
      } else {
        var bounds = await windowManager.getBounds();
        _pksEditSession = PksEditSession(screenWidth: bounds.width.toInt(), screenHeight: bounds.height.toInt(),
            searchPatterns: [], searchReplaceOptions: 0,
            mainWindowPlacement: MainWindowPlacement(left: bounds.left.toInt(), right: bounds.right.toInt(), top: bounds.top.toInt(), bottom: bounds.bottom.toInt()));
      }
    }
    return _pksEditSession!;
  }


}
