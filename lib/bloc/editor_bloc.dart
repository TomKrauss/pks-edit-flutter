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
import 'package:pks_edit_flutter/actions/action_bindings.dart';
import 'package:pks_edit_flutter/bloc/bloc_provider.dart';
import 'package:pks_edit_flutter/bloc/templates.dart';
import 'package:pks_edit_flutter/config/editing_configuration.dart';
import 'package:pks_edit_flutter/config/pks_ini.dart';
import 'package:pks_edit_flutter/config/pks_sys.dart';
import 'package:pks_edit_flutter/config/theme_configuration.dart';
import 'package:pks_edit_flutter/model/languages.dart';
import 'package:pks_edit_flutter/util/file_stat_extension.dart';
import 'package:pks_edit_flutter/util/file_watcher.dart';
import 'package:pks_edit_flutter/util/logger.dart';
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
  OpenFile? _currentFile;
  set currentFile(OpenFile? file) {
    if (file == _currentFile) {
      return;
    }
    currentIndex = file == null ? -1 : files.indexOf(file);
  }
  set currentIndex(int idx) {
    if (_currentIndex == idx) {
      return;
    }
    _currentIndex = idx;
    _currentFile = idx < 0 || idx >= files.length ? null : files[idx];
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

  bool _selectionWasCollapsed = true;

  ///
  /// The index in the list of open files. Can be used to select the file via shortcut.
  ///
  int index = 0;
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

  ///
  /// Whether the file is read-only.
  ///
  bool readOnly;

  ///
  /// The modification when the file was read / written the last time.
  ///
  late DateTime modificationTime;

  ///
  /// Internal flag, if the caret must be repositioned asynchronously
  ///
  bool needsCaretAdjustment = false;
  ///
  /// The controller for performing the editing operations on the file.
  ///
  late CodeLineEditingController controller;

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

  ///
  /// Mark this file as "unchanged" by the user.
  ///
  void unchanged() {
    _lastSavedText = controller.text;
    _updateModified(false);
  }

  ///
  /// Assign a new line break strategy.
  ///
  void updateLineBreak(TextLineBreak newLineBreak) {
    if (newLineBreak == controller.options.lineBreak) {
      return;
    }
    controller = CodeLineEditingController(codeLines: controller.codeLines,
        options: controller.options.copyWith(lineBreak: newLineBreak));
    _changedListener!(this);
  }

  void onChanged(CodeLineEditingValue value) {
    if (controller.codeLines.equals(controller.preValue?.codeLines)) {
      final newCollapsed = value.selection.isCollapsed;
      if (newCollapsed != _selectionWasCollapsed) {
        _selectionWasCollapsed = newCollapsed;
        if (_changedListener != null) {
          _changedListener!(this);
        }
      }
      return;
    }
    _updateModified(controller.text != _lastSavedText);
  }

  void _updateModified(bool newModified) {
    var oldModified = modified;
    modified = newModified;
    modificationTime = DateTime.now();
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
    required TextLineBreak lineBreak,
    this.readOnly = false,
    DateTime? modificationTime,
    this.modified = false, this.encoding = utf8, required this.isNew, int? initialLineNumber}) {
    language = Languages.singleton.modeForFilename(filename);
    _lastSavedText = text;
    this.modificationTime = modificationTime ?? DateTime.now();
    controller = CodeLineEditingController.fromText(text, CodeLineOptions(indentSize: editingConfiguration.tabSize, lineBreak: lineBreak));
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

  final List<String> openFiles = [];
  final Logger _logger = createLogger("EditorBloc");
  late final OpenFileState _openFileState;
  int? _maximumNumberOfOpenWindows;
  final StreamController<PksIniConfiguration> _pksIniStreamController = BehaviorSubject();
  final StreamController<CommandResult> _errorResults = BehaviorSubject();
  late final EditingConfigurations editingConfigurations;
  late final ActionBindings actionBindings;
  late final Themes themes;
  final StreamController<OpenFileState> _openFileSubject = BehaviorSubject.seeded(OpenFileState(files: const [], currentIndex: -1));
  final StreamController<OpenFile> _externalFileChanges = BehaviorSubject();

  Stream<CommandResult> get errorResultStream => _errorResults.stream;
  Stream<OpenFileState> get openFileStream => _openFileSubject.stream;
  Stream<PksIniConfiguration> get pksIniStream => _pksIniStreamController.stream;
  Stream<OpenFile> get externalFileChangeStream => _externalFileChanges.stream;

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

  void _addErrorResult(CommandResult result) {
    if (!result.success) {
      _errorResults.add(result);
    }
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

  Future<CommandResult> _saveFile(OpenFile fileHandle) async {
    try {
      final file = File(fileHandle.filename);
      file.writeAsStringSync(fileHandle.controller.text, encoding: fileHandle.encoding);
      fileHandle.unchanged();
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
      FileWatcher.singleton.addWatchedFile(filename);
    }
    var result = await _saveFile(f);
    if (filename != null) {
      _refreshFiles();
    }
    return result;
  }

  Future<CommandResult> abandonFile(OpenFile openFile) async {
    try {
      final file = File(openFile.filename).absolute;
      final stat = file.statSync();
      openFile.readOnly = stat.readOnly;
      openFile.modificationTime = stat.modified;
      final result = await _detectEncoding(file);
      openFile.controller.text = file.readAsStringSync(encoding: result.encoding);
      openFile.unchanged();
      _refreshFiles();
      return CommandResult(success: true);
    } catch(ex) {
      return CommandResult(success: false, message: ex.toString());
    }
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
  /// Check, whether the current number of open files exceeds the maximum number of
  /// configured open windows. If this is the case, close windows to satisfy the maximumNumberOfOpenWindows condition.
  void _checkForMaxOpenWindows(OpenFile? doNotClose) {
    var max = _maximumNumberOfOpenWindows;
    if (max != null && max > 0) {
      var candidates = _openFileState.files.where((element) => !element.modified).toList();
      while(_openFileState.files.length > max && candidates.isNotEmpty) {
        var file = candidates.first;
        if (file == doNotClose) {
          break;
        }
        closeFile(file);
        candidates.remove(file);
      }
    }
  }

  void _updateFileIndices() {
    for (int i = 0; i < _openFileState.files.length; i++) {
      _openFileState.files[i].index = i+1;
    }
  }

  ///
  /// Activate / make current the window with the given logical [index]. Note,
  /// that PKS Edit window indices start with 1 rather than with 0.
  ///
  void activateWindowByIndex(int index) {
    index--;
    if (index >= 0 && index < _openFileState.files.length) {
      _openFileState.currentIndex = index;
    }
  }

  ///
  /// Add an open file to the list of open files.
  ///
  void _addOpenFile(OpenFile openFile) {
    _openFileState.files.add(openFile);
    _openFileState.currentIndex = _openFileState.files.length-1;
    _updateFileIndices();
    openFile.addChangeListener((OpenFile file) {
      _refreshFiles();
    });
    FileWatcher.singleton.addWatchedFile(openFile.filename);
    _checkForMaxOpenWindows(openFile);
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
    _addOpenFile(OpenFile(filename: filename,
        isNew: true,
        lineBreak: Platform.isWindows ? TextLineBreak.crlf : TextLineBreak.lf,
        editingConfiguration: await editingConfigurations.forFile(filename),
        text: insertTemplate ? Templates.singleton.generateInitialContent(filename) : ""));
    return CommandResult(success: true);
  }

  ({Encoding encoding, TextLineBreak lineBreak}) _parseBytesToDetectEncoding(List<int> pData) {
    var i = 0;
    final end = pData.length;
    int nLength;
    var lb = TextLineBreak.lf;
    while (i < end) {
      int byte = pData[i++];
      if (byte == 13 && i < end && pData[i] == 10) {
        lb = TextLineBreak.crlf;
      }
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
        return (encoding: latin1, lineBreak: lb);
      }

      /* Check continuation bytes: bit 7 should be set, bit 6 should be unset (b10xxxxxx). */
      for (i = 0; i < nLength; i++) {
        if ((pData[i] & 0xC0) != 0x80) {
          return (encoding: latin1, lineBreak: lb);
        }
        if (nLength == 1) {
          return (encoding: utf8, lineBreak: lb);
        } else if (nLength == 2) {
          /* 3 bytes sequence: U+0800..U+FFFF */
          int ch = ((pData[0] & 0x0f) << 12) + ((pData[1] & 0x3f) << 6) +
              (pData[2] & 0x3f);
          /* (0xff & 0x0f) << 12 | (0xff & 0x3f) << 6 | (0xff & 0x3f) = 0xffff, so ch <= 0xffff */
          if (ch < 0x0800) {
            return (encoding: latin1, lineBreak: lb);
          }
          /* surrogates (U+D800-U+DFFF) are invalid in UTF-8: test if (0xD800 <= ch && ch <= 0xDFFF) */
          if ((ch >> 11) == 0x1b) {
            return (encoding: latin1, lineBreak: lb);
          }
          return (encoding: utf8, lineBreak: lb);
        } else if (nLength == 3) {
          /* 4 bytes sequence: U+10000..U+10FFFF */
          int ch = ((pData[0] & 0x07) << 18) + ((pData[1] & 0x3f) << 12) +
              ((pData[2] & 0x3f) << 6) + (pData[3] & 0x3f);
          if ((ch < 0x10000) || (0x10FFFF < ch)) {
            return (encoding: latin1, lineBreak: lb);
          }
          return (encoding: utf8, lineBreak: lb);
        }
        i += nLength;
      }
    }
    return (encoding: latin1, lineBreak: lb);
  }


  Future<({Encoding encoding, TextLineBreak lineBreak})> _detectEncoding(File file) async {
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
      final stat = file.statSync();
      final readOnly = stat.readOnly;
      final result = await _detectEncoding(file);
      String? text = file.readAsStringSync(encoding: result.encoding);
      openFiles.remove(filename);
      openFiles.insert(0, filename);
      if (openFiles.length > 10) {
        openFiles.removeRange(10, openFiles.length);
      }
      _addOpenFile(OpenFile(
          readOnly: readOnly,
          modificationTime: stat.modified,
          editingConfiguration: ec,
          filename: filename,
          isNew: false,
          text: text,
          lineBreak: result.lineBreak,
          encoding: result.encoding,
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
    _updateFileIndices();
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
    PksConfiguration.singleton.saveSettings(configuration);
    _maximumNumberOfOpenWindows = configuration.configuration.maximumOpenWindows;
    _checkForMaxOpenWindows(null);
    _pksIniStreamController.add(configuration);
  }

  ///
  /// Initializes the BLOC interpreting the command line arguments.
  ///
  Future<void> initialize({required List<String> arguments}) async {
    _openFileState = OpenFileState(files: [], currentIndex: -1, currentChanged: _refreshFiles);
    for (var arg in arguments) {
      if (!arg.startsWith("-")) {
        _addErrorResult(await openFile(arg));
      } else {
        if (arg.startsWith("-pks_sys:")) {
          PksConfiguration.singleton.pksSysDirectory = arg.substring(9);
        }
      }
    }
    var session = await PksConfiguration.singleton.currentSession;
    themes = await PksConfiguration.singleton.themes;
    editingConfigurations = await PksConfiguration.singleton.editingConfigurations;
    actionBindings = await PksConfiguration.singleton.actionBindings;
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
        _addErrorResult(await openFile(f.path, dock: f.dock,
            lineNumber: f.lineNumber < 0 ? null : f.lineNumber));
      }
      if (active != null) {
        _openFileState.currentIndex = active;
      }
    }
    openFiles.addAll(session.openFiles);
    updateConfiguration(pksIniConfiguration);
    await initWindowOptions(session);
    FileWatcher.singleton.changeEvents.listen(_checkForFileChanges);
  }

  void _checkForFileChanges(FileSystemEvent event) {
    final changedFile = event.path;
    for (final of in _openFileState.files) {
      var file = File(of.filename);
      if (event.isDirectory && (file.parent.path != changedFile)) {
        continue;
      }
      if (!event.isDirectory && (file.path != changedFile)) {
        continue;
      }
      final stat = file.statSync();
      if (stat.modified.isAfter(of.modificationTime)) {
        // Set modification time to not report again.
        of.modificationTime = stat.modified;
        _externalFileChanges.add(of);
      }
    }
  }

  Future<void> dispose() async {
    _openFileSubject.close();
    _externalFileChanges.close();
    _errorResults.close();
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
    _logger.i("Saving current session.");
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
