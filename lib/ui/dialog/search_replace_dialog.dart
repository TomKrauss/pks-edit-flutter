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

import 'package:flutter/material.dart';
import 'package:pks_edit_flutter/bloc/search_in_files_controller.dart';
import 'package:pks_edit_flutter/config/pks_sys.dart';
import 'package:pks_edit_flutter/ui/dialog/dialog.dart';
import 'package:pks_edit_flutter/generated/l10n.dart';
import 'package:pks_edit_flutter/ui/dialog/search_widgets.dart';
import 'package:re_editor/re_editor.dart';

///
/// Arguments to pass on to the search replace dialog.
///
class SearchReplaceDialogArguments {
  final CodeFindController findController;
  final bool replace;

  SearchReplaceDialogArguments(
      {required this.findController, this.replace = true});
}

///
/// Used to implement search and replace.
///
class SearchReplaceDialog extends StatefulWidget {
  final SearchReplaceDialogArguments arguments;

  static Future<void> show(
          {required BuildContext context,
          required SearchReplaceDialogArguments arguments}) =>
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => SearchReplaceDialog(arguments: arguments));

  const SearchReplaceDialog({required this.arguments, super.key});

  @override
  State<SearchReplaceDialog> createState() => _SearchReplaceDialogState();
}

class _SearchReplaceDialogState extends State<SearchReplaceDialog> {
  final GlobalKey<FindWidgetState> searchKey = GlobalKey(debugLabel: "find");
  final GlobalKey<ReplaceWidgetState> replaceKey =
      GlobalKey(debugLabel: "replace");
  SearchAndReplaceInFilesOptions parameter = SearchAndReplaceInFilesOptions();
  SearchAndReplaceOptions get options => parameter.options;
  bool _findInitialized = false;
  bool _sessionInitialized = false;
  final Future<PksEditSession> session =
      PksConfiguration.singleton.currentSession;

  CodeFindController get _findController => widget.arguments.findController;

  void searchTextChanged(String newValue) {
    _findInitialized = false;
    _applyOptions();
  }

  Widget _inputFields() => FutureBuilder(
      future: session,
      builder: (context, snapshot) {
        var sessionValues = snapshot.data;
        if (sessionValues != null && !_sessionInitialized) {
          _sessionInitialized = true;
          parameter.options = sessionValues.searchAndReplaceOptions;
          searchKey.currentState?.initializeValues(sessionValues.searchPatterns);
          replaceKey.currentState
              ?.initializeValues(sessionValues.replacePatterns);
        }
        return SizedBox(
            width: 650,
            child: Column(children: [
              FindWidget(
                  key: searchKey,
                  label: S.of(context).enterTextToFind,
                  parameter: parameter,
                  onChanged: searchTextChanged,
                  onAccept: (s) {
                    _find();
                  }),
              if (replaceMode)
                ReplaceWidget(
                    key: replaceKey,
                    label: S.of(context).enterTextToReplace,
                    onAccept: (s) {
                      _replace();
                    },
                    parameter: parameter),
            ]));
      });

  DialogAction _button(String text, VoidCallback callback) =>
      DialogAction(text: text, onPressed: callback);

  void _applyOptions() {
    if (_findInitialized) {
      return;
    }
    _findController.value = CodeFindValue(
        option: CodeFindOption(
            regex: options.regex,
            caseSensitive: !options.ignoreCase,
            pattern: ""),
        replaceMode: replaceMode);
    _findInitialized = true;
    _findController.findInputController.text = searchText;
  }

  bool get replaceMode => widget.arguments.replace;

  void saveSessionConfig() {
    PksConfiguration.singleton.currentSession.then((session) {
      searchKey.currentState?.saveSession(session);
      replaceKey.currentState?.saveSession(session);
      session.searchAndReplaceOptions = parameter.options;
    });
  }

  void _find() {
    saveSessionConfig();
    _findController.nextMatch();
  }

  void _replace() {
    saveSessionConfig();
    _findController.findInputController.text = searchText;
    _findController.replaceInputController.text = replaceText;
    _findController.nextMatch();
    _findController.replaceMatch();
  }

  String get searchText => searchKey.currentState?.value ?? "";
  String get replaceText => replaceKey.currentState?.value ?? "";

  List<DialogAction> _actions() => [
        _button(S.of(context).find, _find),
        if (replaceMode) _button(S.of(context).replace, _replace),
        if (replaceMode)
          _button(S.of(context).replaceAll, () {
            _findController.findInputController.text = searchText;
            _findController.replaceInputController.text = replaceText;
            _findController.replaceAllMatches();
            Navigator.of(context).pop();
          }),
        DialogAction.createCancelAction(context)
      ];

  @override
  Widget build(BuildContext context) => PksDialog(
      title: Text(replaceMode ? S.of(context).replace : S.of(context).find),
      actions: _actions(),
      children: [_inputFields()]);
}
