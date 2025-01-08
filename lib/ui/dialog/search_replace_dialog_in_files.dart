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

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:pks_edit_flutter/generated/l10n.dart';
import 'package:pks_edit_flutter/ui/dialog/dialog.dart';

class SearchAndReplaceInFilesParameter {
  String directory = File(".").absolute.path;
  String fileNamePattern = "*.txt";
  String search = "";
  String replace = "";
  bool regex = true;
  bool ignoreCase = true;
  bool preserveUpperLowerCase = true;
  bool singleMatchInFile = false;
  bool ignoreBinaryFiles = true;
}

///
/// Arguments to pass on to the search replace dialog.
///
class SearchReplaceInFilesDialogArguments {
  final String initialSearchPattern;

  SearchReplaceInFilesDialogArguments({this.initialSearchPattern = ""});
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
  late final parameter = SearchAndReplaceInFilesParameter();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _fileNamePatternController = TextEditingController(text: "*.txt");
    _directoryController = TextEditingController(text: File(".").absolute.path);
    _searchController =
        TextEditingController(text: widget.arguments.initialSearchPattern);
    _replaceController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _applyOptions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _replaceController.dispose();
    _fileNamePatternController.dispose();
    _directoryController.dispose();
    super.dispose();
  }

  Widget _editor(String label, IconData icon, TextEditingController controller,
      VoidCallback onSubmitted) {
    final searchField = onSubmitted == _find;
    return Padding(
        padding: _padding,
        child: TextField(
            controller: controller,
            onSubmitted: (newValue) {
              onSubmitted();
              Navigator.of(context).pop(parameter);
            },
            autofocus: searchField,
            decoration: InputDecoration(icon: Icon(icon), hintText: label)));
  }

  Widget _folderSelector(String label, IconData icon,
          TextEditingController controller, VoidCallback onSubmitted) =>
      Padding(
          padding: _padding,
          child: Row(children: [
            Flexible(
                child: TextField(
                    controller: controller,
                    onSubmitted: (newValue) {
                      onSubmitted();
                      Navigator.of(context).pop(parameter);
                    },
                    decoration:
                        InputDecoration(icon: Icon(icon), hintText: label))),
            const SizedBox(width: 10),
            IconButton(
                onPressed: _selectFolder,
                icon: Icon(Icons.folder_copy_outlined))
          ]));

  Future<void> _selectFolder() async {
    var result = await getDirectoryPath(initialDirectory: parameter.directory, confirmButtonText: "Select Folder");
    if (result != null) {
      _directoryController.text = result;
    }
  }

  Widget _inputFields() => SizedBox(
      width: 500,
      child: Column(children: [
        _editor(S.of(context).enterTextToFind, Icons.search, _searchController,
            _find),
        _editor(S.of(context).enterTextToReplace, Icons.find_replace,
            _replaceController, _replace),
        _editor("File Name Patterns", Icons.filter, _fileNamePatternController,
            _find),
        _folderSelector("Find in Folder", Icons.folder, _directoryController, _find),
      ]));

  void _find() {}

  void _replace() {}
  Widget _option(
          String label, bool value, void Function(bool newValue) onChanged) =>
      CheckboxListTile(
          value: value,
          title: Text(label),
          contentPadding: EdgeInsets.zero,
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                onChanged(newValue);
                _initialized = false;
                _applyOptions();
              });
            }
          });

  Widget _options() => SizedBox(
      width: 200,
      child: Column(
        children: [
          _option(S.of(context).regularExpressions, parameter.regex,
              (newValue) {
            parameter.regex = newValue;
          }),
          _option(S.of(context).ignoreCase, parameter.ignoreCase, (newValue) {
            parameter.ignoreCase = newValue;
          }),
          _option("Single match in File", parameter.ignoreCase, (newValue) {
            parameter.ignoreCase = newValue;
          }),
          _option("Ignore binary Files", parameter.ignoreBinaryFiles,
              (newValue) {
            parameter.ignoreBinaryFiles = newValue;
          }),
          _option("Preserve upper/lower Case", parameter.preserveUpperLowerCase,
              (newValue) {
            parameter.preserveUpperLowerCase = newValue;
          }),
        ],
      ));

  DialogAction _button(String text, VoidCallback callback) =>
      DialogAction(text: text, onPressed: callback);

  void _applyOptions() {
    if (_initialized) {
      return;
    }
  }

  List<DialogAction> _actions() => [
        _button(S.of(context).find, _find),
        _button(S.of(context).replace, _replace),
        DialogAction.createCancelAction(context)
      ];

  @override
  Widget build(BuildContext context) => PksDialog(
        title: Text("Search and Replace in Files"),
        actions: _actions(),
        children: [
          Row(children: [
            _inputFields(),
            const SizedBox(width: 20),
            _options(),
          ]),
        ],
      );
}
