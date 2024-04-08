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

import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pks_edit_flutter/bloc/editor_bloc.dart';
import 'package:pks_edit_flutter/ui/actions.dart';
import 'package:re_editor/re_editor.dart';
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
  late TabController controller;

  List<PksEditAction> getActions(OpenFileState? fileState) {
    final context = PksEditActionContext(openFileState: fileState);
    return [
      PksEditAction(
          id: "open-file",
          execute: _openFile,
          text: "Open File..",
          context: context,
          shortcut: const SingleActivator(LogicalKeyboardKey.keyO, control: true),
          group: PksEditAction.fileGroup,
          icon: Icons.file_open),
      PksEditAction(
          id: "new-file",
          execute: _newFile,
          text: "New File..",
          context: context,
          shortcut: const SingleActivator(LogicalKeyboardKey.keyN, control: true),
          group: PksEditAction.fileGroup,
          icon: Icons.create_outlined),
      PksEditAction(
          id: "save-file",
          execute: _saveFile,
          isEnabled: _canSave,
          text: "Save File",
          context: context,
          shortcut: const SingleActivator(LogicalKeyboardKey.keyS, control: true),
          description: "Save current file",
          group: PksEditAction.fileGroup,
          icon: Icons.save),
      PksEditAction(
          id: "close-window",
          execute: _closeWindow,
          text: "Close Window",
          shortcut: const SingleActivator(LogicalKeyboardKey.keyW, control: true),
          context: context,
          description: "Closes the current editor window",
          group: PksEditAction.fileGroup,
          icon: Icons.close),
      PksEditAction(
          id: "undo",
          execute: _undo,
          isEnabled: _canUndo,
          shortcut: const SingleActivator(LogicalKeyboardKey.keyZ, control: true),
          context: context,
          text: "Undo",
          group: PksEditAction.editGroup,
          icon: Icons.undo),
      PksEditAction(
          id: "redo",
          execute: _redo,
          isEnabled: _canRedo,
          shortcut: const SingleActivator(LogicalKeyboardKey.keyY, control: true),
          context: context,
          text: "Redo",
          group: PksEditAction.editGroup,
          icon: Icons.redo),
      PksEditAction(
          id: "copy",
          execute: _copy,
          isEnabled: _hasFile,
          shortcut: const SingleActivator(LogicalKeyboardKey.keyC, control: true),
          context: context,
          text: "Copy",
          group: PksEditAction.editGroup,
          icon: Icons.copy),
      PksEditAction(
          id: "cut",
          execute: _cut,
          isEnabled: _hasFile,
          shortcut: const SingleActivator(LogicalKeyboardKey.keyX, control: true),
          context: context,
          text: "Cut",
          group: PksEditAction.editGroup,
          icon: Icons.cut),
      PksEditAction(
          id: "select-all",
          execute: _selectAll,
          isEnabled: _hasFile,
          shortcut: const SingleActivator(LogicalKeyboardKey.keyA, control: true),
          context: context,
          text: "Select All",
          group: PksEditAction.editGroup),
      PksEditAction(
          id: "paste",
          execute: _paste,
          isEnabled: _hasFile,
          shortcut: const SingleActivator(LogicalKeyboardKey.keyV, control: true),
          context: context,
          text: "Paste",
          group: PksEditAction.editGroup,
          icon: Icons.paste),
    ];
  }

  @override
  void initState() {
    controller = TabController(
      length: 0,
      vsync: this,
      initialIndex: 0,
    );
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void onWindowClose() async {
    if (!mounted) {
      return;
    }
    final bloc = EditorBloc.of(context);
    if (bloc.hasChangedWindows) {
      await showDialog<void>(
          context: context,
          builder: (context) => SimpleDialog(title: const Text("Exit PKS Edit"), children: [
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(children: [
                    const Text(
                        "Some files are changed and not yet saved. Do you want to exit?"),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                            onPressed: windowManager.destroy,
                            child: const Text("Close without Save")),
                        ElevatedButton(
                            onPressed: () async {
                              final result = await bloc.saveAllModified();
                              if (result.success) {
                                windowManager.destroy();
                              } else {
                                _handleCommandResult(result);
                              }
                            },
                            child: const Text("Save All and Exit")),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cancel"))
                      ],
                    )
                  ]))
            ]));
    } else {
      windowManager.destroy();
    }
  }

  @override
  void dispose() {
    super.dispose();
    windowManager.removeListener(this);
  }

  void updateTabs(OpenFileState openFileState) {
    final newCount = openFileState.files.length;
    if (controller.length != newCount ||
        controller.index != openFileState.currentIndex) {
      final oldController = controller;
      controller = TabController(
        length: newCount,
        vsync: this,
        initialIndex:
            openFileState.currentIndex < 0 ? 0 : openFileState.currentIndex,
      );
      oldController.dispose();
      controller.addListener(() {
        openFileState.currentIndex = controller.index;
      });
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
      message ??= "An error occurred executing the command";
      await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => AlertDialog(
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

  bool _canSave(PksEditActionContext actionContext) => actionContext.openFileState?.currentFile?.modified == true;

  bool _canUndo(PksEditActionContext actionContext) {
    var f = actionContext.currentFile;
    if (f != null) {
      return f.controller.canUndo;
    }
    return false;
  }

  bool _hasFile(PksEditActionContext actionContext) => actionContext.currentFile != null;

  bool _canRedo(PksEditActionContext actionContext) {
    var f = actionContext.currentFile;
    if (f != null) {
      return f.controller.canRedo;
    }
    return false;
  }

  void _withCurrentFile(PksEditActionContext actionContext, void Function(CodeLineEditingController controller) callback) {
    var f = actionContext.currentFile;
    if (f != null) {
      callback(f.controller);
    }
  }

  void _copy(PksEditActionContext actionContext) {
    _withCurrentFile(actionContext, (controller) { controller.copy(); });
  }

  void _cut(PksEditActionContext actionContext) {
    _withCurrentFile(actionContext, (controller) { controller.cut(); });
  }

  void _paste(PksEditActionContext actionContext) {
    _withCurrentFile(actionContext, (controller) { controller.paste(); });
  }

  void _undo(PksEditActionContext actionContext) {
    _withCurrentFile(actionContext, (controller) { controller.undo(); });
  }

  void _selectAll(PksEditActionContext actionContext) {
    _withCurrentFile(actionContext, (controller) { controller.selectAll(); });
  }

  void _redo(PksEditActionContext actionContext) {
    _withCurrentFile(actionContext, (controller) { controller.redo(); });
  }

  void _openFile(PksEditActionContext actionContext) async {
    final bloc = EditorBloc.of(context);
    final String initialDirectory = File(".").absolute.path;
    final result = await openFile(
        initialDirectory: initialDirectory, confirmButtonText: "Open");
    if (result != null) {
      await _handleCommandResult(await bloc.openFile(result.path));
    }
  }

  void _saveFile(PksEditActionContext actionContext) async {
    final bloc = EditorBloc.of(context);
    _handleCommandResult(await bloc.saveActiveFile());
  }

  void _newFile(PksEditActionContext actionContext) async {
    _handleCommandResult(await EditorBloc.of(context).newFile("Test.yaml"));
  }

  void _closeWindow(PksEditActionContext actionContext) {
    var file = actionContext.currentFile;
    if (file == null) {
      return;
    }
    final bloc = EditorBloc.of(context);
    if (file.modified) {}
    bloc.closeFile(file);
  }

  List<Widget> _buildTabs(OpenFileState state) => state.files
        .map((e) => Tab(
              child: Row(children: [
                Tooltip(message: e.filename, child: Text(e.title)),
                const SizedBox(width: 4),
                InkWell(
                    onTap: () {
                      _closeWindow(PksEditActionContext(openFileState: state, currentFile: e));
                    },
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).dividerColor,
                    ))
              ]),
            ))
        .toList();

  List<Widget> _buildEditors(List<OpenFile> files) {
    final bloc = EditorBloc.of(context);
    return files.map(
      (e) => CodeEditor(
          onChanged: e.onChanged,
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
          controller: e.controller,
          style: CodeEditorStyle(
              fontFamily: bloc.editorConfiguration.defaultFontFace,
              codeTheme: CodeHighlightTheme(
                  theme: bloc.editorConfiguration.themeName == "dark" ? atomOneDarkTheme : atomOneLightTheme,
                  languages: {
                e.language.name: CodeHighlightThemeMode(mode: e.language.mode)
              })),
        ),
    ).toList();
  }

  Map<ShortcutActivator, VoidCallback> _buildShortcutMap(List<PksEditAction> actions) {
    final result = <ShortcutActivator, VoidCallback>{};
    for (final action in actions) {
      if (action.shortcut is ShortcutActivator && action.onPressed != null) {
        result[action.shortcut as ShortcutActivator] = action.onPressed!;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: EditorBloc.of(context).openFileStream,
        builder: (context, snapshot) {
          var files = snapshot.data;
          if (files != null) {
            updateTabs(files);
          }
          final myActions = getActions(files);
          files ??= OpenFileState(files: [], currentIndex: 0);
          return Scaffold(
              body: CallbackShortcuts(bindings: _buildShortcutMap(myActions), child: Focus(
                    autofocus: true,
                      child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                  width: double.infinity,
                  child: MenuBarWidget(actions: myActions)),
              ToolBarWidget(actions: myActions),
              TabBar(
                  controller: controller,
                  tabAlignment: TabAlignment.start,
                  isScrollable: true,
                  tabs: _buildTabs(files)),
              Expanded(
                  child: TabBarView(
                controller: controller,
                children: _buildEditors(files.files),
              )),
              StatusBarWidget(fileState: files)
            ],
          ))));
        });
}

