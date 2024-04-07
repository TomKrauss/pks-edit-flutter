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
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pks_edit_flutter/bloc/editor_bloc.dart';
import 'package:pks_edit_flutter/ui/actions.dart';

///
/// Main page of the PKS Edit application.
///
class PksEditMainPage extends StatefulWidget {
  const PksEditMainPage({super.key, required this.title});
  final String title;

  @override
  State<PksEditMainPage> createState() => _PksEditMainPageState();
}

class _PksEditMainPageState extends State<PksEditMainPage> with TickerProviderStateMixin {
  late TabController controller;

  List<PksEditAction> get actions => [
    PksEditAction(id: "open-file", execute: _openFile, text: "Open File", icon: Icons.file_open),
    PksEditAction(id: "new-file", execute: _newFile, text: "New File", icon: Icons.create_outlined),
  ];

  @override
  void initState() {
    controller = TabController(
      length: 0,
      vsync: this,
      initialIndex: 0,
    );
    super.initState();
  }

  void updateTabs(OpenFileState openFileState) {
    final newCount = openFileState.files.length;
    if (controller.length != newCount || controller.index != openFileState.currentIndex) {
      final oldController = controller;
      controller = TabController(
        length: newCount,
        vsync: this,
        initialIndex: openFileState.currentIndex < 0 ? 0 : openFileState.currentIndex,
      );
      oldController.dispose();
      //setState(() {});
    }
  }

  void _handleCommandResult(CommandResult result) {

  }
  void _openFile(Object? actionContext) async {
    final bloc = EditorBloc.of(context);
    final String initialDirectory = File(".").absolute.path;
    final result = await openFile(initialDirectory: initialDirectory, confirmButtonText: "Open");
    if (result != null) {
      _handleCommandResult(await bloc.openFile(result.path));
    }
  }

  void _newFile(Object? actionContext) async {
    _handleCommandResult(await EditorBloc.of(context).newFile("Test.yaml"));
  }

  void _closeChild(OpenFile file) {
    final bloc = EditorBloc.of(context);
    if (file.modified) {

    }
    bloc.closeFile(file);
  }

  List<Widget> _buildTabs(List<OpenFile> files) {
    return files
        .map((e) => Tab(
      child: Row(children: [
        Tooltip(message: e.filename, child: Text(e.title)),
        const SizedBox(width: 4),
        InkWell(onTap: () {_closeChild(e);}, child: const Icon(Icons.close, color: Colors.white24,))]),
    ))
        .toList();
  }

  List<Widget> _buildEditors(List<OpenFile> files) {
    return files.map(
          (e) {
        final scrollController = ScrollController();
        return Scrollbar(
            controller: scrollController,
            trackVisibility: true,
            thumbVisibility: true,
            child: CodeTheme(
                data: CodeThemeData(styles: monokaiSublimeTheme),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: TextField(
                    decoration: const InputDecoration(
                        filled: true,
                        border: null,
                        focusedErrorBorder: null,
                        focusedBorder: null,
                        enabledBorder: null,
                        disabledBorder: null),
                    controller: e.controller,
                    maxLines: null,
                  ),
                )));
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
          final myActions = actions;
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
                          ))
                    ],
                  )));
        });
  }
}

class ToolBarWidget extends StatelessWidget {
  final List<PksEditAction> actions;
  final Color iconColor;

  const ToolBarWidget(
      {super.key, required this.actions, this.iconColor = Colors.blue});

  void _notImplemented() {}

  Widget _buildButton(IconData icon, Function() callback) => InkWell(
      onTap: callback,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Icon(icon, color: iconColor),
      ));

  List<Widget> _buildToolbarItems(BuildContext context) {
    return [
      ...actions.where((e) => e.displayInToolbar).map((e) => _buildButton(e.icon!, () => e.execute(null))),
      SizedBox(
          height: 30,
          child: VerticalDivider(
            indent: 3,
            endIndent: 3,
            color: Theme.of(context).dividerColor,
          )),
      _buildButton(Icons.delete, _notImplemented)
    ];
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: _buildToolbarItems(context),
  );
}

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
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Author: Tom Krauß"), Text("Design: Rolf Pahlen")],)
          ],
          applicationIcon: Image.asset("lib/assets/images/pks.png"),
          applicationVersion: info.version);
    }
  }

  List<Widget> _buildMenuBarChildren(BuildContext context) {
    return [
      SubmenuButton(
        menuChildren: actions.where((element) => element.displayInMenu).map((e) =>
            MenuItemButton(onPressed: () {e.execute(null);},
          child: Text(e.label),)).toList(),
        child: const Text("File"),
      ),
      const SubmenuButton(
        menuChildren: [],
        child: Text("Edit"),
      ),
      const SubmenuButton(
        menuChildren: [],
        child: Text("Find"),
      ),
      const SubmenuButton(
        menuChildren: [],
        child: Text("Functions"),
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
}
