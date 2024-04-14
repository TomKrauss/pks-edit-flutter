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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:pks_edit_flutter/actions/shortcuts.dart';
import 'package:pks_edit_flutter/bloc/editor_bloc.dart';
import 'package:pks_edit_flutter/config/pks_ini.dart';
import 'package:pks_edit_flutter/actions/actions.dart';
import 'package:pks_edit_flutter/ui/dialog/confirmation_dialog.dart';
import 'package:pks_edit_flutter/ui/status_bar_widget.dart';
import 'package:pks_edit_flutter/ui/tool_bar_widget.dart';
import 'package:re_editor/re_editor.dart';
import 'package:sound_library/sound_library.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:window_manager/window_manager.dart';
import 'package:pks_edit_flutter/generated/l10n.dart';
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
  PksEditActionContext _actionContext = PksEditActionContext(openFileState: null);

  late final PksEditActions actions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = EditorBloc.of(context);
    _externalFileSubscription = bloc.externalFileChangeStream.listen((event) async {
        if ((await ConfirmationDialog.show(context: context, message: S.of(context).reloadChangedFile(event.title))) == 'yes') {
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
    actions = PksEditActions(getBuildContext: () => context,
        handleCommandResult: _handleCommandResult, getActionContext: () => _actionContext,
        additionalActions: { const SingleActivator(LogicalKeyboardKey.keyS, alt: true, control: true): _toggleSearchBarFocus }
    );
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
    actions.execute(PksEditActions.actionExit);
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
      message ??= S.of(context).anErrorOccurred;
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

  void _toggleSearchBarFocus() {
    if (_searchbarFocusNode.hasFocus) {
      _editorFocusNode.requestFocus();
    } else {
      _searchbarFocusNode.requestFocus();
    }
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
        _actionContext = PksEditActionContext(openFileState: files);
        final myActions = actions;
        final ac = actions.actions.values;
        files ??= OpenFileState(files: [], currentIndex: 0);
        final configuration = PksIniConfiguration.of(context).configuration;
        return CallbackShortcuts(
                bindings: myActions.shortcuts,
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
                            child: MenuBarWidget(actions: ac)),
                        if (configuration.showToolbar)
                        ToolBarWidget(currentFile: files.currentFile, actions: ac,
                          focusNode: _searchbarFocusNode,
                          ),
                        Expanded(child: EditorDockPanelWidget(state: files, files: files.files, editorFocusNode: _editorFocusNode, closeFile: (file) {
                          _actionContext = PksEditActionContext(openFileState: files, currentFile: file);
                          actions.execute(PksEditActions.actionCloseWindow);
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

  List<Widget> _buildTabs(bool compactMode) => widget.files
      .map((e) => Tab(
    child: Row(children: [
      FaIcon(e.icon, size: 16),
      const SizedBox(width: 4),
      Tooltip(message: e.filename, child: Text("#${e.index} ${compactMode ? e.title : e.filename}")),
      const SizedBox(width: 4),
      InkWell(
          onTap: () {
            widget.closeFile(e);
          },
          child: Icon(
            Icons.close,
            color: Theme.of(context).dividerColor,
          )),
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
        shortcutsActivatorsBuilder: const PksEditCodeShortcutsActivatorsBuilder(),
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
    var config = PksIniConfiguration.of(context).configuration;
    var labelStyle = Theme.of(context).textTheme.bodySmall;
    var unselectedLabelStyle = labelStyle?.copyWith(color: Theme.of(context).dividerColor);
    labelStyle = labelStyle?.copyWith(fontWeight: FontWeight.bold);
    return Column(children: [
      TabBar(
          controller: controller,
          tabAlignment: TabAlignment.start,
          padding: EdgeInsets.zero,
          labelStyle: labelStyle,
          unselectedLabelStyle: unselectedLabelStyle,
          isScrollable: true,
          tabs: _buildTabs(config.compactEditorTabs)),
      Expanded(
          child: widget.files.isEmpty ? const SizedBox() : _buildEditor(widget.files[controller.index])),
    ],);
  }
}

///
/// Displays a menu bar containing the menu bar triggered actions of PKS EDIT
///
class MenuBarWidget extends StatelessWidget {
  final Iterable<PksEditAction> actions;
  const MenuBarWidget({super.key, required this.actions});

  void _showAbout(BuildContext context) async {
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

  List<Widget> _buildMenuBarChildren(BuildContext context) => [
        SubmenuButton(
          menuChildren: _buildFileMenu(context),
          child: Text(S.of(context).file),
        ),
        SubmenuButton(
          menuChildren: _buildMenuForGroup(context, PksEditAction.editGroup),
          child: Text(S.of(context).edit),
        ),
        SubmenuButton(
          menuChildren: _buildMenuForGroup(context, PksEditAction.findGroup),
          child: Text(S.of(context).find),
        ),
        SubmenuButton(
          menuChildren:
              _buildMenuForGroup(context, PksEditAction.functionGroup),
          child: Text(S.of(context).functions),
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
          child: Text(S.of(context).window),
        ),
        SubmenuButton(
          menuChildren: [
            _createMenuButton(
                context, S.of(context).about, null, null, () {
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
    final subMenu = <Widget>[];
    final bloc = EditorBloc.of(context);
    for (var of in bloc.openFiles) {
      subMenu.add(_createMenuButton(context, _shortenFileName(of), null, null,  () {
            bloc.openFile(of);
          }));
    }
    result.insert(0, SubmenuButton(menuChildren: subMenu, child: const Text("Recent Files")));
    return result;
  }
}

