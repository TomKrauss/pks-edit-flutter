//
// actions.dart
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

//
// actions.dart
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

import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:pks_edit_flutter/bloc/editor_bloc.dart';
import 'package:pks_edit_flutter/ui/dialog/confirmation_dialog.dart';
import 'package:pks_edit_flutter/ui/dialog/input_dialog.dart';
import 'package:pks_edit_flutter/ui/dialog/settings_dialog.dart';
import 'package:re_editor/re_editor.dart';

///
/// Context used in actions to evaluate actions and action enablement.
///
class PksEditActionContext {
  final OpenFileState? openFileState;
  final OpenFile? _currentFile;
  OpenFile? get currentFile => _currentFile ?? openFileState?.currentFile;
  PksEditActionContext({required this.openFileState, OpenFile? currentFile}) : _currentFile = currentFile;
}

///
/// Represents an action to be executed by PKS-Edit.
///
class PksEditAction {
  static const String fileGroup = "file";
  static const String editGroup = "edit";
  static const String findGroup = "find";
  static const String viewGroup = "view";
  static const String windowGroup = "window";
  static const String extraGroup = "extra";
  static const String functionGroup = "function";
  static const String defaultGroup = "default";
  static List<String> get wellknownGroups => [PksEditAction.fileGroup, PksEditAction.editGroup, PksEditAction.findGroup,
    PksEditAction.functionGroup, PksEditAction.extraGroup, PksEditAction.windowGroup, PksEditAction.viewGroup];
  final String id;
  final String? _description;
  final String group;
  final MenuSerializableShortcut? shortcut;
  ///
  /// Add a separator before creating a button in the toolbar / in a menu before adding
  /// the button for this action.
  ///
  final bool separatorBefore;
  String? text;
  IconData? icon;
  ///
  /// Returns the label to be used to display the action in a UI.
  ///
  String get label => text ?? id;
  ///
  /// Returns the text to be displayed as a description (tooltip) for this action
  ///
  String get description => "${_description ?? label}${shortcut == null ? '' : '- ${shortcut!.debugDescribeKeys()}'}";
  final bool Function() isEnabled;
  final void Function() execute;

  bool get displayInToolbar => icon != null;
  bool get displayInMenu => true;

  void Function()? get onPressed => isEnabled() ? execute : null;

  static bool _alwaysEnabled() => true;

  PksEditAction({required this.id, this.isEnabled = _alwaysEnabled,
    required this.execute,
    this.separatorBefore = false,
    this.shortcut,
    this.group = defaultGroup,
    this.text, this.icon, String? description}) : _description = description;
}

///
/// The actions supported by PKS-Edit.
///
class PksEditActions {
  static const actionExit = "exit";
  static const actionCloseWindow = "close-window";
  final PksEditActionContext Function() getActionContext;
  final BuildContext Function() getBuildContext;
  final Future<void> Function(CommandResult commandResult) handleCommandResult;
  final Map<ShortcutActivator, VoidCallback> additionalActions;
  final Map<String, PksEditAction> actions = {};
  late final Map<ShortcutActivator, VoidCallback> shortcuts;

  PksEditActions({required this.getBuildContext, required this.getActionContext,
        required this.handleCommandResult, required this.additionalActions}) {
    _initialize();
  }

  void _registerAction(PksEditAction action) {
    actions[action.id] = action;
  }

