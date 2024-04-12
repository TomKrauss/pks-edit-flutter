//
// statusbar_widget.dart
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
import 'package:pks_edit_flutter/bloc/editor_bloc.dart';

///
/// A widget displaying status information about the currently active file.
///
class StatusBarWidget extends StatelessWidget {
  final OpenFileState fileState;
  const StatusBarWidget({super.key, required this.fileState});

  @override
  Widget build(BuildContext context) {
    var current = fileState.currentFile;
    final divider = VerticalDivider(
        color: Theme.of(context).dividerColor, width: 20);
    var row = (current == null)
        ? const Row(
      children: [Text("")],
    )
        : IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(current.filename),
            Row(children: [
              divider,
              Tooltip(message: current.readOnly ? "Read-only" : "Writeable", child: Icon(current.readOnly ? Icons.lock_outline : Icons.lock_open, size: 16)),
              divider,
              Text(current.encoding.name),
              divider,
              Tooltip(message: "Used Grammar", child: Text(current.language.name))
            ])
          ],
        ));
    return Container(
        color: Theme.of(context).appBarTheme.backgroundColor,
        child: Padding(padding: const EdgeInsets.all(4), child: row));
  }
}
