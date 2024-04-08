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
          group: PksEditAction.fileGroup,
          icon: Icons.file_open),
      PksEditAction(
          id: "new-file",
          execute: _newFile,
          text: "New File..",
          context: context,
          group: PksEditAction.fileGroup,
          icon: Icons.create_outlined),
      PksEditAction(
          id: "save-file",
          execute: _saveFile,
          isEnabled: _canSave,
          text: "Save File",
          context: context,
          description: "Save current file",
          group: PksEditAction.fileGroup,
          icon: Icons.save),
      PksEditAction(
          id: "undo",
          execute: _undo,
          isEnabled: _canUndo,
          context: context,
          text: "Undo",
          group: PksEditAction.editGroup,
          icon: Icons.undo),
      PksEditAction(
          id: "redo",
          execute: _redo,
          isEnabled: _canRedo,
          context: context,
          text: "Redo",
          group: PksEditAction.editGroup,
          icon: Icons.redo),
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
      await showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(title: const Text("Exit PKS Edit"), children: [
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
                            onPressed: () {
                              windowManager.destroy();
                            },
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
            ]);
          });
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
      await showDialog(
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

  bool _canSave(PksEditActionContext actionContext) {
    return actionContext.openFileState?.currentFileSync?.modified == true;
  }


  bool _canUndo(PksEditActionContext actionContext) {
    var f = actionContext.openFileState?.currentFileSync;
    if (f != null) {
      return f.controller.canUndo;
    }
    return false;
  }

  bool _canRedo(PksEditActionContext actionContext) {
    var f = actionContext.openFileState?.currentFileSync;
    if (f != null) {
      return f.controller.canRedo;
    }
    return false;
  }

  void _undo(PksEditActionContext actionContext) {
    var f = actionContext.openFileState?.currentFileSync;
    if (f != null) {
      f.controller.undo();
    }
  }

  void _redo(PksEditActionContext actionContext) {
    var f = actionContext.openFileState?.currentFileSync;
    if (f != null) {
      f.controller.redo();
    }
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

  void _closeChild(OpenFile file) {
    final bloc = EditorBloc.of(context);
    if (file.modified) {}
    bloc.closeFile(file);
  }

  List<Widget> _buildTabs(List<OpenFile> files) {
    return files
        .map((e) => Tab(
              child: Row(children: [
                Tooltip(message: e.filename, child: Text(e.title)),
                const SizedBox(width: 4),
                InkWell(
                    onTap: () {
                      _closeChild(e);
                    },
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).dividerColor,
                    ))
              ]),
            ))
        .toList();
  }

  List<Widget> _buildEditors(List<OpenFile> files) {
    return files.map(
      (e) {
        return CodeEditor(
          onChanged: e.onChanged,
          indicatorBuilder:
              (context, editingController, chunkController, notifier) {
            return Row(
              children: [
                DefaultCodeLineNumber(
                  controller: editingController,
                  notifier: notifier,
                ),
                DefaultCodeChunkIndicator(
                    width: 20, controller: chunkController, notifier: notifier)
              ],
            );
          },
          controller: e.controller,
          style: CodeEditorStyle(
            fontFamily: Platform.isWindows ? "Consolas" : "Courier New",
              codeTheme: CodeHighlightTheme(
                  theme: atomOneLightTheme,
                  languages: {
                e.language.name: CodeHighlightThemeMode(mode: e.language.mode)
              })),
        );
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: EditorBloc.of(context).openFileStream,
        builder: (context, snapshot) {
          var files = snapshot.data;
          if (files != null) {
            updateTabs(files);
          }
          final myActions = getActions(files);
          files ??= OpenFileState(files: [], currentIndex: 0);
          return Scaffold(
              body: Center(
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
                  tabs: _buildTabs(files.files)),
              Expanded(
                  child: TabBarView(
                controller: controller,
                children: _buildEditors(files.files),
              )),
              StatusBarWidget(fileState: files)
            ],
          )));
        });
  }
}

///
/// Displays a tool bar containing the tool bar triggered actions of PKS EDIT
///
class ToolBarWidget extends StatelessWidget {
  final List<PksEditAction> actions;
  final Color iconColor;

  const ToolBarWidget(
      {super.key, required this.actions, this.iconColor = Colors.blue});

  Widget _buildButton(PksEditAction action, Function()? callback) => Tooltip(
      message: action.description,
      child: InkWell(
          onTap: callback,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Icon(action.icon,
                color: callback == null ? Colors.grey : iconColor),
          )));

  Iterable<Widget> _buildItemsForGroup(BuildContext context, String group) {
    return actions
        .where((e) => e.displayInToolbar && e.group == group)
        .map((e) => _buildButton(e, e.onPressed));
  }

  List<Widget> _buildToolbarItems(BuildContext context) {
    return [
      ..._buildItemsForGroup(context, PksEditAction.fileGroup),
      VerticalDivider(
        indent: 3,
        endIndent: 3,
        color: Theme.of(context).dividerColor,
      ),
      ..._buildItemsForGroup(context, PksEditAction.editGroup),
    ];
  }

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

  List<Widget> _buildMenuBarChildren(BuildContext context) {
    return [
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
  }

  @override
  Widget build(BuildContext context) {
    return MenuBar(children: _buildMenuBarChildren(context));
  }

  List<Widget> _buildMenuForGroup(BuildContext context, String group) {
    final List<Widget> result = [];
    result.addAll(actions
        .where((element) => element.displayInMenu && element.group == group)
        .map((e) => MenuItemButton(
              onPressed: e.onPressed,
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
      var current = fileState.currentFileSync;
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
