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
import 'package:flutter/services.dart';
import 'package:pks_edit_flutter/actions/actions.dart';
import 'package:pks_edit_flutter/ui/dialog/dialog.dart';

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
  final TextInputType keyboardType;
  ///
  /// An optional input validator.
  ///
  final String? Function(String value)? validator;

  InputDialogArguments(
      {required this.context,
      required this.title,
      required this.inputLabel,
      this.validator,
      this.keyboardType = TextInputType.text,
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
  String? _validationHint;
  late final TextEditingController controller;
  late final Map<String, bool> selectedOptions;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.arguments.initialValue);
    selectedOptions = {}..addAll(widget.arguments.options);
    controller.addListener(() {
      if (widget.arguments.validator != null) {
        _validationHint = widget.arguments.validator!(controller.text);
      }
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
    for (final entry in selectedOptions.entries) {
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

  List<TextInputFormatter>? get inputFormatters {
    if (widget.arguments.keyboardType == TextInputType.number) {
      return [ FilteringTextInputFormatter.digitsOnly ];
    }
    return null;
  }
  @override
  Widget build(BuildContext context) => PksDialog(
          title: Text(widget.arguments.title),
          actions: [
            DialogAction(
                text: "OK",
                onPressed: controller.text.isEmpty || _validationHint != null
                    ? null
                    : _submit,
                ),
            DialogAction.createCancelAction(context)
          ],
          children: [
            Row(
                children: [
              Text("${widget.arguments.inputLabel}:"),
              const SizedBox(width: 10),
              Expanded(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 300, minHeight: 50),
                      child:
                          TextField(controller: controller, autofocus: true,
                            keyboardType: widget.arguments.keyboardType,
                            inputFormatters: inputFormatters,
                            onSubmitted: (s) {
                              _submit();
                            },
                            decoration: InputDecoration(errorText: _validationHint).applyDefaults(Theme.of(context).inputDecorationTheme),
                          )))
            ]),
            const SizedBox(height: 10),
            ...buildOptions(),
          ]);

  void _submit() {
    if (controller.text.isEmpty || _validationHint != null) {
      return;
    }
    Navigator.of(context).pop(InputResult(selectedText: controller.text, selectedOptions: selectedOptions));
  }
}
