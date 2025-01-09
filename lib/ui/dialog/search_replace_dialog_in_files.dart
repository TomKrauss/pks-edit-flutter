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
import 'package:pks_edit_flutter/bloc/search_in_files_controller.dart';
import 'package:pks_edit_flutter/generated/l10n.dart';
import 'package:pks_edit_flutter/ui/dialog/dialog.dart';

///
/// Arguments to pass on to the search replace dialog.
///
class SearchReplaceInFilesDialogArguments {
  final String initialSearchPattern;
  final bool supportReplace;

  SearchReplaceInFilesDialogArguments({this.initialSearchPattern = "", this.supportReplace = true});
}

class SearchResultList extends StatelessWidget {
  final SearchInFilesController controller;
  const SearchResultList(this.controller, {super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder(stream: controller.results, builder: (context, snapshot) {
    final data = snapshot.data;
    if (data == null || data.isEmpty) {
      return Center(child: Text("no results"));
    }
    return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: data.map((d) => Text(d.printMatch())).toList()));
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
  late final parameter = SearchAndReplaceInFilesOptions();
  final SearchInFilesController searchInFilesController = SearchInFilesController();

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

  Widget _editor(String label, IconData icon, bool autoFocus, TextEditingController controller, {List<Widget>? options}) => Padding(
        padding: _padding,
        child: TextField(
            controller: controller,
            autofocus: autoFocus,
            decoration: InputDecoration(icon: Icon(icon), hintText: label,
                suffix: options == null ? null : Row(mainAxisSize: MainAxisSize.min, children: options,))));

  Widget _folderSelector(String label, IconData icon,
          TextEditingController controller, {List<Widget>? options}) =>
      Padding(
          padding: _padding,
          child: Row(children: [
            Flexible(
                child: TextField(
                    controller: controller,
                    decoration:
                        InputDecoration(icon: Icon(icon), hintText: label, suffix: options == null ? null : Row(mainAxisSize: MainAxisSize.min, children: options,)))),
            const SizedBox(width: 10),
            Tooltip(message: 'Select Directory', child: IconButton(
                onPressed: _selectFolder,
                icon: Icon(Icons.folder_copy_outlined)))
          ]));

  Future<void> _selectFolder() async {
    var result = await getDirectoryPath(initialDirectory: parameter.directory, confirmButtonText: "Select Folder");
    if (result != null) {
      _directoryController.text = result;
    }
  }

  Widget _inputFields() => SizedBox(
      width: 800,
      child: Column(children: [
        Row(children: [
          Expanded(flex: 3, child:_folderSelector("Find in Folder", Icons.folder, _directoryController, options: [
            _optionButton("1", "Single Match in File", parameter.singleMatchInFile, (newValue) {
              parameter.singleMatchInFile = newValue;
            }),
            _optionButton("0x", "Ignore Binary Files", parameter.ignoreBinaryFiles, (newValue) {
              parameter.ignoreBinaryFiles = newValue;
            }),
          ])),
          Flexible(child: _editor("File Name Patterns", Icons.filter, false, _fileNamePatternController))
        ]),
        _editor(S.of(context).enterTextToFind, Icons.search, true, _searchController, options: [
          _optionButton(".*", "Match regular Expressions", parameter.regex, (newValue) {
                parameter.regex = newValue;
              }),
          _optionButton("Cc", "Ignore Case", parameter.ignoreCase, (newValue) {
            parameter.ignoreCase = newValue;
          }),
        ]),
        if (widget.arguments.supportReplace)
        _editor(S.of(context).enterTextToReplace, Icons.find_replace, false, _replaceController, options: [
          _optionButton("AA", "Preserve Case", parameter.preserveUpperLowerCase, (newValue) {
            parameter.preserveUpperLowerCase = newValue;
          }),
        ])]));

  void _find() {
    _applyOptions();
    parameter.action = SearchInFilesAction.search;
    searchInFilesController.run(parameter);
    //Navigator.pop(context, parameter);
  }

  void _replace() {
    _applyOptions();
    parameter.action = SearchInFilesAction.replace;
    Navigator.pop(context, parameter);
  }

  Widget _optionButton(String label, String tooltip, bool value, void Function(bool newValue) onChanged) {
    var theme = Theme.of(context);
    var style = ElevatedButton.styleFrom(
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      fixedSize: Size(25, 25),
      minimumSize: Size.zero,
      backgroundColor: theme.colorScheme.primary.withAlpha(30),
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5)))
    );
    if (value) {
      style = style.copyWith(foregroundColor: WidgetStatePropertyAll(theme.colorScheme.onPrimary),
          backgroundColor: WidgetStatePropertyAll(theme.colorScheme.primary));
    }
    return Padding(padding: EdgeInsets.only(left: 10), child: Tooltip(message: tooltip, child: ElevatedButton(onPressed: () {
      setState(() {
        onChanged(!value);
      });
    },
      style: style, child: Text(label), )));
  }

  DialogAction _button(String text, VoidCallback? callback) =>
      DialogAction(text: text, onPressed: callback);

  void _applyOptions() {
    parameter.fileNamePattern = _fileNamePatternController.text;
    parameter.directory = _directoryController.text;
    parameter.search = _searchController.text;
    parameter.replace = _replaceController.text;
  }

  List<DialogAction> _actions() => [
        _button(S.of(context).find, searchInFilesController.running.value ? null : _find),
        _button(S.of(context).replace, searchInFilesController.running.value ? null : _replace),
        DialogAction.createCancelAction(context)
      ];

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(valueListenable: searchInFilesController.running, builder: (_, value, __) => PksDialog(
        title: Text("Search and Replace in Files"),
        actions: _actions(),
        children: [
          _inputFields(),
          SizedBox(height: 500, width: 750, child: SearchResultList(searchInFilesController))
        ],
      ));
}
