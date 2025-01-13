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

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pks_edit_flutter/bloc/match_result_list.dart';
import 'package:pks_edit_flutter/bloc/search_in_files_controller.dart';
import 'package:pks_edit_flutter/config/pks_sys.dart';
import 'package:pks_edit_flutter/generated/l10n.dart';
import 'package:pks_edit_flutter/ui/dialog/dialog.dart';
import 'package:pks_edit_flutter/ui/dialog/search_widgets.dart';

///
/// A widget displaying one match result.
///
class _MatchResultListWidget extends StatefulWidget {
  final MatchedFileLocation match;
  final bool selected;
  final TextStyle? textStyle;
  final void Function(bool) onSelect;
  const _MatchResultListWidget(
      {required this.match,
      required this.onSelect,
      this.selected = false,
      this.textStyle});

  @override
  State<StatefulWidget> createState() => _MatchResultListWidgetState();
}

///
/// Represents one match result in our MatchResultListWidget.
///
class _MatchResultListWidgetState extends State<_MatchResultListWidget> {
  MatchedFileLocation get match => widget.match;
  bool get selected => widget.selected;
  TextStyle? get textStyle => widget.textStyle;
  void Function(bool) get onSelect => widget.onSelect;
  bool _hovered = false;

  RichText? _createSpan(
      List<String> segments, TextStyle? textStyle, TextStyle? boldStyle) {
    if (segments.length == 3) {
      if (_hovered) {
        textStyle = textStyle?.copyWith(decoration: TextDecoration.underline);
        boldStyle = boldStyle?.copyWith(decoration: TextDecoration.underline);
      }
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
          onSelect(_hovered);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(match.fileName,
                style: style?.copyWith(
                    color: style.color?.withAlpha(100), fontSize: 14)),
            Expanded(
                child: Row(children: [
                      SizedBox(
                          width: 40,
                          child: Text("${match.lineNumber}:", style: style)),
                      Flexible(
                          child: MouseRegion(
                              onEnter: (e) {
                                setState(() {
                                  _hovered = true;
                                });
                              },
                              onExit: (e) {
                                setState(() {
                                  _hovered = false;
                                });
                              },
                              child: _createSpan(
                                  match.matchedSegments, style, boldStyle) ??
                              const SizedBox(width: 0)))
                    ])),
            const Divider(thickness: 0.2)
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
  final void Function(BuildContext context, SearchInFilesAction action)
      onAction;

  SearchReplaceInFilesDialogArguments(
      {this.supportReplace = true, required this.onAction});
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

  const MatchResultListWidget(this.resultList,
      {required this.progress, required this.onAccept, super.key});

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
  ValueNotifier<MatchedFileLocation?> get selectedMatch =>
      widget.resultList.selectedMatch;
  late final CallbackAction<_PreviousIntent> _previousAction;
  late final CallbackAction<_NextIntent> _nextAction;
  late final CallbackAction<_ConfirmIntent> _confirmAction;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _previousAction =
        CallbackAction<_PreviousIntent>(onInvoke: _handleMovePrevious);
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
      if (p.viewportDimension + p.pixels < highY) {
        var newPos = highY - p.viewportDimension;
        if (newPos - p.pixels > itemHeight) {
          newPos = highY - p.viewportDimension / 2;
        }
        _scrollController.jumpTo(newPos);
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
                  : const Text("No results"));
        }
        WidgetsBinding.instance.addPostFrameCallback((d) {
          _ensureListItemVisible();
        });
        var fnStyle = Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(overflow: TextOverflow.fade);
        return SingleChildScrollView(
            controller: _scrollController,
            child: Shortcuts(
                shortcuts: <LogicalKeySet, Intent>{
                  LogicalKeySet(LogicalKeyboardKey.arrowDown):
                      const _NextIntent(),
                  LogicalKeySet(LogicalKeyboardKey.arrowUp):
                      const _PreviousIntent(),
                  LogicalKeySet(LogicalKeyboardKey.enter):
                      const _ConfirmIntent(),
                },
                child: Actions(
                    actions: <Type, Action<Intent>>{
                      _NextIntent: _nextAction,
                      _ConfirmIntent: _confirmAction,
                      _PreviousIntent: _previousAction
                    },
                    child: Focus(
                        focusNode: _focusNode,
                        debugLabel: "Focused Result List",
                        child: ValueListenableBuilder(
                            valueListenable: selectedMatch,
                            builder: (context, value, child) => Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: data
                                    .map((d) => SizedBox(
                                        height: itemHeight,
                                        child: _MatchResultListWidget(
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
  final GlobalKey<FindWidgetState> searchKey = GlobalKey(debugLabel: "searchField");
  final GlobalKey<ReplaceWidgetState> replaceKey = GlobalKey(debugLabel: "replaceField");
  final GlobalKey<FileNamePatternWidgetState> patternKey = GlobalKey(debugLabel: "patternField");
  final GlobalKey<FolderWidgetState> folderKey = GlobalKey(debugLabel: "folderField");
  static const _padding = EdgeInsets.all(10);
  final Future<PksEditSession> session =
      PksConfiguration.singleton.currentSession;
  final parameter = SearchAndReplaceInFilesOptions();
  final SearchInFilesController searchInFilesController =
      SearchInFilesController.instance;
  bool _sessionInitialized = false;

  @override
  void initState() {
    super.initState();
    searchInFilesController.initialize();
  }

  Widget _folderSelector(
          String label) =>
      Padding(
          padding: _padding,
          child: Row(children: [
            Flexible(
                child: FolderWidget(
                  key: folderKey,
                    label: label,
                    parameter: parameter)),
            const SizedBox(width: 10),
            Tooltip(
                message: S.of(context).selectDirectory,
                child: IconButton(
                    onPressed: _selectFolder,
                    icon: const Icon(Icons.folder_copy_outlined)))
          ]));

  Future<void> _selectFolder() async {
    var result = await getDirectoryPath(
        initialDirectory: parameter.directory,
        confirmButtonText: "Select Folder");
    if (result != null) {
      folderKey.currentState?.value = result;
    }
  }

  Widget _inputFields() => SizedBox(
      width: 900,
      child: Column(children: [
        Row(children: [
          Expanded(
              flex: 3,
              child: _folderSelector(S.of(context).findInFolder)),
          Flexible(
              child: FileNamePatternWidget(key: patternKey, label: S.of(context).fileNamePatterns, icon: Icons.filter, parameter: parameter,))
        ]),
        FindWidget(key: searchKey, label: S.of(context).enterTextToFind, parameter: parameter),
        if (widget.arguments.supportReplace)
          ReplaceWidget(key: replaceKey, label: S.of(context).enterTextToReplace, parameter: parameter,)
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

  DialogAction _button(String text, VoidCallback? callback) =>
      DialogAction(text: text, onPressed: callback);

  void _applyOptions() {
    parameter.fileNamePattern = patternKey.currentState?.value ?? "";
    parameter.directory = folderKey.currentState?.value ?? "";
    parameter.replace = replaceKey.currentState?.value ?? "";
    parameter.search = searchKey.currentState?.value ?? "";
    PksConfiguration.singleton.currentSession.then((session) {
      searchKey.currentState?.saveSession(session);
      replaceKey.currentState?.saveSession(session);
      folderKey.currentState?.saveSession(session);
      patternKey.currentState?.saveSession(session);
      session.searchAndReplaceOptions = parameter.options;
    });
  }

  List<DialogAction> _actions() => [
        if (!searchInFilesController.running.value)
        _button(S.of(context).find, _find),
        if (widget.arguments.supportReplace && !searchInFilesController.running.value)
        _button(S.of(context).replace, _replace),
        if (searchInFilesController.running.value)
        _button("Abort", _abortSearch),
        DialogAction.createCancelAction(context)
      ];

  void _abortSearch() {
    searchInFilesController.abortSearch();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: session,
      builder: (context, snapshot) {
        var sessionValues = snapshot.data;
        if (sessionValues != null && !_sessionInitialized) {
          _sessionInitialized = true;
          parameter.options = sessionValues.searchAndReplaceOptions;
          searchKey.currentState?.initializeValues(sessionValues.searchPatterns);
          replaceKey.currentState?.initializeValues(sessionValues.searchPatterns);
          folderKey.currentState?.initializeValues(sessionValues.folders);
          patternKey.currentState?.initializeValues(sessionValues.filePatterns);
        }
        var title = MatchResultList.current.title;
        return ValueListenableBuilder(
            valueListenable: searchInFilesController.running,
            builder: (_, value, __) => PksDialog(
                  title: Text(S.of(context).searchAndReplaceInFiles),
                  actions: _actions(),
                  children: [
                    _inputFields(),
                    const SizedBox(height: 20),
                    ValueListenableBuilder(valueListenable: title, builder: (context, value, child) => Text(value)),
                    Container(
                        height: 500,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColorLight)),
                        child: MatchResultListWidget(
                          MatchResultList.current,
                          onAccept: () {
                            widget.arguments.onAction(
                                context, SearchInFilesAction.openFile);
                          },
                          progress: searchInFilesController.running.value,
                        )),
                    SizedBox(width: 800, child: ValueListenableBuilder(valueListenable: searchInFilesController.progressInfo,
                        builder: (context, value, child) => Text(value, style: const TextStyle(overflow: TextOverflow.ellipsis, fontSize: 12),))),
                  ],
                ));
      });
}
