//
// editor_bloc.dart
//
// PKS-EDIT - Flutter
//
// Last modified: 07.04.24, 08:07
// Author: Tom Krauß
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:pks_edit_flutter/bloc/bloc_provider.dart';
import 'package:pks_edit_flutter/bloc/templates.dart';
import 'package:pks_edit_flutter/config/pks_ini.dart';
import 'package:pks_edit_flutter/config/pks_sys.dart';
import 'package:pks_edit_flutter/model/languages.dart';
import 'package:re_editor/re_editor.dart';
import 'package:rxdart/rxdart.dart';
import 'package:window_manager/window_manager.dart';

///
/// Represents the model of all files currently opened in PKS-Edit.
///
class OpenFileState {
  final List<OpenFile> files;
  OpenFile? get currentFileSync => _currentFile;
  int _currentIndex;
  int get currentIndex => _currentIndex;
  final void Function()? _currentChanged;
  OpenFile? get _currentFile => currentIndex < 0 || files.length <= currentIndex ? null : files[currentIndex];
  set currentIndex(int idx) {
    if (_currentIndex == idx) {
      return;
    }
    _currentIndex = idx;
    if (_currentChanged != null) {
      _currentChanged();
    }
  }
  OpenFileState({required this.files, required int currentIndex, void Function()? currentChanged}) :
    _currentIndex = currentIndex,
    _currentChanged = currentChanged
  ;
}

///
/// Represents one open file.
///
class OpenFile {
  final String filename;
  final String text;
  late String _lastSavedText;
  final Encoding encoding;
  bool isNew;
  bool modified;
  late final CodeLineEditingController controller;
  String get title {
    var name = basename(filename);
    return modified ? "* $name" : name;
  }
  late final Language language;
  void Function(OpenFile file)? _changedListener;

  void saved() {
    _lastSavedText = controller.text;
    _updateModified(false);
  }

  void onChanged(CodeLineEditingValue value) {
    if (controller.codeLines.equals(controller.preValue?.codeLines)) {
      return;
    }
    _updateModified(controller.text != _lastSavedText);
  }

  void _updateModified(bool newModified) {
    var oldModified = modified;
    modified = newModified;
    if (_changedListener != null && oldModified != newModified) {
      _changedListener!(this);
    }
  }

  OpenFile({required this.filename, required this.text, this.modified = false, this.encoding = utf8, required this.isNew}) {
    language = Languages.singleton.modeForFilename(filename);
    _lastSavedText = text;
    controller = CodeLineEditingController.fromText(text);
  }

  ///
  /// Add a listener to be invoked, when the file changes.
  ///
  void addChangeListener(void Function(OpenFile file) listener) {
    _changedListener = listener;
  }

  ///
  /// Remove the change listener. Must be called, when the OpenFile element is disposed.
  ///
  void removeChangeListener() {
    _changedListener = null;
  }
}

///
/// Result of executing a BLOC command.
///
class CommandResult {
  final bool success;
  final String? message;
  CommandResult({required this.success, this.message});
}

///
/// Implements the commands for PKS EDIT.
///
class EditorBloc {
  static EditorBloc of(BuildContext context) => SimpleBlocProvider.of(context);
  late final OpenFileState _openFileState;
  late final EditorConfiguration editorConfiguration;
  final StreamController<OpenFileState> _openFileSubject = BehaviorSubject.seeded(OpenFileState(files: const [], currentIndex: -1));
  Stream<OpenFileState> get openFileStream => _openFileSubject.stream;
  final List<String> openFiles = [];

  void _refreshFiles() {
    _openFileSubject.add(_openFileState);
  }

  ///
  /// Whether there are any editor windows open, which are currently in the state modified.
  ///
  bool get hasChangedWindows => _openFileState.files.where((element) => element.modified).isNotEmpty;

  ///
  /// Try to select (make current) the file with the given absolute [filename].
  /// If we have an open file with the given file name already it is made the current
  /// file and this method returns true.
  ///
  bool _selectFile(String filename) {
    final index = _openFileState.files.indexWhere((element) => element.filename == filename);
    if (index >= 0) {
      _openFileState.currentIndex = index;
      _refreshFiles();
      return true;
    }
    return false;
  }

  ///
  /// Convert a filename into an absolute filename.
  ///
  String _makeAbsolute(String filename) {
    final f = File(filename);
    return f.absolute.path;
  }

  Future<CommandResult> _saveFile(OpenFile fileHandle) async {
    try {
      final file = File(fileHandle.filename);
      file.writeAsStringSync(fileHandle.controller.text, encoding: fileHandle.encoding);
      fileHandle.saved();
      return CommandResult(success: true, message: "Successfully saved ${fileHandle.filename}");
    } catch(ex) {
      return CommandResult(success: false, message: ex.toString());
    }
  }

