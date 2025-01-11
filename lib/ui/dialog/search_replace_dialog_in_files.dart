//
// search_replace_dialog.dart
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

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pks_edit_flutter/bloc/search_in_files_controller.dart';
import 'package:pks_edit_flutter/config/pks_sys.dart';
import 'package:pks_edit_flutter/generated/l10n.dart';
import 'package:pks_edit_flutter/ui/dialog/dialog.dart';

///
/// Represents one match result in our MatchResultListWidget.
///
class _MatchResultListWidget extends StatelessWidget {
  final SearchInFilesMatch match;
  final bool selected;
  final TextStyle? textStyle;
  final void Function(bool) onSelect;
  const _MatchResultListWidget(
      {required this.match,
      required this.onSelect,
      this.selected = false,
      this.textStyle});

  RichText? _createSpan(
      List<String> segments, TextStyle? textStyle, TextStyle? boldStyle) {
    if (segments.length == 3) {
      return RichText(
          text: TextSpan(
              text: segments[0].trimLeft(),
              style: textStyle,
              children: [
            TextSpan(text: segments[1], style: boldStyle),
            TextSpan(text: segments[2], style: textStyle)
          ]));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var style = textStyle;
    if (selected) {
      style = style?.copyWith(color: Theme.of(context).colorScheme.primary);
    }
    var boldStyle = style?.copyWith(fontWeight: FontWeight.bold);
    var result = GestureDetector(
        onDoubleTap: () {
          onSelect(true);
        },
        onTap: () {
          onSelect(false);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(match.fileName, style: style?.copyWith(color: style.color?.withAlpha(100), fontSize: 14)),
            Expanded(
                child: Row(children: [
              SizedBox(
                  width: 40, child: Text("${match.lineNumber}:", style: style)),
              Flexible(
                  child: _createSpan(match.matchedSegments, style, boldStyle) ??
                      SizedBox(width: 0))
            ])),
            Divider(thickness: 0.2)
          ],
        ));
    if (selected) {
      return Container(
          color: Theme.of(context).colorScheme.onPrimary, child: result);
    }
    return result;
  }
}

///
/// Arguments to pass on to the search replace dialog.
///
class SearchReplaceInFilesDialogArguments {
  final bool supportReplace;
  final void Function(BuildContext context, SearchInFilesAction action) onAction;

  SearchReplaceInFilesDialogArguments({this.supportReplace = true, required this.onAction});
}

///
/// A widget displaying a match result list.
///
class MatchResultListWidget extends StatefulWidget {
  ///
  /// The model of this widget - the match results.
  final MatchResultList resultList;
  ///
  /// Invoked, when an item in the list is double clicked.
  ///
  final void Function() onAccept;
  final bool progress;

  const MatchResultListWidget(this.resultList, {required this.progress, required this.onAccept, super.key});

  @override
  State<StatefulWidget> createState() => SearchResultState();
}

// Action to move to the previous match
class _NextIntent extends Intent {
  const _NextIntent();
}

// Action to move to the previous match
class _PreviousIntent extends Intent {
  const _PreviousIntent();
}

// Action to confirm a match
class _ConfirmIntent extends Intent {
  const _ConfirmIntent();
}