///
/// Displays a tool bar containing the tool bar triggered actions of PKS EDIT
///
class ToolBarWidget extends StatelessWidget {
  final List<PksEditAction> actions;
  final Color iconColor;

  const ToolBarWidget(
      {super.key, required this.actions, this.iconColor = Colors.blue});

  Widget _buildButton(PksEditAction action, void Function()? callback) => Tooltip(
      message: action.description,
      child: InkWell(
          onTap: callback,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Icon(action.icon,
                color: callback == null ? Colors.grey : iconColor),
          )));

  Iterable<Widget> _buildItemsForGroup(BuildContext context, String group) => actions
        .where((e) => e.displayInToolbar && e.group == group)
        .map((e) => _buildButton(e, e.onPressed));

  List<Widget> _buildToolbarItems(BuildContext context) => [
      ..._buildItemsForGroup(context, PksEditAction.fileGroup),
      VerticalDivider(
        indent: 3,
        endIndent: 3,
        color: Theme.of(context).dividerColor,
      ),
      ..._buildItemsForGroup(context, PksEditAction.editGroup),
    ];

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
          child: Container(
              color: Theme.of(context).appBarTheme.backgroundColor,
              padding: const EdgeInsets.all(4),
              child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildToolbarItems(context),
      )));
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
        menuChildren: _buildMenuForGroup(context, PksEditAction.functionGroup),
        child: const Text("Functions"),
      ),
      const SubmenuButton(
        menuChildren: [],
        child: Text("Macro"),
      ),
      const SubmenuButton(
        menuChildren: [],
        child: Text("Settings"),
      ),
      const SubmenuButton(
        menuChildren: [],
        child: Text("Extras"),
      ),
      const SubmenuButton(
        menuChildren: [],
        child: Text("Window"),
      ),
      SubmenuButton(
        menuChildren: [
          MenuItemButton(
              child: const Text("About..."),
              onPressed: () {
                _showAbout(context);
              })
        ],
        child: const Text("?"),
      ),
    ];

  @override
  Widget build(BuildContext context) => MenuBar(children: _buildMenuBarChildren(context));

  List<Widget> _buildMenuForGroup(BuildContext context, String group) {
    final List<Widget> result = [];
    result.addAll(actions
        .where((element) => element.displayInMenu && element.group == group)
        .map((e) => MenuItemButton(
              onPressed: e.onPressed,
              shortcut: e.shortcut,
              child: Text(e.label),
            )));
    return result;
  }

  List<Widget> _buildFileMenu(BuildContext context) {
    final List<Widget> result =
        _buildMenuForGroup(context, PksEditAction.fileGroup);
    result.add(const Divider());
    final bloc = EditorBloc.of(context);
    for (var of in bloc.openFiles) {
      result.add(MenuItemButton(
          onPressed: () {
            bloc.openFile(of);
          },
          child: Text(of)));
    }
    return result;
  }
}

class StatusBarWidget extends StatelessWidget {
  final OpenFileState fileState;
  const StatusBarWidget({super.key, required this.fileState});

  @override
  Widget build(BuildContext context) {
      var current = fileState.currentFile;
      var row = (current == null)
          ? const Row(
              children: [Text("")],
            )
          : IntrinsicHeight(
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(current.filename),
                Row(children: [
                  Text(current.encoding.name),
                  VerticalDivider(color: Theme.of(context).dividerColor, width: 20),
                  Text(current.language.name)
                ])
              ],
            ));
      return Container(
          color: Theme.of(context).appBarTheme.backgroundColor,
          child: Padding(padding: const EdgeInsets.all(4), child: row));
  }
}
