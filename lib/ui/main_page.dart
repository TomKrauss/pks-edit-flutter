//
// main_page.dart
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
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:pks_edit_flutter/bloc/editor_bloc.dart';
import 'package:pks_edit_flutter/config/pks_ini.dart';
import 'package:pks_edit_flutter/ui/actions.dart';
import 'package:pks_edit_flutter/ui/dialog/confirmation_dialog.dart';
import 'package:pks_edit_flutter/ui/dialog/input_dialog.dart';
import 'package:pks_edit_flutter/ui/dialog/settings_dialog.dart';
import 'package:pks_edit_flutter/ui/status_bar_widget.dart';
import 'package:pks_edit_flutter/ui/tool_bar_widget.dart';
import 'package:re_editor/re_editor.dart';
import 'package:sound_library/sound_library.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:window_manager/window_manager.dart';

///
/// Main page of the PKS Edit application.
///
class PksEditMainPage extends StatefulWidget {
  const PksEditMainPage({super.key, required this.title});
  final String title;

  @override
  State<PksEditMainPage> createState() => _PksEditMainPageState();
}

class _PksEditMainPageState extends State<PksEditMainPage>
    with TickerProviderStateMixin, WindowListener {
  late EditorBloc bloc;
  late StreamSubscription<OpenFile> _externalFileSubscription;
  late final FocusNode _searchbarFocusNode;
  late final FocusNode _editorFocusNode;

  List<PksEditAction> getActions(OpenFileState? fileState) {
    final context = PksEditActionContext(openFileState: fileState);
    return [
      PksEditAction(
          id: "open-file",
          execute: _openFile,
          text: "Open File...",
          context: context,
          shortcut:
              const SingleActivator(LogicalKeyboardKey.keyO, control: true),
          group: PksEditAction.fileGroup,
          icon: Icons.file_open),
      PksEditAction(
          id: "new-file",
          execute: _newFile,
          text: "New File...",
          context: context,
          shortcut:
              const SingleActivator(LogicalKeyboardKey.keyN, control: true),
          group: PksEditAction.fileGroup,
          icon: Icons.create_outlined),
      PksEditAction(
          id: "save-file",
          execute: _saveFile,
          isEnabled: _canSave,
          text: "Save File",
          context: context,
          shortcut:
              const SingleActivator(LogicalKeyboardKey.keyS, control: true),
          description: "Save current file",
          group: PksEditAction.fileGroup,
          icon: Icons.save),
      PksEditAction(
          id: "save-file-as",
          execute: _saveFileAs,
          isEnabled: _hasFile,
          text: "Save File As...",
          context: context,
          description: "Save current file under new name",
          group: PksEditAction.fileGroup,
          icon: Icons.save_as),
      PksEditAction(
          id: "close-window",
          execute: _closeWindow,
          text: "Close Window",
          shortcut:
              const SingleActivator(LogicalKeyboardKey.keyW, control: true),
          context: context,
          description: "Closes the current editor window",
          group: PksEditAction.fileGroup,
          icon: Icons.close),
      PksEditAction(
          id: "close-all-windows",
          execute: _closeAllWindows,
          text: "Close All Windows",
          shortcut:
          const SingleActivator(LogicalKeyboardKey.keyW, control: true, shift: true),
          context: context,
          icon: Icons.done_all,
          description: "Closes all editor windows",
          group: PksEditAction.fileGroup),
      PksEditAction(
          id: "close-all-but-active",
          execute: _closeAllButActive,
          text: "Close All other Windows",
          shortcut:
          const SingleActivator(LogicalKeyboardKey.keyW, control: true, alt: true),
          context: context,
          icon: Icons.clear_all,
          description: "Closes all other editor windows but current",
          group: PksEditAction.fileGroup),
      PksEditAction(
          id: "exit",
          execute: _exit,
          text: "Exit",
          shortcut: const SingleActivator(LogicalKeyboardKey.f4, alt: true),
          context: context,
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
          context: context,
          text: "Undo",
          group: PksEditAction.editGroup,
          icon: Icons.undo),
      PksEditAction(
          id: "redo",
          execute: _redo,
          isEnabled: _canRedo,
          shortcut:
              const SingleActivator(LogicalKeyboardKey.keyY, control: true),
          context: context,
          text: "Redo",
          group: PksEditAction.editGroup,
          icon: Icons.redo),
      PksEditAction(
          id: "copy",
          execute: _copy,
          isEnabled: _hasFile,
          shortcut:
              const SingleActivator(LogicalKeyboardKey.keyC, control: true),
          context: context,
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
          context: context,
          text: "Cut",
          group: PksEditAction.editGroup,
          icon: Icons.cut),
      PksEditAction(
          id: "paste",
          execute: _paste,
          isEnabled: _hasWriteableFile,
          shortcut:
              const SingleActivator(LogicalKeyboardKey.keyV, control: true),
          context: context,
          text: "Paste",
          group: PksEditAction.editGroup,
          icon: Icons.paste),
      PksEditAction(
          id: "select-all",
          execute: _selectAll,
          isEnabled: _hasFile,
          shortcut: const SingleActivator(LogicalKeyboardKey.keyA, control: true),
          context: context,
          icon: Icons.select_all,
          separatorBefore: true,
          text: "Select All",
          group: PksEditAction.editGroup),
      PksEditAction(
          id: "cycle-window-forward",
          execute: _cycleWindowForward,
          shortcut: const SingleActivator(LogicalKeyboardKey.tab, control: true),
          context: context,
          icon: Icons.rotate_left,
          text: "Cycle window forward",
          group: PksEditAction.windowGroup),
      PksEditAction(
          id: "cycle-window-backward",
          execute: _cycleWindowBackward,
          shortcut:
          const SingleActivator(LogicalKeyboardKey.tab, control: true, shift: true),
          context: context,
          icon: Icons.rotate_right,
          text: "Cycle window backward",
          group: PksEditAction.windowGroup),
      PksEditAction(
          id: "goto-line",
          execute: _gotoLine,
          isEnabled: _hasFile,
          shortcut:
          const SingleActivator(LogicalKeyboardKey.keyG, control: true),
          context: context,
          icon: Icons.numbers_sharp,
          text: "Goto line",
          group: PksEditAction.findGroup),
      PksEditAction(
          id: "change-settings",
          execute: _changeSettings,
          text: "Change Settings...",
          context: context,
          shortcut:
          const SingleActivator(LogicalKeyboardKey.numpadMultiply, alt: true),
          group: PksEditAction.extraGroup,
          icon: Icons.create_outlined),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = EditorBloc.of(context);
    _externalFileSubscription = bloc.externalFileChangeStream.listen((event) async {
        if ((await ConfirmationDialog.show(context: context, message: "File ${event.title} is changed. Do you want to reload it?")) == 'yes') {
          final result = await bloc.abandonFile(event);
          _handleCommandResult(result);
        }
    });
  }

  @override
  void initState() {
    windowManager.addListener(this);
    _searchbarFocusNode = FocusNode();
    _editorFocusNode = FocusNode();
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
    _externalFileSubscription.cancel();
    _searchbarFocusNode.dispose();
    _editorFocusNode.dispose();
    windowManager.removeListener(this);
  }

  @override
  void onWindowClose() async {
    if (!mounted) {
      return;
    }
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
          _handleCommandResult(result);
          return;
        }
      }
    }
    if (mounted) {
      bloc.exitApp(context);
    }
  }

  ///
  /// Handle the result of executing a command. Currently three different situations are supported:
  /// - the command was executed with success and no message is passed - do nothing
  /// - the command was executed with success and a message is passed - show an info popup in the snackbar
  /// - the command was executed with an error - show a modal dialog presenting the error.
  ///
  Future<void> _handleCommandResult(CommandResult result) async {
    if (!mounted) {
      return;
    }
    var message = result.message;
    if (result.success) {
      if (message != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } else {
      var config = PksIniConfiguration.of(context).configuration;
      if (config.playSoundOnError) {
        SoundPlayer.play(config.errorSound);
      }
      message ??= "An error occurred executing the command";
      if (config.showErrorsInToast) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.errorContainer,));
      } else {
        await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) =>
                AlertDialog(
                  content: Text(message!),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("OK"))
                  ],
                ));
      }
    }
  }

  Future<void> _changeSettings(PksEditActionContext actionContext) async {
    await SettingsDialog.show(context: context);
  }

  bool _canSave(PksEditActionContext actionContext) =>
      actionContext.openFileState?.currentFile?.modified == true;

  bool _canUndo(PksEditActionContext actionContext) {
    var f = actionContext.currentFile;
    if (f != null) {
      return f.controller.canUndo;
    }
    return false;
  }

  bool _hasFile(PksEditActionContext actionContext) =>
      actionContext.currentFile != null;

  bool _hasWriteableFile(PksEditActionContext actionContext) =>
      actionContext.currentFile != null && actionContext.currentFile?.readOnly != true;

  bool _canRedo(PksEditActionContext actionContext) {
    var f = actionContext.currentFile;
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

  void _copy(PksEditActionContext actionContext) {
    _withCurrentFile(actionContext, (controller) {
      controller.copy();
    });
  }

  void _cut(PksEditActionContext actionContext) {
    _withCurrentFile(actionContext, (controller) {
      controller.cut();
    });
  }

  void _paste(PksEditActionContext actionContext) {
    _withCurrentFile(actionContext, (controller) {
      controller.paste();
    });
  }

  void _undo(PksEditActionContext actionContext) {
    _withCurrentFile(actionContext, (controller) {
      controller.undo();
    });
  }

  void _selectAll(PksEditActionContext actionContext) {
    _withCurrentFile(actionContext, (controller) {
      controller.selectAll();
    });
  }

  void _redo(PksEditActionContext actionContext) {
    _withCurrentFile(actionContext, (controller) {
      controller.redo();
    });
  }

  void _exit(PksEditActionContext actionContext) {
    onWindowClose();
  }

  Future<void> _openFile(PksEditActionContext actionContext) async {
    final String initialDirectory = File(".").absolute.path;
    final result = await openFile(
        initialDirectory: initialDirectory,
        acceptedTypeGroups: bloc.editingConfigurations.getFileGroups(actionContext.currentFile?.filename ?? ""),
        confirmButtonText: "Open");
    if (result != null) {
      await _handleCommandResult(await bloc.openFile(result.path));
    }
  }

  void _cycleWindowForward(PksEditActionContext actionContext) {
    bloc.cycleWindow(1);
  }

  void _cycleWindowBackward(PksEditActionContext actionContext) {
    bloc.cycleWindow(-1);
  }

  void _saveFileAs(PksEditActionContext actionContext) async {
    final filename = bloc.suggestNewFilename(actionContext.currentFile!.filename);
    final String initialDirectory = path.dirname(filename);
    final result = await getSaveLocation(
        initialDirectory: initialDirectory,
        suggestedName: path.basename(filename),
        acceptedTypeGroups: bloc.editingConfigurations.getFileGroups(filename),
        confirmButtonText: "Save");
    if (result != null) {
      _handleCommandResult(await bloc.saveActiveFile(filename: result.path));
    }
  }

  void _saveFile(PksEditActionContext actionContext) async {
    _handleCommandResult(await bloc.saveActiveFile());
  }

  void _gotoLine(PksEditActionContext actionContext) async {
    var controller = actionContext.currentFile?.controller;
    if (controller == null) {
      return;
    }
    final result = await InputDialog.show(context: context, arguments:
      InputDialogArguments(context: actionContext, title: "Goto Line",
          keyboardType: TextInputType.number,
          inputLabel: "Line number", initialValue: "${controller.selection.start.index+1}"));
    if (result != null) {
      var newLine = int.tryParse(result.selectedText);
      if (newLine != null) {
        if (newLine < 0 || newLine >= controller.lineCount) {
          _handleCommandResult(CommandResult(success: true, message: "Line number of of range (0 - ${controller.lineCount})"));
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

  void _newFile(PksEditActionContext actionContext) async {
    final newFilename = bloc.suggestNewFilename(actionContext.currentFile?.filename);
    final result = await InputDialog.show(context: context, arguments:
        InputDialogArguments(context: actionContext, title: "New File", inputLabel: "File name",
            options: {"Initialize with Template": true},
            initialValue: path.basename(newFilename)));
    if (result != null) {
      _handleCommandResult(await bloc.newFile(path.join(path.dirname(newFilename), result.selectedText), insertTemplate: result.firstOptionSelected));
    }
  }

  Future<void> _closeWindows(List<OpenFile> files) async {
    // avoid concurrent modification exception.
    files = [...files];
    for (final file in files) {
      if (file.modified) {
        var result = await ConfirmationDialog.show(context: context, message: "File ${file.filename} was modified.\nShould we save it before closing?",
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
            _handleCommandResult(commandResult);
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
  void _closeAllButActive(PksEditActionContext actionContext) {
    var files = actionContext.openFileState?.files.where((element) => element != actionContext.openFileState?.currentFile).toList();
    if (files != null) {
      _closeWindows(files);
    }
  }

  void _closeAllWindows(PksEditActionContext actionContext) {
    _closeWindows(actionContext.openFileState?.files ?? []);
  }

  void _closeWindow(PksEditActionContext actionContext) {
    var file = actionContext.currentFile;
    if (file == null) {
      return;
    }
    _closeWindows([file]);
  }

  void _toggleSearchBarFocus() {
    if (_searchbarFocusNode.hasFocus) {
      _editorFocusNode.requestFocus();
    } else {
      _searchbarFocusNode.requestFocus();
    }
  }

  Map<ShortcutActivator, VoidCallback> _buildShortcutMap(
      List<PksEditAction> actions) {
    final result = <ShortcutActivator, VoidCallback>{};
    for (final action in actions) {
      if (action.shortcut is ShortcutActivator && action.onPressed != null) {
        result[action.shortcut as ShortcutActivator] = action.onPressed!;
      }
    }
    result[const SingleActivator(LogicalKeyboardKey.keyS, alt: true, control: true)] = _toggleSearchBarFocus;
    return result;
  }

  DropOperation _onDropOver(DropOverEvent event) => event.session.allowedOperations.firstOrNull ?? DropOperation.none;

  Future<void> _onPerformDrop(PerformDropEvent event) async {
    await Future.wait(
      event.session.items.map(
            (e) async {
              e.dataReader?.getValue(Formats.fileUri, (value) async {
                if (value is Uri) {
                  _handleCommandResult(await bloc.openFile(value.toFilePath(windows: Platform.isWindows)));
                }
              });
            }
      ),
    );
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: bloc.openFileStream,
      builder: (context, snapshot) {
        var files = snapshot.data;
        final myActions = getActions(files);
        files ??= OpenFileState(files: [], currentIndex: 0);
        final configuration = PksIniConfiguration.of(context).configuration;
        return CallbackShortcuts(
                bindings: _buildShortcutMap(myActions),
                child: Focus(
                    child: Scaffold(
                        body: DropRegion(formats: const [
                          Formats.plainTextFile,
                        ], onDropOver: _onDropOver,
                            onPerformDrop: _onPerformDrop, child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                            width: double.infinity,
                            child: MenuBarWidget(actions: myActions)),
                        if (configuration.showToolbar)
                        ToolBarWidget(currentFile: files.currentFile, actions: myActions,
                          focusNode: _searchbarFocusNode,
                          ),
                        Expanded(child: EditorDockPanelWidget(state: files, files: files.files, editorFocusNode: _editorFocusNode, closeFile: (file) {
                          _closeWindow(PksEditActionContext(openFileState: files, currentFile: file));
                        })),
                        if (configuration.showStatusbar)
                        StatusBarWidget(fileState: files)
                      ],
                    )))));
      });
}

///
/// Represents one "dock" in PKS-Edit displaying a list of files selectable using tabs.
///
class EditorDockPanelWidget extends StatefulWidget {
  final String dockName;
  final List<OpenFile> files;
  final OpenFileState state;
  final FocusNode editorFocusNode;
  final void Function(OpenFile) closeFile;
  const EditorDockPanelWidget({this.dockName = OpenFile.dockNameDefault,
    required this.state, required this.files, required this.closeFile, required this.editorFocusNode, super.key});

  @override
  State<EditorDockPanelWidget> createState() => _EditorDockPanelWidgetState();
}

class _EditorDockPanelWidgetState extends State<EditorDockPanelWidget> with TickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 0, vsync: this);
  }

  ///
  /// Update the tab controller to reflect a changed number of tabs.
  ///
  void updateTabs(List<OpenFile> files) {
    final newCount = files.length;
    int idx = controller.index;
    final selected = widget.state.currentFile;
    var newIdx = selected == null ? -1 : widget.files.indexOf(selected);
    if (newIdx < 0) {
      newIdx = idx;
    }
    if (controller.length != newCount) {
      final oldController = controller;
      controller = TabController(
        length: newCount,
        vsync: this,
        initialIndex: newIdx,
      );
      oldController.dispose();
      controller.addListener(() {
        widget.state.currentFile = widget.files[controller.index];
      });
    } else {
      controller.index = newIdx;
    }
  }

  List<Widget> _buildTabs() => widget.files
      .map((e) => Tab(
    child: Row(children: [
      FaIcon(e.icon, size: 16),
      const SizedBox(width: 4),
      Tooltip(message: e.filename, child: Text(e.title)),
      const SizedBox(width: 4),
      InkWell(
          onTap: () {
            widget.closeFile(e);
          },
          child: Icon(
            Icons.close,
            color: Theme.of(context).dividerColor,
          ))
    ]),
  ))
      .toList();

  Widget _buildEditor(OpenFile file) {
    final bloc = EditorBloc.of(context);
    file.adjustCaret();
    final configuration = PksIniConfiguration.of(context).configuration;
    return CodeEditor(
        autofocus: true,
        readOnly: file.readOnly,
        onChanged: file.onChanged,
        border: Border(top: BorderSide(color: Theme.of(context).appBarTheme.backgroundColor ?? Colors.transparent)),
        focusNode: widget.editorFocusNode,
        findController: file.findController,
        indicatorBuilder:
            (context, editingController, chunkController, notifier) => Row(
          children: [
            DefaultCodeLineNumber(
              controller: editingController,
              notifier: notifier,
            ),
            DefaultCodeChunkIndicator(
                width: 20, controller: chunkController, notifier: notifier)
          ],
        ),
        controller: file.controller,
        style: CodeEditorStyle(
            fontFamily: configuration.defaultFont,
            codeTheme: CodeHighlightTheme(
                theme: bloc.themes.currentTheme.isDark
                    ? atomOneDarkTheme
                    : atomOneLightTheme,
                languages: {
                  file.language.name:
                  CodeHighlightThemeMode(mode: file.language.mode)
                })));
  }

  @override
  Widget build(BuildContext context) {
    updateTabs(widget.files);
    return Column(children: [
      TabBar(
          controller: controller,
          tabAlignment: TabAlignment.start,
          isScrollable: true,
          tabs: _buildTabs()),
      Expanded(
          child: widget.files.isEmpty ? const SizedBox() : _buildEditor(widget.files[controller.index])),
    ],);
  }
}

///
/// Displays a menu bar containing the menu bar triggered actions of PKS EDIT
///
class MenuBarWidget extends StatelessWidget {
  final List<PksEditAction> actions;
  const MenuBarWidget({super.key, required this.actions});

  void _showAbout(BuildContext context) async {
    final info = await PackageInfo.fromPlatform();
    if (context.mounted) {
      showAboutDialog(
          context: context,
          applicationName: "PKS Edit",
          children: [
            const Text("Flutter version of the famous Atari Code Editor"),
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

  List<Widget> _buildMenuBarChildren(BuildContext context) => [
        SubmenuButton(
          menuChildren: _buildFileMenu(context),
          child: const Text("File"),
        ),
        SubmenuButton(
          menuChildren: _buildMenuForGroup(context, PksEditAction.editGroup),
          child: const Text("Edit"),
        ),
        SubmenuButton(
          menuChildren: _buildMenuForGroup(context, PksEditAction.findGroup),
          child: const Text("Find"),
        ),
        SubmenuButton(
          menuChildren:
              _buildMenuForGroup(context, PksEditAction.functionGroup),
          child: const Text("Functions"),
        ),
        const SubmenuButton(
          menuChildren: [],
          child: Text("Macro"),
        ),
        SubmenuButton(
          menuChildren: _buildMenuForGroup(context, PksEditAction.extraGroup),
          child: const Text("Extras"),
        ),
        SubmenuButton(
          menuChildren: _buildMenuForGroup(context, PksEditAction.windowGroup),
          child: const Text("Window"),
        ),
        SubmenuButton(
          menuChildren: [
            _createMenuButton(
                context, "About...", null, null, () {
                  _showAbout(context);
                })
          ],
          child: const Text("?"),
        ),
      ];

  @override
  Widget build(BuildContext context) =>
      MenuBar(children: _buildMenuBarChildren(context));

  MenuItemButton _createMenuButton(BuildContext context, String label, IconData? icon,
        MenuSerializableShortcut? shortcut, void Function()? onPressed) =>
    MenuItemButton(
        leadingIcon: icon == null ?
          SizedBox(width: Theme.of(context).menuButtonTheme.style?.iconSize?.resolve({MaterialState.selected}) ?? 24) :
        Icon(icon),
        onPressed: onPressed, shortcut: shortcut, child: Text(label));

  List<Widget> _buildMenuForGroup(BuildContext context, String group) {
    final List<Widget> result = [];
    actions
        .where((element) => element.displayInMenu && element.group == group)
        .forEach((e) {
      if (e.separatorBefore) {
        result.add(const Divider());
      }
      result.add(_createMenuButton(context, e.label, e.icon, e.shortcut, e.onPressed));
    });
    return result;
  }

  String _shortenFileName(String filename) {
    if (filename.length < 40) {
      return filename;
    }
    var segments = path.split(filename);
    if (segments.length < 4) {
      return filename;
    }
    return path.join(segments.first, segments[1], "...", segments[segments.length-2], segments.last);
  }

  List<Widget> _buildFileMenu(BuildContext context) {
    final List<Widget> result =
        _buildMenuForGroup(context, PksEditAction.fileGroup);
    result.add(const Divider());
    final bloc = EditorBloc.of(context);
    for (var of in bloc.openFiles) {
      result.add(_createMenuButton(context, _shortenFileName(of), null, null,  () {
            bloc.openFile(of);
          }));
    }
    return result;
  }
}