class SearchResultState extends State<MatchResultListWidget> {
  double get itemHeight => 65;
  ValueNotifier<SearchInFilesMatch?> get selectedMatch =>
      widget.resultList.selectedMatch;
  late final CallbackAction<_PreviousIntent> _previousAction;
  late final CallbackAction<_NextIntent> _nextAction;
  late final CallbackAction<_ConfirmIntent> _confirmAction;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _previousAction = CallbackAction<_PreviousIntent>(onInvoke: _handleMovePrevious);
    _nextAction = CallbackAction<_NextIntent>(onInvoke: _handleMoveNext);
    _confirmAction = CallbackAction<_ConfirmIntent>(onInvoke: _handleConfirm);
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
  }

  void _ensureListItemVisible() {
    var idx = widget.resultList.selectedIndex;
    if (idx >= 0 && _scrollController.hasClients) {
      var lowY = idx * itemHeight;
      var highY = lowY + itemHeight;
      var p = _scrollController.position;
      if (p.viewportDimension+p.pixels < highY) {
        _scrollController.jumpTo(highY-p.viewportDimension);
      } else if (p.pixels > lowY) {
        _scrollController.jumpTo(lowY);
      }
    }
  }

  void _handleConfirm(_ConfirmIntent intent) {
    widget.onAccept();
  }

  void _handleMoveNext(_NextIntent intent) {
    widget.resultList.moveSelectionNext();
    _ensureListItemVisible();
  }

  void _handleMovePrevious(_PreviousIntent intent) {
    widget.resultList.moveSelectionPrevious();
    _ensureListItemVisible();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: widget.resultList.results,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null || data.isEmpty) {
          return Center(
              child: widget.progress
                  ? const CircularProgressIndicator()
                  : Text("No results"));
        }
        var fnStyle = Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(overflow: TextOverflow.fade);
        return SingleChildScrollView(
            controller: _scrollController,
            child: Shortcuts(
                shortcuts: <LogicalKeySet, Intent>{
              LogicalKeySet(LogicalKeyboardKey.arrowDown): const _NextIntent(),
              LogicalKeySet(LogicalKeyboardKey.arrowUp): const _PreviousIntent(),
              LogicalKeySet(LogicalKeyboardKey.enter): const _ConfirmIntent(),
            },
                child: Actions(
                    actions: <Type, Action<Intent>>{
                      _NextIntent: _nextAction,
                      _ConfirmIntent: _confirmAction,
                      _PreviousIntent: _previousAction
                    },
                    child:  Focus(
            focusNode: _focusNode,
            debugLabel: "Focused Result List",
            child: ValueListenableBuilder(
                        valueListenable: selectedMatch,
                        builder: (context, value, child) => Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: data
                                .map((d) => SizedBox(height: itemHeight, child: _MatchResultListWidget(
                                      onSelect: (flag) {
                                        _focusNode.requestFocus();
                                        selectedMatch.value = d;
                                        if (flag) {
                                          widget.onAccept();
                                        }
                                      },
                                      match: d,
                                      textStyle: fnStyle,
                                      selected: d == value,
                                    )))
                                .toList()))))));
      });
}

///
/// Used to implement search and replace in files.
///
class SearchReplaceInFilesDialog extends StatefulWidget {
  final SearchReplaceInFilesDialogArguments arguments;

  static Future<void> show(
          {required BuildContext context,
          required SearchReplaceInFilesDialogArguments arguments}) =>
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              SearchReplaceInFilesDialog(arguments: arguments));

  const SearchReplaceInFilesDialog({required this.arguments, super.key});

  @override
  State<SearchReplaceInFilesDialog> createState() =>
      _SearchReplaceInFilesDialogState();
}