  void _initialize() {
    final actions = [
      PksEditAction(
          id: "open-file",
          execute: _openFile,
          text: "Open File...",
          shortcut:
          const SingleActivator(LogicalKeyboardKey.keyO, control: true),
          group: PksEditAction.fileGroup,
          icon: Icons.file_open),
      PksEditAction(
          id: "new-file",
          execute: _newFile,
          text: "New File...",
          shortcut:
          const SingleActivator(LogicalKeyboardKey.keyN, control: true),
          group: PksEditAction.fileGroup,
          icon: Icons.create_outlined),
      PksEditAction(
          id: "save-file",
          execute: _saveFile,
          isEnabled: _canSave,
          text: "Save File",
          shortcut:
          const SingleActivator(LogicalKeyboardKey.keyS, control: true),
          description: "Save current file",
          group: PksEditAction.fileGroup,
          icon: Icons.save),
      PksEditAction(
          id: "abandon-file",
          execute: _abandonFile,
          isEnabled: _canSave,
          text: "Abandon File",
          shortcut:
          const SingleActivator(LogicalKeyboardKey.f5, control: true),
          description: "Abandon all changes in the current file",
          group: PksEditAction.fileGroup,
          icon: Icons.recycling),
      PksEditAction(
          id: "save-file-as",
          execute: _saveFileAs,
          isEnabled: _hasFile,
          text: "Save File As...",
          description: "Save current file under new name",
          group: PksEditAction.fileGroup,
          icon: Icons.save_as),
      PksEditAction(
          id: actionCloseWindow,
          execute: _closeWindow,
          text: "Close Window",
          shortcut:
          const SingleActivator(LogicalKeyboardKey.keyW, control: true),
          description: "Closes the current editor window",
          group: PksEditAction.fileGroup,
          icon: Icons.close),
      PksEditAction(
          id: "close-all-windows",
          execute: _closeAllWindows,
          text: "Close All Windows",
          shortcut:
          const SingleActivator(
              LogicalKeyboardKey.keyW, control: true, shift: true),
          icon: Icons.done_all,
          description: "Closes all editor windows",
          group: PksEditAction.fileGroup),
      PksEditAction(
          id: "close-all-but-active",
          execute: _closeAllButActive,
          text: "Close All other Windows",
          shortcut:
          const SingleActivator(
              LogicalKeyboardKey.keyW, control: true, alt: true),
          icon: Icons.clear_all,
          description: "Closes all other editor windows but current",
          group: PksEditAction.fileGroup),
      PksEditAction(
          id: actionExit,
          execute: _exit,
          text: "Exit",
          shortcut: const SingleActivator(LogicalKeyboardKey.f4, alt: true),
          icon: Icons.exit_to_app,
          description: "Exit PKS Edit",
          separatorBefore: true,
          group: PksEditAction.fileGroup),
      PksEditAction(
          id: "undo",
          execute: _undo,
          isEnabled: _canUndo,
          shortcut:
          const SingleActivator(LogicalKeyboardKey.keyZ, control: true),
          text: "Undo",
          group: PksEditAction.editGroup,
          icon: Icons.undo),
      PksEditAction(
          id: "redo",
          execute: _redo,
          isEnabled: _canRedo,
          shortcut:
          const SingleActivator(LogicalKeyboardKey.keyY, control: true),
          text: "Redo",
          group: PksEditAction.editGroup,
          icon: Icons.redo),
      PksEditAction(
          id: "copy",
          execute: _copy,
          isEnabled: _hasFile,
          shortcut:
          const SingleActivator(LogicalKeyboardKey.keyC, control: true),
          text: "Copy",
          separatorBefore: true,
          group: PksEditAction.editGroup,
          icon: Icons.copy),
      PksEditAction(
          id: "cut",
          execute: _cut,
          isEnabled: _hasWriteableFile,
          shortcut:
          const SingleActivator(LogicalKeyboardKey.keyX, control: true),
          text: "Cut",
          group: PksEditAction.editGroup,
          icon: Icons.cut),
      PksEditAction(
          id: "paste",
          execute: _paste,
          isEnabled: _hasWriteableFile,
          shortcut:
          const SingleActivator(LogicalKeyboardKey.keyV, control: true),
          text: "Paste",
          group: PksEditAction.editGroup,
          icon: Icons.paste),
      PksEditAction(
          id: "select-all",
          execute: _selectAll,
          isEnabled: _hasFile,
          shortcut: const SingleActivator(
              LogicalKeyboardKey.keyA, control: true),
          icon: Icons.select_all,
          separatorBefore: true,
          text: "Select All",
          group: PksEditAction.editGroup),
      PksEditAction(
          id: "comment-line",
          execute: _commentLine,
          isEnabled: _hasFile,
          shortcut: const SingleActivator(
              LogicalKeyboardKey.numpad7, control: true),
          icon: Icons.comment,
          text: "Comment Single Line",
          group: PksEditAction.functionGroup),
      PksEditAction(
          id: "transpose-characters",
          execute: _transposeCharacters,
          isEnabled: _hasFile,
          shortcut: const SingleActivator(
              LogicalKeyboardKey.keyT, control: true),
          text: "Transpose Characters",
          group: PksEditAction.functionGroup),
      PksEditAction(
          id: "cycle-window-forward",
          execute: _cycleWindowForward,
          shortcut: const SingleActivator(
              LogicalKeyboardKey.tab, control: true),
          icon: Icons.rotate_left,
          text: "Cycle window forward",
          group: PksEditAction.windowGroup),
      PksEditAction(
          id: "cycle-window-backward",
          execute: _cycleWindowBackward,
          shortcut:
          const SingleActivator(
              LogicalKeyboardKey.tab, control: true, shift: true),
          icon: Icons.rotate_right,
          text: "Cycle window backward",
          group: PksEditAction.windowGroup),
      PksEditAction(
          id: "activate-window-1",
          execute: _activateWindow1,
          shortcut:
          const SingleActivator(
              LogicalKeyboardKey.numpad1, control: true),
          text: "Activate Window 1"),
      PksEditAction(
          id: "activate-window-1",
          execute: _activateWindow1,
          shortcut:
          const SingleActivator(
              LogicalKeyboardKey.digit1, control: true),
          text: "Activate Window 1"),
      PksEditAction(
          id: "activate-window-2",
          execute: _activateWindow2,
          shortcut:
          const SingleActivator(
              LogicalKeyboardKey.digit2, control: true),
          text: "Activate Window 2"),
      PksEditAction(
          id: "activate-window-3",
          execute: _activateWindow3,
          shortcut:
          const SingleActivator(
              LogicalKeyboardKey.digit3, control: true),
          text: "Activate Window 3"),
      PksEditAction(
          id: "activate-window-4",
          execute: _activateWindow4,
          shortcut:
          const SingleActivator(
              LogicalKeyboardKey.digit4, control: true),
          text: "Activate Window 4"),
      PksEditAction(
          id: "activate-window-5",
          execute: _activateWindow5,
          shortcut:
          const SingleActivator(
              LogicalKeyboardKey.digit5, control: true),
          text: "Activate Window 5"),
      PksEditAction(
          id: "goto-line",
          execute: _gotoLine,
          isEnabled: _hasFile,
          shortcut:
          const SingleActivator(LogicalKeyboardKey.keyG, control: true),
          icon: Icons.numbers_sharp,
          text: "Goto line",
          group: PksEditAction.findGroup),
      PksEditAction(
          id: "change-settings",
          execute: _changeSettings,
          text: "Change Settings...",
          shortcut:
          const SingleActivator(LogicalKeyboardKey.numpadMultiply, alt: true),
          group: PksEditAction.extraGroup,
          icon: Icons.create_outlined),
    ];
    shortcuts = _buildShortcutMap(actions);
    actions.forEach(_registerAction);
  }

