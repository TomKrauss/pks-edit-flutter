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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:pks_edit_flutter/bloc/bloc_provider.dart';
import 'package:pks_edit_flutter/bloc/templates.dart';
import 'package:pks_edit_flutter/config/editing_configuration.dart';
import 'package:pks_edit_flutter/config/pks_ini.dart';
import 'package:pks_edit_flutter/config/pks_sys.dart';
import 'package:pks_edit_flutter/config/theme_configuration.dart';
import 'package:pks_edit_flutter/model/languages.dart';
import 'package:pks_edit_flutter/util/file_stat_extension.dart';
import 'package:re_editor/re_editor.dart';
import 'package:rxdart/rxdart.dart';
import 'package:window_manager/window_manager.dart';

///
/// Represents the model of all files currently opened in PKS-Edit.
///
class OpenFileState {
  final List<OpenFile> files;
  OpenFile? get currentFile => _currentFile;
  int _currentIndex;
  int get currentIndex => _currentIndex;
  final void Function()? _currentChanged;
  OpenFile? get _currentFile => currentIndex < 0 || files.length <= currentIndex ? null : files[currentIndex];
  set currentFile(OpenFile? file) => currentIndex = file == null ? -1 : files.indexOf(file);
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

class FileIcons {
  static FileIcons singleton = FileIcons._();
  final Map<String,IconData> _iconsByExtension = {
    "txt": FontAwesomeIcons.fileLines,
    "md": FontAwesomeIcons.markdown,
    "pdf": FontAwesomeIcons.filePdf,
    "html": FontAwesomeIcons.html5,
    "doc": FontAwesomeIcons.fileWord,
    "docx": FontAwesomeIcons.fileWord,
    "py": FontAwesomeIcons.python,
    "pas": FontAwesomeIcons.fileCode,
    "cpp": FontAwesomeIcons.c,
    "c": FontAwesomeIcons.c,
    "gradle": FontAwesomeIcons.fileCode,
    "groovy": FontAwesomeIcons.fileCode,
    "dart": FontAwesomeIcons.fileCode,
    "java": FontAwesomeIcons.java,
    "csv": FontAwesomeIcons.fileCsv,
    "js": FontAwesomeIcons.squareJs,
    "json": FontAwesomeIcons.fileImport,
    "css": FontAwesomeIcons.css3
  };
  FileIcons._();

  IconData getIcon(String filename) {
    var ext = path.extension(filename);
    if (ext.startsWith(".")) {
      ext = ext.substring(1);
    }
    return _iconsByExtension[ext] ?? FontAwesomeIcons.file;
  }
}

///
/// Represents one open file.
///
class OpenFile {
  static const String dockNameDefault = "default";
  static const String dockNameRight = "rightSlot";
  static const String dockNameBottom = "bottomSlot";
  ///
  /// The absolute path name of the file edited.
  ///
  String filename;
  ///
  /// The initial contents of the file to edit.
  ///
  final String text;
  ///
  /// The "dock", where this file is placed.
  ///
  final String dock;
  ///
  /// The character encoding.
  ///
  final Encoding encoding;

  ///
  /// The icon to represent this file.
  ///
  IconData get icon => FileIcons.singleton.getIcon(filename);

  ///
  /// Whether this is a new file.
  ///
  bool isNew;
  ///
  /// Whether the file was edited by the user but not yet saved.
  ///
  bool modified;

  bool readOnly;

  ///
  /// Internal flag, if the caret must be repositioned asynchronously
  ///
  bool needsCaretAdjustment = false;
  ///
  /// The controller for performing the editing operations on the file.
  ///
  late final CodeLineEditingController controller;

  ///
  /// The controller for executing find and replace operations.
  ///
  late final CodeFindController findController;

  EditingConfiguration editingConfiguration;

  String get title {
    var name = path.basename(filename);
    return modified ? "* $name" : name;
  }
  late final Language language;

