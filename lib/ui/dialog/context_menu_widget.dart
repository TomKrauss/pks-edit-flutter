//
// context_menu_widget.dart
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
import 'package:pks_edit_flutter/actions/action_bindings.dart';
import 'package:re_editor/re_editor.dart';

///
/// Implements the context menu to be displayed for each editor.
///
class ContextMenuItemWidget extends PopupMenuItem<void> implements PreferredSizeWidget {
  ContextMenuItemWidget({
    required String text,
    super.onTap,
    super.key
  }) : super(
      child: Text(text)
  );

  @override
  Size get preferredSize => const Size(150, 25);

}

///
/// Controls the items to display in a context menu opened for each editor. Context menu
/// items for PKS Edit can be configured in the actions configuration.
///
class ContextMenuControllerImpl implements SelectionToolbarController {
  final List<MenuItemBinding> menuItems;

  const ContextMenuControllerImpl({required this.menuItems});

  @override
  void hide(BuildContext context) {
  }

  @override
  void show({
    required BuildContext context,
    required CodeLineEditingController controller,
    required TextSelectionToolbarAnchors anchors,
    Rect? renderRect,
    required LayerLink layerLink,
    required ValueNotifier<bool> visibility,
  }) {
    var items = <PopupMenuEntry<dynamic>>[];
    for (final e in menuItems) {
      if (e.isSeparator) {
        if (items.lastOrNull is PopupMenuDivider) {
          continue;
        }
        items.add(const PopupMenuDivider());
      } else {
        items.add(ContextMenuItemWidget(text: e.title, onTap: e.action?.onPressed));
      }
    }
    if (items.lastOrNull is PopupMenuDivider) {
      items.removeLast();
    }
    showMenu(
        context: context,
        position: RelativeRect.fromSize(
            anchors.primaryAnchor & const Size(150, double.infinity),
            MediaQuery
                .of(context)
                .size),
        items: items
    );
  }
}