  ///
  /// Save the current active file.
  ///
  Future<CommandResult> saveActiveFile() async {
    final f = _openFileState._currentFile;
    if (f == null) {
      return CommandResult(success: true, message: "No current file");
    }
    return await _saveFile(f);
  }

  ///
  /// Save all modified files.
  ///
  Future<CommandResult> saveAllModified() async {
    int nSaved = 0;
    for (var handle in _openFileState.files) {
      if (handle.modified) {
        var result = await _saveFile(handle);
        if (!result.success) {
          return result;
        }
        nSaved++;
      }
    }
    return CommandResult(success: true, message: "Succesfully saved $nSaved files.");
  }

  ///
  /// Add an open file to the list of open files.
  ///
  void _addOpenFile(OpenFile openFile) {
    _openFileState.files.add(openFile);
    _openFileState.currentIndex = _openFileState.files.length-1;
    _refreshFiles();
    openFile.addChangeListener((OpenFile file) {
      _refreshFiles();
    });
  }

  ///
  /// Create a new file with the given  [filename]. If that is specified using a relative
  /// name convert it relative to the "current directory" to an absolute filename.
  ///
  Future<CommandResult> newFile(String filename) async {
    filename = _makeAbsolute(filename);
    if (_selectFile(filename)) {
      return CommandResult(success: true, message: "File with the given name was open already.");
    }
    if (File(filename).existsSync()) {
      return await openFile(filename);
    }
    _addOpenFile(OpenFile(filename: filename, isNew: true, text: Templates.singleton.generateInitialContent(filename)));
    return CommandResult(success: true);
  }

  ///
  /// Open a file with the given [filename]. If a
  Future<CommandResult> openFile(String filename) async {
    filename = _makeAbsolute(filename);
    if (_selectFile(filename)) {
      return CommandResult(success: true, message: "File with the given name was open already.");
    }
    try {
      final file = File.fromUri(
          Uri.file(filename, windows: Platform.isWindows));
      Encoding encoding = utf8;
      String? text;
      try {
        text = file.readAsStringSync();
      } catch (ex) {
        // TODO: add encoding detection
        encoding = latin1;
        text = file.readAsStringSync(encoding: encoding);
      }
      _addOpenFile(OpenFile(
          filename: filename, isNew: false, text: text, encoding: encoding));
    } catch(ex) {
      return CommandResult(success: false, message: ex.toString());
    }
    return CommandResult(success: true);
  }

  ///
  /// Open a file with the given file name. If a physical file with [filename]
  /// exists, open it, otherwise create a new file with the name.
  ///
  Future<void> tryOpenFile(String filename) async {
    if (File(filename).existsSync()) {
      await openFile(filename);
    } else {
      await newFile(filename);
    }
  }

  ///
  /// Closes a file.
  ///
  Future<void> closeFile(OpenFile file) async {
    if (!_openFileState.files.remove(file)) {
      return;
    }
    file.removeChangeListener();
    if (_openFileState.currentIndex >= _openFileState.files.length) {
      _openFileState.currentIndex = _openFileState.files.length-1;
    }
    _refreshFiles();
  }

  Future<void> initWindowOptions(PksEditSession session) async {
    final p = session.mainWindowPlacement;
  // First get the FlutterView.
    FlutterView view = WidgetsBinding.instance.platformDispatcher.views.first;
  // Dimensions in physical pixels (px)
    Size screenSize = view.physicalSize;
    var width = session.screenWidth;
    var height = session.screenWidth;
    var wFactor = screenSize.width / max(1, width);
    var hFactor = screenSize.height / max(1, height);
    var size = Size((p.right-p.left)*wFactor, (p.bottom-p.top)*hFactor);
    WindowOptions windowOptions = WindowOptions(
        size: p.show == MainWindowPlacement.swShowMaximized ? null : size,
        minimumSize: p.show == MainWindowPlacement.swShowMaximized ? null : size,
        skipTaskbar: false,
        fullScreen: null);
    if (p.show == MainWindowPlacement.swShowMaximized) {
      WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
        windowManager.maximize();
      });
    } else {
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.focus();
        await windowManager.show();
      });
    }
  }

  ///
  /// Initializes the BLOC interpreting the command line arguments.
  ///
  Future<void> initialize({required List<String> arguments}) async {
    _openFileState = OpenFileState(files: [], currentIndex: -1, currentChanged: _refreshFiles);
    for (var arg in arguments) {
      if (!arg.startsWith("-")) {
        await openFile(arg);
      } else {
        if (arg.startsWith("-pks_sys:")) {
          PksConfiguration.singleton.pksSysDirectory = arg.substring(9);
        }
      }
    }
    var session = await PksConfiguration.singleton.currentSession;
    editorConfiguration = await PksConfiguration.singleton.configuration;
    await initWindowOptions(session);
    for (var f in session.openEditors) {
      await openFile(f.path);
    }
    openFiles.addAll(session.openFiles);
  }

  Future<void> dispose() async {
    _openFileSubject.close();
  }
}