  bool _hasFile() =>
      getActionContext().currentFile != null;

  bool _hasWriteableFile() =>
      getActionContext().currentFile != null && getActionContext().currentFile?.readOnly != true;

  bool _canRedo() {
    var f = getActionContext().currentFile;
    if (f != null) {
      return f.controller.canRedo;
    }
    return false;
  }

  void _withCurrentFile(PksEditActionContext actionContext,
      void Function(CodeLineEditingController controller) callback) {
    var f = actionContext.currentFile;
    if (f != null) {
      callback(f.controller);
    }
  }

  void _copy() {
    _withCurrentFile(getActionContext(), (controller) {
      controller.copy();
    });
  }

  void _cut() {
    _withCurrentFile(getActionContext(), (controller) {
      controller.cut();
    });
  }

  void _paste() {
    _withCurrentFile(getActionContext(), (controller) {
      controller.paste();
    });
  }

  void _undo() {
    _withCurrentFile(getActionContext(), (controller) {
      controller.undo();
    });
  }

  void _commentLine() {
    _withCurrentFile(getActionContext(), (controller) {
      //controller.transposeCharacters();
    });
  }

  void _transposeCharacters() {
    _withCurrentFile(getActionContext(), (controller) {
      controller.transposeCharacters();
    });
  }

