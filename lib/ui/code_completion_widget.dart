//
// code_completion_widget.dart
//
// PKS-EDIT - Flutter
//
// Last modified: 2025
// Author: Tom Krauß
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pks_edit_flutter/bloc/editor_bloc.dart';
import 'package:re_editor/re_editor.dart';

typedef _ScrollBuilder = Widget Function(BuildContext context, int index, _AutoScrollWidgetSelection selection);

enum _AutoScrollWidgetSelection {
  none,
  top,
  bottom
}

///
/// A widget used to present the auto-completion values of the editor.
///
class CodeAutocompleteListView extends StatefulWidget implements PreferredSizeWidget {
  static const double itemHeight = 26;
  final ValueNotifier<CodeAutocompleteEditingValue> notifier;
  final ValueChanged<CodeAutocompleteResult> onSelected;

  const CodeAutocompleteListView({
    super.key,
    required this.notifier,
    required this.onSelected,
  });

  @override
  Size get preferredSize => Size(
      250,
      // 2 is border size
      min(itemHeight * notifier.value.prompts.length, 200) + 2
  );

  @override
  State<StatefulWidget> createState() => _CodeAutocompleteListViewState();

}

class _CodeAutocompleteListViewState extends State<CodeAutocompleteListView> {
  @override
  void initState() {
    widget.notifier.addListener(_onValueChanged);
    super.initState();
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onValueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints.loose(widget.preferredSize),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary,
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(6)
        ),
        child: _AutoScrollListView(
          controller: ScrollController(),
          initialIndex: widget.notifier.value.index,
          itemCount: widget.notifier.value.prompts.length,
          itemBuilder:(context, index, selection) {
            final CodePrompt prompt = widget.notifier.value.prompts[index];
            var top = selection == _AutoScrollWidgetSelection.top;
            var bottom = selection == _AutoScrollWidgetSelection.bottom;
            final circular = const Radius.circular(5);
            final BorderRadius radius = BorderRadius.only(
              topLeft: top ? circular : Radius.zero,
              topRight: top ? circular : Radius.zero,
              bottomLeft: bottom ? circular : Radius.zero,
              bottomRight: bottom ? circular : Radius.zero,
            );           return InkWell(
                borderRadius: radius,
                onTap: () {
                  widget.onSelected(widget.notifier.value.copyWith(
                      index: index
                  ).autocomplete);
                },
                child: Container(
                  width: double.infinity,
                  height: CodeAutocompleteListView.itemHeight,
                  padding: const EdgeInsets.only(
                      left: 5,
                      right: 5
                  ),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                      color: index == widget.notifier.value.index ? Theme.of(context).colorScheme.primary : null,
                      borderRadius: radius
                  ),
                  child: RichText(
                    text: prompt.createSpan(context, widget.notifier.value.input, index == widget.notifier.value.index),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                )
            );
          },
        )
    );

  void _onValueChanged() {
    setState(() {
    });
  }

}

extension _CodePromptExtension on CodePrompt {

  InlineSpan createSpan(BuildContext context, String input, bool selected) {
    TextStyle style = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    if (selected) {
      style = style.copyWith(color: Theme.of(context).colorScheme.onPrimary);
    }
    final InlineSpan span = style.createSpan(
      value: word,
      anchor: input,
      color: Colors.blue,
      fontWeight: FontWeight.bold,
    );
    final CodePrompt prompt = this;
    if (prompt is CodeFieldPrompt) {
      return TextSpan(
          children: [
            span,
            TextSpan(
                text: ' ${prompt.type}',
                style: style.copyWith(
                    color: Colors.cyan
                )
            )
          ]
      );
    }
    if (prompt is CodeTemplatePrompt) {
      return TextSpan(
          children: [
            TextSpan(
                text: 'Template: ',
                style: style.copyWith(
                    color: Colors.cyan
                )
            ),
            span,
          ]
      );
    }
    if (prompt is CodeFunctionPrompt) {
      return TextSpan(
          children: [
            span,
            TextSpan(
                text: '(...) -> ${prompt.type}',
                style: style.copyWith(
                    color: Colors.cyan
                )
            )
          ]
      );
    }
    return span;
  }

}

