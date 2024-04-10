//
// input_dialog.dart
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
import 'package:pks_edit_flutter/ui/actions.dart';

///
/// Arguments to pass on to the input dialog.
///
class InputDialogArguments {
  final PksEditActionContext context;
  final String? initialValue;
  /// Can be used to display additional checkboxes with the text and initial selection defined by the entries in this map.
  /// If specified, the result will have a flag, whether the option had been selected.
  final Map<String,bool> options;
  final String inputLabel;
  final String title;

  InputDialogArguments(
      {required this.context,
      required this.title,
      required this.inputLabel,
        this.options = const {},
      this.initialValue});
}

///
/// The result of the input selecting
///
class InputResult {
  final String selectedText;
  final Map<String, bool> selectedOptions;
  bool get firstOptionSelected => selectedOptions.values.firstOrNull ?? false;
  InputResult({required this.selectedText, required this.selectedOptions});
}

///
/// Can be used to prompt for an arbitrary text input of the user.
///
class InputDialog extends StatefulWidget {
  final InputDialogArguments arguments;
  const InputDialog({super.key, required this.arguments});

  static Future<InputResult?> show(
          {required BuildContext context,
          required InputDialogArguments arguments}) =>
      showDialog(
          context: context,
          builder: (context) => InputDialog(arguments: arguments));

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  late final TextEditingController controller;
  late final Map<String, bool> selectedOptions;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.arguments.initialValue);
    selectedOptions = {}..addAll(widget.arguments.options);
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  ///
  /// Build the options widgets
  ///
  List<Widget> buildOptions() {
    var result = <Widget>[];
    for (var entry in selectedOptions.entries) {
      result.add(CheckboxListTile(
        contentPadding: EdgeInsets.zero,
          title: Text(entry.key), value: entry.value, onChanged: (newSel) {
        selectedOptions[entry.key] = newSel ?? false;
      }));
    }
    if (result.isNotEmpty) {
      result.add(const SizedBox(height: 20));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) => SimpleDialog(
          title: Text(widget.arguments.title),
          contentPadding: const EdgeInsets.all(25),
          children: [
            Row(
                children: [
              Text("${widget.arguments.inputLabel}:"),
              const SizedBox(width: 10),
              Expanded(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 300),
                      child:
                          TextField(controller: controller, autofocus: true)))
            ]),
            const SizedBox(height: 10),
            ...buildOptions(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: controller.text.isEmpty
                        ? null
                        : () {
                            Navigator.of(context).pop(InputResult(selectedText: controller.text, selectedOptions: selectedOptions));
                          },
                    child: const Text("OK")),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(null);
                    },
                    child: const Text("Cancel")),
              ],
            )
          ]);
}