  void _selectAll() {
    _withCurrentFile(getActionContext(), (controller) {
      controller.selectAll();
    });
  }

  void _redo() {
    _withCurrentFile(getActionContext(), (controller) {
      controller.redo();
    });
  }

  Future<void> _changeSettings() async {
    await SettingsDialog.show(context: getBuildContext());
  }

  bool _canSave() =>
      getActionContext().openFileState?.currentFile?.modified == true;

  bool _canUndo() {
    var f = getActionContext().currentFile;
    if (f != null) {
      return f.controller.canUndo;
    }
    return false;
  }

  void _abandonFile() async {
    var context = getBuildContext();
    final bloc = EditorBloc.of(context);
    var f = getActionContext().currentFile;
    if (f != null && f.modified) {
      if ((await ConfirmationDialog.show(context: context, message: "Do you really want to abandon all changes?", actions: ConfirmationDialog.yesNoActions)) == "yes") {
        bloc.abandonFile(f);
      }
    }
  }

  void _cycleWindowForward() {
    final bloc = EditorBloc.of(getBuildContext());
    bloc.cycleWindow(1);
  }

  void _cycleWindowBackward() {
    final bloc = EditorBloc.of(getBuildContext());
    bloc.cycleWindow(-1);
  }

  void _activateWindow(int index) {
    final bloc = EditorBloc.of(getBuildContext());
    bloc.activateWindowByIndex(index);
  }

  void _activateWindow1() {
    _activateWindow(1);
  }

  void _activateWindow2() {
    _activateWindow(2);
  }

  void _activateWindow3() {
    _activateWindow(3);
  }

  void _activateWindow4() {
    _activateWindow(4);
  }

  void _activateWindow5() {
    _activateWindow(5);
  }

  void _saveFileAs() async {
    final bloc = EditorBloc.of(getBuildContext());
    final filename = bloc.suggestNewFilename(getActionContext().currentFile!.filename);
    final String initialDirectory = path.dirname(filename);
    final result = await getSaveLocation(
        initialDirectory: initialDirectory,
        suggestedName: path.basename(filename),
        acceptedTypeGroups: bloc.editingConfigurations.getFileGroups(filename),
        confirmButtonText: "Save");
    if (result != null) {
      handleCommandResult(await bloc.saveActiveFile(filename: result.path));
    }
  }

  void _saveFile() async {
    final bloc = EditorBloc.of(getBuildContext());
    handleCommandResult(await bloc.saveActiveFile());
  }

  void _gotoLine() async {
    var controller = getActionContext().currentFile?.controller;
    if (controller == null) {
      return;
    }
    final result = await InputDialog.show(context: getBuildContext(), arguments:
    InputDialogArguments(context: getActionContext(), title: "Goto Line",
        keyboardType: TextInputType.number,
        inputLabel: "Line number", initialValue: "${controller.selection.start.index+1}"));
    if (result != null) {
      var newLine = int.tryParse(result.selectedText);
      if (newLine != null) {
        if (newLine < 0 || newLine >= controller.lineCount) {
          handleCommandResult(CommandResult(success: true, message: "Line number of of range (0 - ${controller.lineCount})"));
          return;
        }
        controller.selection = controller.selection.copyWith(
          baseIndex: newLine-1,
          baseOffset: 0,
          extentIndex: newLine-1,
          extentOffset: 0,
        );
        controller.makeCursorCenterIfInvisible();
      }
    }
  }