  late String _lastSavedText;
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
      needsCaretAdjustment = true;
    }
  }

  ///
  /// Must be invoked, if the caret was moved, but not yet made visible.
  ///
  void adjustCaret() {
    if (needsCaretAdjustment) {
      needsCaretAdjustment = false;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        controller.makeCursorCenterIfInvisible();
      });
    }
  }

  OpenFile({required this.filename, required this.text, this.dock = dockNameDefault,
    required this.editingConfiguration,
    this.readOnly = false,
    this.modified = false, this.encoding = utf8, required this.isNew, int? initialLineNumber}) {
    language = Languages.singleton.modeForFilename(filename);
    _lastSavedText = text;
    controller = CodeLineEditingController.fromText(text, CodeLineOptions(indentSize: editingConfiguration.tabSize));
    if (initialLineNumber != null) {
      controller.selection = CodeLineSelection.fromPosition(position: CodeLinePosition(index: initialLineNumber, offset: 0));
    }
    findController = CodeFindController(controller, const CodeFindValue(option: CodeFindOption(pattern: "", caseSensitive: true, regex: false),
        searching: true,
        replaceMode: false));
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
  final Logger _logger = Logger(printer: SimplePrinter(printTime: true, colors: false));
  late final OpenFileState _openFileState;
  final StreamController<PksIniConfiguration> _pksIniStreamController = BehaviorSubject();
  Stream<PksIniConfiguration> get pksIniStream => _pksIniStreamController.stream;
  late final EditingConfigurations editingConfigurations;
  late final Themes themes;
  final StreamController<OpenFileState> _openFileSubject = BehaviorSubject.seeded(OpenFileState(files: const [], currentIndex: -1));
  Stream<OpenFileState> get openFileStream => _openFileSubject.stream;
  final List<String> openFiles = [];

  void _refreshFiles() {
    _openFileSubject.add(_openFileState);
  }

  ///
  /// Can be used to "cycle" through the list of open windows. If [delta] is positive we cycle
  /// forward, otherwise backward.
  ///
  void cycleWindow(int delta) {
    var newIdx = _openFileState.currentIndex + delta;
    if (newIdx < 0) {
      newIdx = _openFileState.files.length-1;
    } else if (newIdx >= _openFileState.files.length)  {
      newIdx = 0;
    }
    _openFileState.currentIndex = newIdx;
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
  /// Suggest a new file name given an existing [filename].
  /// The filename is returned including the complete path.
  ///
  String suggestNewFilename(String? filename) {
    final String extension = filename != null ? path.extension(filename) : ".txt";
    final String dir = filename != null ? path.dirname(filename) : ".";
    return path.absolute(dir, "newfile$extension");
  }

  ///
  /// Save the current active file. If a [filename] is passed, use
  /// it rather than the original file name.
  ///
  Future<CommandResult> saveActiveFile({String? filename}) async {
    final f = _openFileState._currentFile;
    if (f == null) {
      return CommandResult(success: true, message: "No current file");
    }
    if (filename != null) {
      f.filename = filename;
    }
    var result = await _saveFile(f);
    if (filename != null) {
      _refreshFiles();
    }
    return result;
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
    openFile.addChangeListener((OpenFile file) {
      _refreshFiles();
    });
  }

  ///
  /// Create a new file with the given  [filename]. If that is specified using a relative
  /// name convert it relative to the "current directory" to an absolute filename.
  ///
  Future<CommandResult> newFile(String filename, {bool insertTemplate = true}) async {
    filename = _makeAbsolute(filename);
    if (_selectFile(filename)) {
      return CommandResult(success: true, message: "File with the given name was open already.");
    }
    if (File(filename).existsSync()) {
      return await openFile(filename);
    }
    _addOpenFile(OpenFile(filename: filename, isNew: true,
        editingConfiguration: await editingConfigurations.forFile(filename),
        text: insertTemplate ? Templates.singleton.generateInitialContent(filename) : ""));
    return CommandResult(success: true);
  }

  Encoding _parseBytesToDetectEncoding(List<int> pData) {
    var i = 0;
    final end = pData.length;
    int nLength;
    while (i < end) {
      int byte = pData[i++];
      if (byte <= 0x7F || i >= end) {
        /* 1 byte sequence: U+0000..U+007F */
        continue;
      }
      if (0xC2 <= byte && byte <= 0xDF) {
        nLength = 1;
      } else if (0xE0 <= byte && byte <= 0xEF) {
        nLength = 2;
      } else if (0xF0 <= byte && byte <= 0xF4) {
        nLength = 3;
      } else {
        continue;
      }
      if (i + nLength >= end) {
        /* truncated string or invalid byte sequence */
        return latin1;
      }

      /* Check continuation bytes: bit 7 should be set, bit 6 should be unset (b10xxxxxx). */
      for (i = 0; i < nLength; i++) {
        if ((pData[i] & 0xC0) != 0x80) {
          return latin1;
        }
        if (nLength == 1) {
          return utf8;
        } else if (nLength == 2) {
          /* 3 bytes sequence: U+0800..U+FFFF */
          int ch = ((pData[0] & 0x0f) << 12) + ((pData[1] & 0x3f) << 6) +
              (pData[2] & 0x3f);
          /* (0xff & 0x0f) << 12 | (0xff & 0x3f) << 6 | (0xff & 0x3f) = 0xffff, so ch <= 0xffff */
          if (ch < 0x0800) {
            return latin1;
          }
          /* surrogates (U+D800-U+DFFF) are invalid in UTF-8: test if (0xD800 <= ch && ch <= 0xDFFF) */
          if ((ch >> 11) == 0x1b) {
            return latin1;
          }
          return utf8;
        } else if (nLength == 3) {
          /* 4 bytes sequence: U+10000..U+10FFFF */
          int ch = ((pData[0] & 0x07) << 18) + ((pData[1] & 0x3f) << 12) +
              ((pData[2] & 0x3f) << 6) + (pData[3] & 0x3f);
          if ((ch < 0x10000) || (0x10FFFF < ch)) {
            return latin1;
          }
          return utf8;
        }
        i += nLength;
      }
    }
    return latin1;
  }


  Future<Encoding> _detectEncoding(File file) async {
    final size = min(4096, await file.length());
    final tester = file.openRead(0, size);
    return _parseBytesToDetectEncoding(await tester.first);
  }

  ///
  /// Open a file with the given [filename]. If a [dock] is passed, the file is opened
  /// in the corresponding dock on the screen otherwise on the default dock.
  ///
  Future<CommandResult> openFile(String filename, {String? dock, int? lineNumber}) async {
    filename = _makeAbsolute(filename);
    if (_selectFile(filename)) {
      return CommandResult(success: true, message: "File with the given name was open already.");
    }
    try {
      final ec = await editingConfigurations.forFile(filename);
      final file = File.fromUri(
          Uri.file(filename, windows: Platform.isWindows));
      final readOnly = file.statSync().readOnly;
      Encoding encoding = await _detectEncoding(file);
      String? text = file.readAsStringSync(encoding: encoding);
      openFiles.remove(filename);
      openFiles.insert(0, filename);
      if (openFiles.length > 10) {
        openFiles.removeRange(10, openFiles.length);
      }
      _addOpenFile(OpenFile(
          readOnly: readOnly,
          editingConfiguration: ec,
          filename: filename, isNew: false, text: text, encoding: encoding,
          initialLineNumber: lineNumber,
          dock: dock ?? OpenFile.dockNameDefault));
      _logger.i("Opened file $filename");
    } catch(ex) {
      _logger.e("Failure opening file $filename: $ex");
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
    } else {
      _refreshFiles();
    }
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
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.focus();
      await windowManager.show();
    });
    if (p.show == MainWindowPlacement.swShowMaximized) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        windowManager.maximize();
      });
    }
  }

  void updateConfiguration(PksIniConfiguration configuration) {
    themes.selectTheme(configuration.configuration.theme);
    _pksIniStreamController.add(configuration);
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
    themes = await PksConfiguration.singleton.themes;
    editingConfigurations = await PksConfiguration.singleton.editingConfigurations;
    final pksIniConfiguration = await PksConfiguration.singleton.configuration;
    final applicationConfiguration = pksIniConfiguration.configuration;
    int? active;
    int idx = 0;
    if (applicationConfiguration.preserveHistory) {
      _logger.i("Restoring file from previous session...");
      for (var f in session.openEditors) {
        if (f.active) {
          active = idx;
        }
        idx++;
        await openFile(f.path, dock: f.dock,
            lineNumber: f.lineNumber < 0 ? null : f.lineNumber);
      }
      if (active != null) {
        _openFileState.currentIndex = active;
      }
    }
    openFiles.addAll(session.openFiles);
    updateConfiguration(pksIniConfiguration);
    await initWindowOptions(session);
  }

  Future<void> dispose() async {
    _openFileSubject.close();
  }

  ///
  /// Save the current PKS EDIT session.
  ///
  Future<void> _saveSession(BuildContext context) async {
    var current = await PksConfiguration.singleton.currentSession;
    if (!context.mounted) {
      _logger.e("Cannot save session. Context not mounted any more.");
      return;
    }
    final session = await current.prepareSave(context: context, state: _openFileState);
    _logger.e("Saving current session.");
    PksConfiguration.singleton.saveSession(session);
  }

  ///
  /// Exit the PKS EDIT application saving the current session before.
  ///
  Future<void> exitApp(BuildContext context) async {
    await _saveSession(context);
    windowManager.destroy();
  }
}
