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

///
/// Represents the state of an opened editor window as read from the sessions.
///
class OpenEditorPanel {
  static final pksEditSearchListFormat = RegExp(r'"([^"]+)", line ([0-9]+): *(.*)');
  final String path;
  final int lineNumber;
  final String openHint;
  String get dockName {
    var split = openHint.split(" ");
    return split.first.trim();
  }
  ///
  /// Whether this panel had been active.
  ///
  bool get active => openHint.split(" ").contains("active");

  OpenEditorPanel({required this.path, required this.lineNumber, required this.openHint});

  String encodeJson() => "\"$path\", line: $lineNumber: $openHint";

  static OpenEditorPanel? parse(String string) {
    var match = pksEditSearchListFormat.firstMatch(string);
    if (match == null) {
      return null;
    }
    return OpenEditorPanel(path: match.group(1)!, lineNumber: int.tryParse(match.group(2)!) ?? 0, openHint: match.group(3)!);
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

  String encodeJson() {
    var map = {
      "flags": flags,
      "show": show,
      "top": top,
      "bottom": bottom,
      "left": left,
      "right": right,
    };
    return jsonEncode(map);
  }
  static MainWindowPlacement from(Map<String, dynamic> map) =>
      MainWindowPlacement(flags: map["flags"], show: map["show"], top: map["top"], bottom: map["bottom"], right: map["right"]);
}

///
/// Describes on main frame docking area.
///
class MainFrameDock {
  final String name;
  final double x;
  final double y;
  final double w;
  final double h;
  MainFrameDock({required this.name, required this.x, required this.y, required this.w, required this.h});

  static MainFrameDock? from(Map<String, dynamic> map) {
    if (map case {
        'name': String name,
        'x': double x,
        'y': double y,
        'w': double w,
        'h': double h,
      }) {
      return MainFrameDock(name: name, x: x, y: y, w: w, h: h);
    }
    return null;
  }
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
  final List<OpenEditorPanel> openEditors;
  final MainWindowPlacement mainWindowPlacement;
  final Map<String, MainFrameDock> docks;
  PksEditSession({
    required this.screenWidth,
    required this.screenHeight,
    required this.searchPatterns,
    required this.searchReplaceOptions,
    required this.mainWindowPlacement,
    this.docks = const{},
    this.openFiles = const[],
    this.openEditors = const []});

  String encodeJson() {
    var map = <String, dynamic>{
      "search-replace-options": searchReplaceOptions,
      "open-files": openFiles,
      "open-editors": openEditors.map((e) => e.encodeJson).toList(),
      "screen-width": screenWidth,
      "main-window-placement": mainWindowPlacement.encodeJson(),
      "screen-height": screenHeight
    };
    return jsonEncode(map);
  }
  static PksEditSession from(Map<String,dynamic> jsonInput) {
    final h = jsonInput["screen-height"];
    final w = jsonInput["screen-width"];
    final options = jsonInput["search-replace-options"];
    final openFiles = jsonInput["open-files"];
    final searchPatterns = jsonInput["search-patterns"];
    final openEditors = jsonInput["open-editors"];
    final mainWindowPlacement = jsonInput["main-window-placement"];
    final docks = <String,MainFrameDock>{};
    for (int i = 1; i < 3; i++) {
      var dock = jsonInput["dock$i"];
      if (dock is Map) {
        var mainFrameDock = MainFrameDock.from(Map<String,dynamic>.from(dock));
        if (mainFrameDock != null) {
          docks["dock$i"] = mainFrameDock;
        }
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
        openEditors: openEditors is List<dynamic> ?
          openEditors.map((s) => OpenEditorPanel.parse(s.toString())).whereType<OpenEditorPanel>().toList() : const[]);
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
