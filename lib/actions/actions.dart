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
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:pks_edit_flutter/bloc/controller_extension.dart';
import 'package:pks_edit_flutter/bloc/editor_bloc.dart';
import 'package:pks_edit_flutter/generated/l10n.dart';
import 'package:pks_edit_flutter/ui/dialog/confirmation_dialog.dart';
import 'package:pks_edit_flutter/ui/dialog/input_dialog.dart';
import 'package:pks_edit_flutter/ui/dialog/search_replace_dialog.dart';
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
  final String id;
  final String? _description;
  ///
  /// If the description was specified using an L10N key - this is the key.
  ///
  final String? descriptionKey;
  ///
  /// If the text was specified using an L10N key - this is the key.
  ///
  final String? textKey;
  bool referenced = false;
  MenuSerializableShortcut? shortcut;
  ///
  /// If an icon is configured - use it.
  IconData? icon;
  final String? _text;

  String? get text {
    if (_text != null) {
      return _text;
    }
    if (textKey != null) {
      return Intl.message(textKey!, name: textKey);
    }
    return null;
  }

  ///
  /// Returns the label to be used to display the action in a UI.
  ///
  String get label => text ?? id;
  ///
  /// Returns the text to be displayed as a description (tooltip) for this action
  ///
  String get description {
    var t = _description;
    if (t == null && descriptionKey != null) {
      t = Intl.message(descriptionKey!, name: descriptionKey);
    }
    t ??= label;
    return "$t${shortcut == null ? '' : '- ${shortcut!.debugDescribeKeys()}'}";
  }
  final bool Function() isEnabled;
  final void Function() execute;

  bool get displayInMenu => true;

  void Function()? get onPressed => isEnabled() ? execute : null;

  static bool _alwaysEnabled() => true;

    PksEditAction({required this.id, this.isEnabled = _alwaysEnabled,
      required this.execute,
      this.textKey,
      this.shortcut,
      this.descriptionKey,
      String? text, String? description}) : _text = text, _description = description;
}

///
/// The actions supported by PKS-Edit.
///
class PksEditActions {
  static const actionExit = "exit-edit";
  static const actionCloseWindow = "quit-file";
  final PksEditActionContext Function() getActionContext;
  final BuildContext Function() getBuildContext;
  final Future<void> Function(CommandResult commandResult) handleCommandResult;
  final Map<String, PksEditAction> actions = {};

