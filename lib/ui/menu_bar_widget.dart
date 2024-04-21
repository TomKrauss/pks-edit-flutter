//
// menu_bar_widget.dart
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

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:pks_edit_flutter/actions/action_bindings.dart';
import 'package:pks_edit_flutter/bloc/editor_bloc.dart';
import 'package:pks_edit_flutter/generated/l10n.dart';

///
/// Displays a menu bar containing the menu bar triggered actions of PKS EDIT
///
class MenuBarWidget extends StatelessWidget {
  final Iterable<MenuItemBinding> actions;
  const MenuBarWidget({super.key, required this.actions});

  Widget _createLeadingIcon(BuildContext context, IconData? icon) => icon == null ?
  SizedBox(width: Theme.of(context).menuButtonTheme.style?.iconSize?.resolve({MaterialState.selected}) ?? 24) :
  Icon(icon);
      
  Widget _createMenuButton(BuildContext context, String label, IconData? icon, MenuSerializableShortcut? shortcut,
      void Function()? onPressed) =>
      MenuItemButton(
          leadingIcon: _createLeadingIcon(context, icon),
          onPressed: onPressed, shortcut: shortcut, child: Text(label));

  List<Widget> _buildChildren(BuildContext context, Iterable<MenuItemBinding> actions) {
    var result = <Widget>[];
    for (var b in actions) {
      if (b.children != null && b.children!.isNotEmpty) {
        result.add(SubmenuButton(
          menuChildren: _buildChildren(context, b.children!),
          child: Text(b.title),
        ));
      } else if (b.isSeparator) {
        if (result.isNotEmpty && result.lastOrNull is! Divider) {
          result.add(const Divider());
        }
        if (b.isHistoryMenu) {
          result.add(SubmenuButton(menuChildren: _buildHistoryMenu(context), 
              leadingIcon: _createLeadingIcon(context, null),
              child: Text(S.of(context).recentFiles)));
        }
      } else {
        final icon = b.iconData;
        var element = _createMenuButton(context, b.title, icon, b.action?.shortcut, b.action?.onPressed);
        result.add(element);
      }
    }
    if (result.lastOrNull is Divider) {
      result.removeLast();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) =>
      MenuBar(children: _buildChildren(context, actions));

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

  List<Widget> _buildHistoryMenu(BuildContext context) {
    final subMenu = <Widget>[];
    final bloc = EditorBloc.of(context);
    for (var of in bloc.openFiles) {
      subMenu.add(_createMenuButton(context, _shortenFileName(of), null, null,  () {
        bloc.openFile(of);
      }));
    }
    return subMenu;
  }
}