extension _TextStyleExtension on TextStyle {

  InlineSpan createSpan({
    required String value,
    required String anchor,
    required Color color,
    FontWeight? fontWeight,
    bool caseSensitive = false,
  }) {
    if (anchor.isEmpty) {
      return TextSpan(
        text: value,
        style: this,
      );
    }
    final int index;
    if (caseSensitive) {
      index = value.indexOf(anchor);
    } else {
      index = value.toLowerCase().indexOf(anchor.toLowerCase());
    }
    if (index < 0) {
      return TextSpan(
        text: value,
        style: this,
      );
    }
    return TextSpan(
        children: [
          TextSpan(
              text: value.substring(0, index),
              style: this
          ),
          TextSpan(
              text: value.substring(index, index + anchor.length),
              style: copyWith(
                color: color,
                fontWeight: fontWeight,
              )
          ),
          TextSpan(
              text: value.substring(index + anchor.length),
              style: this
          )
        ]
    );
  }

}

class _AutoScrollListView extends StatefulWidget {

  final ScrollController controller;
  final _ScrollBuilder itemBuilder;
  final int itemCount;
  final int initialIndex;

  const _AutoScrollListView({
    required this.controller,
    required this.itemBuilder,
    required this.itemCount,
    this.initialIndex = 0
  });

  @override
  State<StatefulWidget> createState() => _AutoScrollListViewState();

}

class _AutoScrollListViewState extends State<_AutoScrollListView> {
  _AutoScrollWidgetSelection _selection = _AutoScrollWidgetSelection.top;
  late final List<GlobalKey> _keys;

  _AutoScrollWidgetSelection get selection => _selection;
  set selection(_AutoScrollWidgetSelection newValue) {
    if (newValue != _selection) {
      setState(() {
        _selection = newValue;
      });
    }
  }

  @override
  void initState() {
    _keys = List.generate(widget.itemCount, (index) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScroll();
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _AutoScrollListView oldWidget) {
    if (widget.itemCount > oldWidget.itemCount) {
      _keys.addAll(List.generate(widget.itemCount - oldWidget.itemCount, (index) => GlobalKey()));
    } else if (widget.itemCount < oldWidget.itemCount) {
      _keys.sublist(oldWidget.itemCount - widget.itemCount);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScroll();
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];
    for (int i = 0; i < widget.itemCount; i++) {
      widgets.add(Container(
        key: _keys[i],
        child: widget.itemBuilder(context, i, selection),
      ));
    }
    return SingleChildScrollView(
      controller: widget.controller,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  void _autoScroll() {
    final ScrollController controller = widget.controller;
    if (!controller.hasClients) {
      return;
    }
    if (controller.position.maxScrollExtent == 0) {
      return;
    }
    double pre = 0;
    double cur = 0;
    for (int i = 0; i < _keys.length; i++) {
      final RenderObject? obj = _keys[i].currentContext?.findRenderObject();
      if (obj is! RenderBox) {
        continue;
      }
      double height = obj.size.height;
      if (i == widget.initialIndex) {
        cur = pre + height;
        break;
      }
      pre += height;
    }
    if (pre == cur) {
      selection = _AutoScrollWidgetSelection.none;
      return;
    }
    if (pre < widget.controller.offset) {
      selection = _AutoScrollWidgetSelection.top;
      controller.jumpTo(pre);
    } else if (cur > controller.offset + controller.position.viewportDimension) {
      selection = _AutoScrollWidgetSelection.bottom;
      controller.jumpTo(cur - controller.position.viewportDimension);
    } else {
      if (widget.initialIndex == 0) {
        selection = _AutoScrollWidgetSelection.top;
      } else {
        selection = _AutoScrollWidgetSelection.none;
      }
    }
  }
}