  Future<void> _openFile() async {
    final bloc = EditorBloc.of(getBuildContext());
    final String initialDirectory = File(".").absolute.path;
    final result = await openFile(
        initialDirectory: initialDirectory,
        acceptedTypeGroups: bloc.editingConfigurations.getFileGroups(getActionContext().currentFile?.filename ?? ""),
        confirmButtonText: "Open");
    if (result != null) {
      await handleCommandResult(await bloc.openFile(result.path));
    }
  }

  void _newFile() async {
    final actionContext = getActionContext();
    final bloc = EditorBloc.of(getBuildContext());
    final newFilename = bloc.suggestNewFilename(actionContext.currentFile?.filename);
    final result = await InputDialog.show(context: getBuildContext(), arguments:
    InputDialogArguments(context: actionContext, title: "New File", inputLabel: "File name",
        options: {"Initialize with Template": true},
        initialValue: path.basename(newFilename)));
    if (result != null) {
      handleCommandResult(await bloc.newFile(path.join(path.dirname(newFilename), result.selectedText), insertTemplate: result.firstOptionSelected));
    }
  }

  Future<void> _closeWindows(List<OpenFile> files) async {
    // avoid concurrent modification exception.
    final bloc = EditorBloc.of(getBuildContext());
    files = [...files];
    for (final file in files) {
      if (file.modified) {
        var result = await ConfirmationDialog.show(context: getBuildContext(), message: "File ${file.filename} was modified.\nShould we save it before closing?",
            actions: {
              "Save": "save",
              "Close without Saving": "close",
              "Cancel": null
            });
        if (result == null) {
          break;
        }
        if (result == "save") {
          final commandResult = await bloc.saveAllModified();
          if (!commandResult.success) {
            handleCommandResult(commandResult);
            return;
          }
        }
      }
      bloc.closeFile(file);
    }
  }

  ///
  /// Close all windows but the active one.
  ///
  void _closeAllButActive() {
    final actionContext = getActionContext();
    var files = actionContext.openFileState?.files.where((element) => element != actionContext.openFileState?.currentFile).toList();
    if (files != null) {
      _closeWindows(files);
    }
  }

  void _closeAllWindows() {
    _closeWindows(getActionContext().openFileState?.files ?? []);
  }

  void _closeWindow() {
    var file = getActionContext().currentFile;
    if (file == null) {
      return;
    }
    _closeWindows([file]);
  }


  void _exit() async {
    var context = getBuildContext();
    if (!context.mounted) {
      return;
    }
    final bloc = EditorBloc.of(context);
    if (bloc.hasChangedWindows) {
      var result = await ConfirmationDialog.show(
          context: context,
          title: "Exit PKS Edit",
          message:
          "Some files are changed and not yet saved. How should we proceed?",
          actions: {
            "Exit without Saving": "close",
            "Save All and Exit": "save",
            "Cancel": null
          });
      if (result == null) {
        return;
      }
      if (result == "save") {
        final result = await bloc.saveAllModified();
        if (!result.success) {
          handleCommandResult(result);
          return;
        }
      }
    }
    if (context.mounted) {
      bloc.exitApp(context);
    }
  }

  Map<ShortcutActivator, VoidCallback> _buildShortcutMap(
      List<PksEditAction> actions) {
    final result = <ShortcutActivator, VoidCallback>{};
    for (final action in actions) {
      if (action.shortcut is ShortcutActivator) {
        result[action.shortcut as ShortcutActivator] = () {
          var f = action.onPressed;
          if (f != null) {
            f();
          }
        };
      }
    }
    result.addAll(additionalActions);
    return result;
  }

  ///
  /// Execute an action given the action id.
  ///
  Future<void> execute(String actionId) async {
    var action = actions[actionId]?.onPressed;
    if (action != null) {
      action();
    }
  }

}
