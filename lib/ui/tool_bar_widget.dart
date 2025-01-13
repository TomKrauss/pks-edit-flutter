//
// toolbar_widget.dart
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
import 'package:flutter/services.dart';
import 'package:pks_edit_flutter/actions/action_bindings.dart';
import 'package:pks_edit_flutter/bloc/editor_bloc.dart';
import 'package:pks_edit_flutter/config/pks_ini.dart';
import 'package:pks_edit_flutter/actions/actions.dart';
import 'package:re_editor/re_editor.dart';
import 'package:pks_edit_flutter/generated/l10n.dart';

///
/// A widget displaying a search area in the toolbar.
///
class SearchBarWidget extends StatefulWidget {
  final FocusNode focusNode;
  final CodeFindController findController;
  const SearchBarWidget({required this.focusNode, required this.findController, super.key});
  @override
  State<StatefulWidget> createState() => SearchBarWidgetState();
}

class SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchBarController = TextEditingController();
  AxisDirection _searchDirection = AxisDirection.down;

  @override
  void initState() {
    super.initState();
    _searchBarController.addListener(() {
      final findController = widget.findController;
      findController.findInputController.text = _searchBarController.text;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchBarController.dispose();
  }

  set searchDirection(AxisDirection direction) {
    if (_searchDirection != direction) {
      setState(() {
        _searchDirection = direction;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = PksIniConfiguration.of(context).configuration.iconSize.size;
    final theme = Theme.of(context);
    final color = ThemeData.estimateBrightnessForColor(theme.primaryColor) == Brightness.light ? Colors.black87 : Colors.white70;
    final fontSize = (height/2);
    final constraints = BoxConstraints(maxHeight: height+4);
    return Tooltip(message: "Type text to search\nPress Enter to navigate matches\nPress Ctrl+Up/Ctrl+Down to change navigation direction",
        child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.arrowDown, control: true): () => searchDirection = AxisDirection.down,
              const SingleActivator(LogicalKeyboardKey.arrowUp, control: true): () => searchDirection = AxisDirection.up,
            },
            child: TextField(
              focusNode: widget.focusNode,
              controller: _searchBarController,
              style: TextStyle(color: color, fontSize: fontSize),
              onSubmitted: (String value) {
                if (_searchDirection == AxisDirection.down) {
                  widget.findController.nextMatch();
                } else {
                  widget.findController.previousMatch();
                }
                widget.focusNode.requestFocus();
              },
              decoration: InputDecoration(
                  prefixIcon: Padding(padding: const EdgeInsets.only(right: 8, left: 4), child: Icon(Icons.search, color: color, size: fontSize+4,)),
                  prefixIconConstraints: constraints,
                  suffixIconConstraints: constraints,
                  border: InputBorder.none,
                  filled: true,
                  fillColor: theme.primaryColor,
                  suffixIcon: Icon(_searchDirection == AxisDirection.down ? Icons.arrow_downward : Icons.arrow_upward, color: color, size: fontSize+4,),
                  hintText: S.of(context).searchIncrementally("Ctrl+Alt+S"),
                  hintStyle: theme.textTheme.bodySmall?.copyWith(color: color, fontSize: fontSize),
                  contentPadding: const EdgeInsets.all(6), isDense: true),)));
  }

}
///
/// Displays a tool bar containing the tool bar triggered actions of PKS EDIT
///
class ToolBarWidget extends StatefulWidget {
  final OpenFile? currentFile;
  final Iterable<ToolbarItemBinding> actions;
  final FocusNode focusNode;

  const ToolBarWidget(
      {super.key, this.currentFile, required this.focusNode, required this.actions});

  @override
  State<StatefulWidget> createState() => ToolBarWidgetState();
}

///
/// Displays a tool bar containing the tool bar triggered actions of PKS EDIT
///
class ToolBarWidgetState extends State<ToolBarWidget> {

  Widget _buildButton(PksEditAction action, IconData? icon, ApplicationConfiguration config, Color iconColor, void Function()? callback) =>
      Tooltip(
          message: action.description,
          child: InkWell(
              onTap: callback,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Icon(icon,
                    size: config.iconSize.size.toDouble(),
                    color: callback == null ? Colors.grey : iconColor),
              )));

  Iterable<Widget> _buildItems(ApplicationConfiguration config, Color iconColor) {
    var result = <Widget>[];
    Widget? previous;
    for (final e in widget.actions) {
      var widget =
      e.isSeparator ? VerticalDivider(
        indent: 3,
        endIndent: 3,
        color: Theme.of(context).dividerColor,
      ) : _buildButton(e.action!, e.iconData, config, iconColor, e.action!.onPressed);
      if (e.isSeparator && previous is VerticalDivider) {
        continue;
      }
      previous = widget;
      result.add(widget);
    }
    return result;
  }

  List<Widget> _buildToolbarItems() {
    var result = <Widget>[];
    final config = PksIniConfiguration.of(context).configuration;
    final iconColor = EditorBloc.of(context).themes.currentTheme.iconColor;
    result.addAll(_buildItems(config, iconColor));
    final findController = widget.currentFile?.findController;
    if (findController != null) {
      result.add(const Spacer());
      result.add(Expanded(flex: 3, child: SearchBarWidget(focusNode: widget.focusNode, findController: findController)));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
      child: Container(
          decoration: BoxDecoration(color: Theme.of(context).appBarTheme.backgroundColor),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: _buildToolbarItems(),
          )));
}

