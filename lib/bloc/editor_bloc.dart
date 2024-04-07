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

import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:path/path.dart';
import 'package:pks_edit_flutter/bloc/bloc_provider.dart';
import 'package:pks_edit_flutter/bloc/templates.dart';
import 'package:pks_edit_flutter/model/languages.dart';
import 'package:rxdart/rxdart.dart';

///
/// Represents the model of all files currently opened in PKS-Edit.
///
class OpenFileState {
  final List<OpenFile> files;
  late final StreamController<OpenFile?> _controller;
  Stream<OpenFile?> get currentFile => _controller.stream;
  int _currentIndex;
  int get currentIndex => _currentIndex;
  OpenFile? get _currentFile => currentIndex < 0 || files.length <= currentIndex ? null : files[currentIndex];
  set currentIndex(int idx) {
    if (_currentIndex == idx) {
      return;
    }
    _currentIndex = idx;
    _controller.add(_currentFile);
  }
  OpenFileState({required this.files, required int currentIndex}) :
    _currentIndex = currentIndex,
    _controller = BehaviorSubject.seeded(currentIndex < 0 || files.length <= currentIndex ? null : files[currentIndex])
  ;
}

///
/// Represents one open file.
///
class OpenFile {
  final String filename;
  final String text;
  final Encoding encoding;
  bool isNew;
  bool modified;
  late final CodeController controller;
  String get title {
    var name = basename(filename);
    return modified ? "* $name" : name;
  }
  late final Language language;
  void Function(OpenFile file)? _changedListener;

  void _updateModified(bool newModified) {
    var oldModified = modified;
    modified = newModified;
    if (_changedListener != null && oldModified != newModified) {
      _changedListener!(this);
    }
  }

  void _changed() {
    if (!modified && controller.text != text) {
      _updateModified(true);
    }
  }

  OpenFile({required this.filename, required this.text, this.modified = false, this.encoding = utf8, required this.isNew}) {
    language = Languages.singleton.modeForFilename(filename);
    controller = CodeController(text: text, language: language.mode);
  }

  ///
  /// Add a listener to be invoked, when the file changes.
  ///
  void addChangeListener(void Function(OpenFile file) listener) {
    _changedListener = listener;
    controller.addListener(_changed);
  }

  ///
  /// Remove the change listener. Must be called, when the OpenFile element is disposed.
  ///
  void removeChangeListener() {
    controller.removeListener(_changed);
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
  final OpenFileState _openFileState = OpenFileState(files: [], currentIndex: -1);
  final StreamController<OpenFileState> _openFileSubject = BehaviorSubject.seeded(OpenFileState(files: const [], currentIndex: -1));
  Stream<OpenFileState> get openFileStream => _openFileSubject.stream;

  void _refreshFiles() {
    _openFileSubject.add(_openFileState);
  }

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

  ///
  /// Initializes the BLOC interpreting the command line arguments.
  ///
  Future<void> initialize({required List<String> arguments}) async {
    for (var arg in arguments) {
      if (!arg.startsWith("-")) {
        await openFile(arg);
      }
    }
    await newFile("Test.java");
    await newFile("Test.dart");
  }

  Future<void> dispose() async {
    _openFileSubject.close();
  }
}
