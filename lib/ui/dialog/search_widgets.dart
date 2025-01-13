//
// search_widgets.dart
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pks_edit_flutter/bloc/search_in_files_controller.dart';
import 'package:pks_edit_flutter/config/pks_sys.dart';
import 'package:pks_edit_flutter/generated/l10n.dart';

///
/// A reusable widget for editing a string parameter used during search and replace optionally providing
/// options modifying the search behavior.
///
abstract class SearchWidget extends StatefulWidget {
  final SearchAndReplaceInFilesOptions parameter;
  final bool autoFocus;
  final IconData icon;
  final String label;
  final void Function(String text)? onChanged;
  final void Function(String text)? onAccept;

  const SearchWidget(
      {super.key,
      this.autoFocus = false,
      this.onChanged,
      this.onAccept,
      required this.icon,
      required this.label,
      required this.parameter});
}

abstract class SearchWidgetState<T extends SearchWidget> extends State<T> {
  static const _padding = EdgeInsets.all(10);
  final TextEditingController _controller = TextEditingController();
  SearchAndReplaceInFilesOptions get parameter => widget.parameter;
  final List<String> suggestions = [];

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @protected
  Widget optionButton(String label, String tooltip, bool value,
      void Function(bool newValue) onChanged) {
    var theme = Theme.of(context);
    var style = ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        fixedSize: const Size(25, 25),
        minimumSize: Size.zero,
        backgroundColor: theme.colorScheme.primary.withAlpha(30),
        shape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))));
    if (value) {
      style = style.copyWith(
          foregroundColor: WidgetStatePropertyAll(theme.colorScheme.onPrimary),
          backgroundColor: WidgetStatePropertyAll(theme.colorScheme.primary));
    }
    return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Tooltip(
            message: tooltip,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  onChanged(!value);
                });
              },
              style: style,
              child: Text(label),
            )));
  }

  void saveSession(PksEditSession session);

  void initializeValues(List<String> values) {
    _controller.text = values.firstOrNull ?? "";
    suggestions.clear();
    suggestions.addAll(values);
  }

  List<Widget>? get options;

  String get value => _controller.text;

  @override
  Widget build(BuildContext context) => Padding(
      padding: _padding,
      child: Stack(
          children: [
          TextField(
          controller: _controller,
          autofocus: widget.autoFocus,
          onChanged: widget.onChanged,
          onSubmitted: widget.onAccept,
          decoration: InputDecoration(
              icon: Icon(widget.icon),
              hintText: widget.label,
              suffix: options == null
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: options ?? [],
                    ))),
            if (suggestions.length > 1)
              Positioned(
                  left: 5,
                  top: 3,
                  child: PopupMenuButton(itemBuilder: (context) => suggestions.map((String s) => PopupMenuItem<String>(child: Text(s), onTap: () {
                    _controller.text = s;
                  },)).toList(),
                      icon: const Icon(Icons.arrow_drop_down_outlined, size: 24,))),
          ]));
}

///
/// A widget to display entry field + options to be used in Find operations.
///
class FindWidget extends SearchWidget {
  const FindWidget(
      {super.key,
      super.icon = Icons.search,
      super.autoFocus = true,
      super.onChanged,
      super.onAccept,
      required super.label,
      required super.parameter});

  @override
  State<StatefulWidget> createState() => FindWidgetState();
}

///
/// A widget allowing to enter a search string with options.
///
class FindWidgetState extends SearchWidgetState<FindWidget> {
  @override
  void saveSession(PksEditSession session) {
    session.searchPatterns.addOrMoveFirst(_controller.text,
        maxLength: PksEditSession.maxHistoryListSize);
  }

  @override
  List<Widget>? get options => [
        optionButton(".*", S.of(context).matchRegularExpressions,
            parameter.options.regex, (newValue) {
          parameter.options.regex = newValue;
          if (newValue) {
            parameter.options.shellWildCards = false;
          }
        }),
        optionButton(
            "Cc", S.of(context).ignoreCase, parameter.options.ignoreCase,
            (newValue) {
          parameter.options.ignoreCase = newValue;
        }),
        optionButton(
            "*?", "Shell wildcard search", parameter.options.shellWildCards,
            (newValue) {
          parameter.options.shellWildCards = newValue;
          if (newValue) {
            parameter.options.regex = false;
          }
        }),
      ];
}

class ReplaceWidget extends SearchWidget {
  const ReplaceWidget(
      {super.key,
      super.autoFocus = false,
      super.onChanged,
      super.onAccept,
      super.icon = Icons.find_replace,
      required super.label,
      required super.parameter});

  @override
  State<StatefulWidget> createState() => ReplaceWidgetState();
}

class ReplaceWidgetState extends SearchWidgetState<ReplaceWidget> {
  @override
  List<Widget>? get options => [
        optionButton(
            "AA", S.of(context).preserveCase, parameter.options.preserveCase,
            (newValue) {
          parameter.options.preserveCase = newValue;
        }),
      ];

  @override
  void saveSession(PksEditSession session) {
    session.replacePatterns.addOrMoveFirst(_controller.text,
        maxLength: PksEditSession.maxHistoryListSize);
  }
}

class FolderWidget extends SearchWidget {
  const FolderWidget(
      {super.key,
      super.onChanged,
      super.onAccept,
      super.autoFocus = false,
      super.icon = Icons.folder,
      required super.label,
      required super.parameter});

  @override
  State<StatefulWidget> createState() => FolderWidgetState();
}

class FolderWidgetState extends SearchWidgetState<FolderWidget> {
  @override
  List<Widget>? get options => [
        optionButton("1", S.of(context).singleMatchInFile,
            parameter.options.singleMatchInFile, (newValue) {
          parameter.options.singleMatchInFile = newValue;
        }),
        optionButton("0x", S.of(context).ignoreBinaryFiles,
            parameter.options.ignoreBinaryFiles, (newValue) {
          parameter.options.ignoreBinaryFiles = newValue;
        }),
      ];

  set value(String value) => _controller.text = value;

  @override
  void initializeValues(List<String> values) {
    _controller.text = values.firstOrNull ?? File(".").absolute.path;
  }

  @override
  void saveSession(PksEditSession session) {
    session.folders.addOrMoveFirst(_controller.text,
        maxLength: PksEditSession.maxHistoryListSize);
  }
}

class FileNamePatternWidget extends SearchWidget {
  const FileNamePatternWidget(
      {super.key,
      super.onChanged,
      super.onAccept,
      super.autoFocus = false,
      super.icon = Icons.find_replace,
      required super.label,
      required super.parameter});

  @override
  State<StatefulWidget> createState() => FileNamePatternWidgetState();
}

class FileNamePatternWidgetState
    extends SearchWidgetState<FileNamePatternWidget> {
  @override
  List<Widget>? get options => null;

  @override
  void saveSession(PksEditSession session) {
    session.filePatterns.addOrMoveFirst(_controller.text,
        maxLength: PksEditSession.maxHistoryListSize);
  }
}