class _SearchReplaceInFilesDialogState
    extends State<SearchReplaceInFilesDialog> {
  static const _padding = EdgeInsets.all(10);
  late final TextEditingController _fileNamePatternController;
  late final TextEditingController _directoryController;
  late final TextEditingController _searchController;
  late final TextEditingController _replaceController;
  final Future<PksEditSession> session =
      PksConfiguration.singleton.currentSession;
  final parameter = SearchAndReplaceInFilesOptions();
  final SearchInFilesController searchInFilesController =
      SearchInFilesController.instance;
  bool _sessionInitialized = false;

  @override
  void initState() {
    super.initState();
    _fileNamePatternController = TextEditingController(text: "*.dart");
    _directoryController = TextEditingController(text: File(".").absolute.path);
    _searchController = TextEditingController();
    _replaceController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _replaceController.dispose();
    _fileNamePatternController.dispose();
    _directoryController.dispose();
    super.dispose();
  }

  Widget _editor(String label, IconData icon, bool autoFocus,
          TextEditingController controller,
          {List<Widget>? options}) =>
      Padding(
          padding: _padding,
          child: TextField(
              controller: controller,
              autofocus: autoFocus,
              decoration: InputDecoration(
                  icon: Icon(icon),
                  hintText: label,
                  suffix: options == null
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: options,
                        ))));

  Widget _folderSelector(
          String label, IconData icon, TextEditingController controller,
          {List<Widget>? options}) =>
      Padding(
          padding: _padding,
          child: Row(children: [
            Flexible(
                child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                        icon: Icon(icon),
                        hintText: label,
                        suffix: options == null
                            ? null
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: options,
                              )))),
            const SizedBox(width: 10),
            Tooltip(
                message: 'Select Directory',
                child: IconButton(
                    onPressed: _selectFolder,
                    icon: Icon(Icons.folder_copy_outlined)))
          ]));

  Future<void> _selectFolder() async {
    var result = await getDirectoryPath(
        initialDirectory: parameter.directory,
        confirmButtonText: "Select Folder");
    if (result != null) {
      _directoryController.text = result;
    }
  }

  Widget _inputFields() => SizedBox(
      width: 900,
      child: Column(children: [
        Row(children: [
          Expanded(
              flex: 3,
              child: _folderSelector(
                  "Find in Folder", Icons.folder, _directoryController,
                  options: [
                    _optionButton("1", "Single Match in File",
                        parameter.options.singleMatchInFile, (newValue) {
                      parameter.options.singleMatchInFile = newValue;
                    }),
                    _optionButton("0x", "Ignore Binary Files",
                        parameter.options.ignoreBinaryFiles, (newValue) {
                      parameter.options.ignoreBinaryFiles = newValue;
                    }),
                  ])),
          Flexible(
              child: _editor("File Name Patterns", Icons.filter, false,
                  _fileNamePatternController))
        ]),
        _editor(S.of(context).enterTextToFind, Icons.search, true,
            _searchController,
            options: [
              _optionButton(
                  ".*", "Match regular Expressions", parameter.options.regex,
                  (newValue) {
                parameter.options.regex = newValue;
              }),
              _optionButton("Cc", "Ignore Case", parameter.options.ignoreCase,
                  (newValue) {
                parameter.options.ignoreCase = newValue;
              }),
            ]),
        if (widget.arguments.supportReplace)
          _editor(S.of(context).enterTextToReplace, Icons.find_replace, false,
              _replaceController,
              options: [
                _optionButton(
                    "AA", "Preserve Case", parameter.options.preserveCase,
                    (newValue) {
                  parameter.options.preserveCase = newValue;
                }),
              ])
      ]));

  void _find() {
    _applyOptions();
    searchInFilesController.run(parameter);
    //Navigator.pop(context, parameter);
  }

  void _replace() {
    _applyOptions();
    Navigator.pop(context, SearchInFilesAction.replaceInFiles);
  }

  Widget _optionButton(String label, String tooltip, bool value,
      void Function(bool newValue) onChanged) {
    var theme = Theme.of(context);
    var style = ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        fixedSize: Size(25, 25),
        minimumSize: Size.zero,
        backgroundColor: theme.colorScheme.primary.withAlpha(30),
        shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))));
    if (value) {
      style = style.copyWith(
          foregroundColor: WidgetStatePropertyAll(theme.colorScheme.onPrimary),
          backgroundColor: WidgetStatePropertyAll(theme.colorScheme.primary));
    }
    return Padding(
        padding: EdgeInsets.only(left: 10),
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

  DialogAction _button(String text, VoidCallback? callback) =>
      DialogAction(text: text, onPressed: callback);

  void _applyOptions() {
    parameter.fileNamePattern = _fileNamePatternController.text;
    parameter.directory = _directoryController.text;
    parameter.search = _searchController.text;
    parameter.replace = _replaceController.text;
    PksConfiguration.singleton.currentSession.then((session) {
      session.searchPatterns.addOrMoveFirst(_searchController.text);
      session.replacePatterns.addOrMoveFirst(_replaceController.text);
      session.filePatterns.addOrMoveFirst(_fileNamePatternController.text);
      session.searchAndReplaceOptions = parameter.options;
    });
  }

  List<DialogAction> _actions() => [
        _button(S.of(context).find,
            searchInFilesController.running.value ? null : _find),
        _button(S.of(context).replace,
            searchInFilesController.running.value ? null : _replace),
        DialogAction.createCancelAction(context)
      ];

  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: session,
      builder: (context, snapshot) {
        var sessionValues = snapshot.data;
        if (sessionValues != null && !_sessionInitialized) {
          _sessionInitialized = true;
          parameter.options = sessionValues.searchAndReplaceOptions;
          _searchController.text =
              sessionValues.searchPatterns.firstOrNull ?? "";
          _replaceController.text =
              sessionValues.replacePatterns.firstOrNull ?? "";
          _fileNamePatternController.text =
              sessionValues.filePatterns.firstOrNull ?? "";
        }
        return ValueListenableBuilder(
            valueListenable: searchInFilesController.running,
            builder: (_, value, __) => PksDialog(
                  title: Text("Search and Replace in Files"),
                  actions: _actions(),
                  children: [
                    _inputFields(),
                    Container(
                        height: 500,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColorLight)),
                        child: MatchResultListWidget(
                          searchInFilesController.results,
                          onAccept: () {
                            widget.arguments.onAction(context, SearchInFilesAction.openFile);
                          },
                          progress: searchInFilesController.running.value,
                        ))
                  ],
                ));
      });
}
