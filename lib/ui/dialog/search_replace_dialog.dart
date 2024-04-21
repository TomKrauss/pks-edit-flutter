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
import 'package:pks_edit_flutter/ui/dialog/dialog.dart';
import 'package:pks_edit_flutter/generated/l10n.dart';
import 'package:re_editor/re_editor.dart';

///
/// Arguments to pass on to the search replace dialog.
/// 
class SearchReplaceDialogArguments {
  final CodeFindController findController;
  final String initialSearchPattern;
  final bool replace;

  SearchReplaceDialogArguments({required this.findController, this.initialSearchPattern = "", this.replace = true});
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
  static const _padding = EdgeInsets.all(10);
  late final FocusNode _searchNode;
  late final TextEditingController _searchController;
  late final TextEditingController _replaceController;
  bool _regex = true;
  bool _ignoreCase = true;
  bool _findInitialized = false;

  CodeFindController get _findController => widget.arguments.findController;

  @override
  void initState() {
    super.initState();
    _searchNode = FocusNode();
    _searchController = TextEditingController(text: widget.arguments.initialSearchPattern);
    _searchController.addListener(() {
      if (_findController.findInputController.text == _searchController.text) {
        return;
      }
      _findController.findInputController.text = _searchController.text;
    });
    _replaceController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _applyOptions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _replaceController.dispose();
    _searchNode.dispose();
    super.dispose();
  }

  Widget _editor(String label, IconData icon, TextEditingController controller, VoidCallback onSubmitted) {
    final searchField = onSubmitted == _find;
    return Padding(padding: _padding, child: TextField(controller: controller,
        onSubmitted: (newValue) {
          onSubmitted();
          Navigator.of(context).pop();
        },
        focusNode: searchField ? _searchNode : null,
        autofocus: searchField,
        decoration: InputDecoration(icon: Icon(icon), hintText: label)));
  }

  Widget _inputFields() => SizedBox(width: 400, child: Column(
    children: [
      _editor(S.of(context).enterTextToFind, Icons.search, _searchController, _find),
      if (replaceMode)
      _editor(S.of(context).enterTextToReplace, Icons.find_replace, _replaceController, _replace),
    ]
  ));

  Widget _option(String label, bool value, void Function(bool newValue) onChanged) =>
      CheckboxListTile(value: value, title: Text(label), contentPadding: EdgeInsets.zero, onChanged: (newValue) {
        if (newValue != null) {
          setState(() {
            onChanged(newValue);
            _findInitialized = false;
            _applyOptions();
          });
        }
      });

  Widget _options() => SizedBox(width: 200, child: Column(children: [
    _option(S.of(context).regularExpressions, _regex, (newValue) {
      _regex = newValue;
    }),
    _option(S.of(context).ignoreCase, _ignoreCase, (newValue) {
      _ignoreCase = newValue;
    }),
  ],));

  DialogAction _button(String text, VoidCallback callback) =>
      DialogAction(text: text, onPressed: callback);

  void _applyOptions() {
    if (_findInitialized) {
      return;
    }
    _findController.value = CodeFindValue(
        option: CodeFindOption(regex: _regex, caseSensitive: !_ignoreCase, pattern: ""),
        replaceMode: replaceMode);
    _findInitialized = true;
    _findController.findInputController.text = _searchController.text;
  }

  bool get replaceMode => widget.arguments.replace;

  void _find() {
    _findController.nextMatch();
  }

  void _replace() {
    _findController.findInputController.text = _searchController.text;
    _findController.replaceInputController.text = _replaceController.text;
    _findController.nextMatch();
    _findController.replaceMatch();
  }

  List<DialogAction> _actions() => [
    _button(S.of(context).find, _find),
    if (replaceMode)
    _button(S.of(context).replace, _replace),
    if (replaceMode)
    _button(S.of(context).replaceAll, () {
      _findController.findInputController.text = _searchController.text;
      _findController.replaceInputController.text = _replaceController.text;
      _findController.replaceAllMatches();
      Navigator.of(context).pop();
    }),
    DialogAction.createCancelAction(context)
  ];

  @override
  Widget build(BuildContext context) =>
  PksDialog(
    title: Text(replaceMode ? S.of(context).replace : S.of(context).find),
    actions: _actions(),
    children: [
      Row(children: [_inputFields(), const SizedBox(width: 20), _options(),]),
    ],
  );
}
