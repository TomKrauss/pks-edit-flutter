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
/// Represents the last store PksEditSession.
///
class PksEditSession {
  final int screenWidth;
  final int screenHeight;
  final List<String> openFiles;
  final List<OpenEditor> openEditors;
  PksEditSession({required this.screenWidth, required this.screenHeight, this.openFiles = const[], this.openEditors = const []});

  static PksEditSession from(Map<String,dynamic> jsonInput) {
    final h = jsonInput["screen-height"];
    final w = jsonInput["screen-width"];
    final openFiles = jsonInput["open-files"];
    final openEditors = jsonInput["open-editors"];
    return PksEditSession(screenHeight: h is int ? h : 1200, screenWidth: w is int ? w : 1960,
      openFiles: openFiles is List ? List<String>.from(openFiles) : const[], openEditors: openEditors is List ?
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

  set pksSysDirectory(String newDir) {
    _logger.i("Assigning new PKS_SYS directory to $newDir");
    _pksSysDirectory = newDir;
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
        _pksSysDirectory = File(pksSys).absolute.path;
      }
      _logger.i("Assuming PKS_SYS directory in $_pksSysDirectory");
    }
    return _pksSysDirectory ?? pksSysVariable;
  }

  ///
  /// Returns and optionally reads before the last saved edit session config file.
  ///
  PksEditSession get currentSession {
    if (_pksEditSession == null) {
      var sessionFile = File(join(pksSysDirectory, sessionFilename));
      if (sessionFile.existsSync()) {
        _logger.i("Reading session file ${sessionFile.path} to restore last setting.");
        var string = sessionFile.readAsStringSync();
        _pksEditSession = PksEditSession.from(jsonDecode(string));
      } else {
        _pksEditSession = PksEditSession(screenWidth: 1960, screenHeight: 1200);
      }
    }
    return _pksEditSession!;
  }


}