  PksEditActions({required this.getBuildContext, required this.getActionContext,
        required this.handleCommandResult}) {
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
          textKey: "actionOpenFile",),
      PksEditAction(
          id: "open-new-file",
          execute: _newFile,
          textKey: "actionNewFile",),
      PksEditAction(
          id: "save-file",
          execute: _saveFile,
          isEnabled: _canSave,
          textKey: "actionSaveFile",
          descriptionKey: "actionDescriptionSaveCurrentFile",),
      PksEditAction(
          id: "discard-changes-in-file",
          execute: _discardChangesInFile,
          isEnabled: _canSave,
          textKey: "actionDiscardChangesInFile",
          descriptionKey: "actionDescriptionDiscardChangesInFile"),
      PksEditAction(
          id: "save-file-as",
          execute: _saveFileAs,
          isEnabled: _hasFile,
          textKey: "actionSaveFileAs",
          descriptionKey: "actionDescriptionSaveFileAs"),
      PksEditAction(
          id: actionCloseWindow,
          execute: _closeWindow,
          textKey: "actionCloseWindow",
          descriptionKey: "actionDescriptionCloseWindow"),
      PksEditAction(
          id: "close-all-windows",
          execute: _closeAllWindows,
          textKey: "actionCloseAllWindows",
          descriptionKey: "actionDescriptionCloseAllWindows"),
      PksEditAction(
          id: "close-all-but-current-window",
          execute: _closeAllButActive,
          textKey: "actionCloseAllButCurrentWindow",
          descriptionKey: "actionDescriptionCloseAllButCurrentWindow"),
      PksEditAction(
          id: actionExit,
          execute: _exit,
          textKey: "actionExit",
          descriptionKey: "actionDescriptionExit"),
      PksEditAction(
          id: "undo",
          execute: _undo,
          isEnabled: _canUndo,
          textKey: "actionUndo"),
      PksEditAction(
          id: "redo",
          execute: _redo,
          isEnabled: _canRedo,
          textKey: "actionRedo"),
      PksEditAction(
          id: "find-string",
          execute: _find,
          isEnabled: _hasFile,
          textKey: "actionFind"),
      PksEditAction(
          id: "find-word-forward",
          execute: _findWordForward,
          isEnabled: _hasFile,
          textKey: "actionFindWordForward"),
      PksEditAction(
          id: "find-word-back",
          execute: _findWordBackward,
          isEnabled: _hasFile,
          textKey: "actionFindWordBackward"),
      PksEditAction(
          id: "find-again-backward",
          execute: _findAgainBackward,
          isEnabled: _hasFile,
          textKey: "actionFindAgainBackward"),
      PksEditAction(
          id: "find-again-forward",
          execute: _findAgainForward,
          isEnabled: _hasFile,
          textKey: "actionFindAgainForward"),
      // Currently an alias of find-again-forward.
      PksEditAction(
          id: "find-again",
          execute: _findAgainForward,
          isEnabled: _hasFile,
          textKey: "actionFindAgainForward"),
      PksEditAction(
          id: "replace-string",
          execute: _replace,
          isEnabled: _hasWriteableFile,
          textKey: "actionReplace"),
      PksEditAction(
          id: "copy-to-clipboard",
          execute: _copy,
          isEnabled: _hasSelection,
          textKey: "actionCopy"),
      PksEditAction(
          id: "erase-selection",
          execute: _eraseSelection,
          isEnabled: _hasWriteableSelection,
          textKey: "actionErase"),
      PksEditAction(
          id: "shift-range-left",
          execute: _shiftRangeLeft,
          isEnabled: _hasWriteableFile,
          textKey: "actionShiftRangeLeft"),
      PksEditAction(
          id: "shift-range-right",
          execute: _shiftRangeRight,
          isEnabled: _hasWriteableFile,
          textKey: "actionShiftRangeRight"),
      PksEditAction(
          id: "use-linux-lineends",
          execute: _useLinuxLineEnds,
          isEnabled: _hasWriteableFile,
          textKey: "actionUseLinuxLineEnds"),
      PksEditAction(
          id: "use-windows-lineends",
          execute: _useWindowsLineEnds,
          isEnabled: _hasWriteableFile,
          textKey: "actionUseWindowsLineEnds"),
      PksEditAction(
          id: "char-to-lower",
          execute: _charToLower,
          isEnabled: _hasWriteableSelection,
          textKey: "actionCharToLower"),
      PksEditAction(
          id: "char-to-upper",
          execute: _charToUpper,
          isEnabled: _hasWriteableSelection,
          textKey: "actionCharToUpper"),
      PksEditAction(
          id: "char-toggle-upper-lower",
          execute: _charToggleUpperLower,
          isEnabled: _hasWriteableSelection,
          textKey: "actionCharToggleUpperLower"),
      PksEditAction(
          id: "delete-selection",
          execute: _cut,
          isEnabled: _hasWriteableSelection,
          textKey: "actionCut"),
      PksEditAction(
          id: "paste-clipboard",
          execute: _paste,
          isEnabled: _hasWriteableFile,
          textKey: "actionPaste"),
      PksEditAction(
          id: "select-all",
          execute: _selectAll,
          isEnabled: _hasFile,
          textKey: "actionSelectAll"),
      PksEditAction(
          id: "toggle-comment",
          execute: _commentLine,
          isEnabled: _hasFile,
          textKey: "actionToggleComment"),
      PksEditAction(
          id: "cycle-window",
          execute: _cycleWindowForward,
          textKey: "actionCycleWindow"),
      PksEditAction(
          id: "select-previous-window",
          execute: _cycleWindowBackward,
          textKey: "actionSelectPreviousWindow"),
      PksEditAction(
          id: "select-window-1",
          execute: _activateWindow1,
          text: "Activate Window 1"),
      PksEditAction(
          id: "select-window-2",
          execute: _activateWindow2,
          text: "Activate Window 2"),
      PksEditAction(
          id: "select-window-3",
          execute: _activateWindow3,
          text: "Activate Window 3"),
      PksEditAction(
          id: "select-window-4",
          execute: _activateWindow4,
          text: "Activate Window 4"),
      PksEditAction(
          id: "select-window-5",
          execute: _activateWindow5,
          text: "Activate Window 5"),
      PksEditAction(
          id: "select-window-6",
          execute: _activateWindow6,
          text: "Activate Window 6"),
      PksEditAction(
          id: "goto-line",
          execute: _gotoLine,
          isEnabled: _hasFile,
          textKey: "actionGotoLine"),
      PksEditAction(
          id: "set-options",
          execute: _changeSettings,
          textKey: "actionSetOptions"),
      PksEditAction(
          id: "show-copyright",
          execute: _showAbout,
          textKey: "actionShowCopyright"),
    ];
    actions.forEach(_registerAction);
  }

  bool _hasFile() =>
      getActionContext().currentFile != null;

  bool _hasSelection() =>
      getActionContext().currentFile?.controller.selection.isCollapsed == false;

  bool _hasWriteableSelection() {
    var f = getActionContext().currentFile;
    return f != null && !f.readOnly && !f.controller.selection.isCollapsed;
  }

  bool _hasWriteableFile() {
    var f = getActionContext().currentFile;
    return f != null && !f.readOnly;
  }

  bool _canRedo() {
    var f = getActionContext().currentFile;
    if (f != null) {
      return f.controller.canRedo;
    }
    return false;
  }

  void _showAbout() async {
    final context = getBuildContext();
    final info = await PackageInfo.fromPlatform();
    if (context.mounted) {
      showAboutDialog(
          context: context,
          applicationName: "PKS Edit",
          children: [
            Text(S.of(context).aboutInfoText),
            const Divider(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Author: Tom Krauß"),
                Text("Design: Rolf Pahlen")
              ],
            )
          ],
          applicationIcon: Image.asset("lib/assets/images/pks.png"),
          applicationVersion: info.version);
    }
  }

  void _replace() {
    var f = getActionContext().currentFile;
    if (f != null) {
      SearchReplaceDialog.show(context: getBuildContext(), arguments: SearchReplaceDialogArguments(findController: f.findController));
    }
  }

  void _useLinuxLineEnds() {
    _withCurrentFile((file) {
      file.updateLineBreak(TextLineBreak.lf);
    });
  }

  void _useWindowsLineEnds() {
    _withCurrentFile((file) {
      file.updateLineBreak(TextLineBreak.crlf);
    });
  }

  void _updateMatchSelection(OpenFile file) {
    var sel = file.findController.currentMatchSelection;
    if (sel != null) {
      file.controller.selection = sel;
      file.controller.makeCursorVisible();
    }
  }

  void _findAgainBackward() {
    _withCurrentFile((file) {
      file.findController.previousMatch();
      _updateMatchSelection(file);
    });
  }

  void _shiftRangeRight() {
    _withCurrentFile((file) {
      file.controller.applyIndent();
    });
  }

  void _shiftRangeLeft() {
    _withCurrentFile((file) {
      file.controller.applyOutdent();
    });
  }

  void _findAgainForward() {
    _withCurrentFile((file) {
      file.findController.nextMatch();
      _updateMatchSelection(file);
    });
  }

  void _findWordForward() {
    _withCurrentFile((file) async {
      var context = getBuildContext();
      final bloc = EditorBloc.of(context);
      await bloc.matchWord(file);
      file.findController.nextMatch();
      _updateMatchSelection(file);
    });
  }

  void _findWordBackward() {
    _withCurrentFile((file) async {
      var context = getBuildContext();
      final bloc = EditorBloc.of(context);
      await bloc.matchWord(file);
      file.findController.previousMatch();
      _updateMatchSelection(file);
    });
  }

  void _find() {
    _withCurrentFile((file) {
      SearchReplaceDialog.show(context: getBuildContext(),
          arguments: SearchReplaceDialogArguments(findController: file.findController, replace: false));
    });
  }

  void _withCurrentFile(void Function(OpenFile file) callback) {
    var f = getActionContext().currentFile;
    if (f != null) {
      callback(f);
    }
  }

  void _eraseSelection() {
    _withCurrentFile((file) {
      file.controller.deleteSelection();
    });
  }

  void _copy() {
    _withCurrentFile((file) {
      final controller = file.controller;
      controller.copy();
      var s = controller.selectedText;
      if (s.isNotEmpty) {
        handleCommandResult(CommandResult(success: true, message: S.current.copiedToClipboardHint(s.length)));
      }
    });
  }

  void _cut() {
    _withCurrentFile((file) {
      final controller = file.controller;
      controller.cut();
    });
  }

  void _paste() {
    _withCurrentFile((file) {
      final controller = file.controller;
      controller.paste();
    });
  }

  void _undo() {
    _withCurrentFile((file) {
      final controller = file.controller;
      controller.undo();
    });
  }

  void _commentLine() {
    _withCurrentFile((file) {
      //controller.transposeCharacters();
    });
  }

  void _selectAll() {
    _withCurrentFile((file) {
      final controller = file.controller;
      controller.selectAll();
    });
  }

  void _redo() {
    _withCurrentFile((file) {
      final controller = file.controller;
      controller.redo();
    });
  }

  void _charToggleUpperLower() {
    _withCurrentFile((file) {
      final controller = file.controller;
      controller.charToggleUpperLower();
    });
  }

  void _charToUpper() {
    _withCurrentFile((file) {
      final controller = file.controller;
      controller.charToUpper();
    });
  }

  void _charToLower() {
    _withCurrentFile((file) {
      final controller = file.controller;
      controller.charToLower();
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

  void _discardChangesInFile() async {
    var context = getBuildContext();
    final bloc = EditorBloc.of(context);
    var f = getActionContext().currentFile;
    if (f != null && f.modified) {
      if ((await ConfirmationDialog.show(context: context, message: S.of(context).reallyDiscardAllChanges, actions: ConfirmationDialog.yesNoActions)) == "yes") {
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

  void _activateWindow6() {
    _activateWindow(6);
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
    final context = getBuildContext();
    final intl = S.of(context);
    int? newLine;
    String? validate(String newValue) {
      newLine = int.tryParse(newValue);
      if (newLine == null) {
        return "";
      }
      if (newLine! <= 0 || newLine! > controller.lineCount) {
        return intl.lineNumberRangeHint(controller.lineCount);
      }
      return null;
    }
    final result = await InputDialog.show(context: context, arguments:
    InputDialogArguments(context: getActionContext(), title: intl.gotoLine,
        keyboardType: TextInputType.number,
        validator: validate,
        inputLabel: intl.lineNumber, initialValue: "${controller.selection.start.index+1}"));
    var nl = newLine;
    if (result != null && nl != null) {
      controller.selection = controller.selection.copyWith(
        baseIndex: nl-1,
        baseOffset: 0,
        extentIndex: nl-1,
        extentOffset: 0,
      );
      controller.makeCursorCenterIfInvisible();
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
    final context = getBuildContext();
    final bloc = EditorBloc.of(context);
    final newFilename = bloc.suggestNewFilename(actionContext.currentFile?.filename);
    final result = await InputDialog.show(context: getBuildContext(), arguments:
    InputDialogArguments(context: actionContext, title: S.of(context).newFile, inputLabel: S.of(context).fileName,
        options: {S.of(context).initializeWithTemplate: true},
        initialValue: path.basename(newFilename)));
    if (result != null) {
      handleCommandResult(await bloc.newFile(path.join(path.dirname(newFilename), result.selectedText), insertTemplate: result.firstOptionSelected));
    }
  }

  Future<void> _closeWindows(List<OpenFile> files) async {
    // avoid concurrent modification exception.
    final context = getBuildContext();
    final bloc = EditorBloc.of(context);
    files = [...files];
    for (final file in files) {
      if (file.modified) {
        var result = await ConfirmationDialog.show(context: context, message: "File ${file.filename} was modified.\nShould we save it before closing?",
            actions: {
              S.of(context).save: ConfirmationDialog.actionSave,
              S.of(context).closeWithoutSaving: ConfirmationDialog.actionClose,
              S.of(context).cancel: ConfirmationDialog.actionCancel
            });
        if (result == ConfirmationDialog.actionCancel) {
          break;
        }
        if (result == ConfirmationDialog.actionSave) {
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
      final bundle = S.of(context);
      var result = await ConfirmationDialog.show(
          context: context,
          title: bundle.exitPksEdit,
          message:
            bundle.filesChangedAndExit,
          actions: {
            bundle.exitWithoutSaving: ConfirmationDialog.actionClose,
            bundle.saveAllAndExit: ConfirmationDialog.actionSave,
            bundle.cancel: ConfirmationDialog.actionCancel
          });
      if (result == ConfirmationDialog.actionCancel) {
        return;
      }
      if (result == ConfirmationDialog.actionSave) {
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
