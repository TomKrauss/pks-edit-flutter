//
// actions.dart
//
// PKS-EDIT - Flutter
//
// Last modified: 07.04.24, 08:07
// Author: Tom Krauß
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import 'package:flutter/cupertino.dart';
import 'package:pks_edit_flutter/bloc/editor_bloc.dart';

///
/// Context used in actions to evaluate actions and action enablement.
///
class PksEditActionContext {
  final OpenFileState? openFileState;
  final OpenFile? _currentFile;
  OpenFile? get currentFile => _currentFile ?? openFileState?.currentFile;
  PksEditActionContext({required this.openFileState, OpenFile? currentFile}) : _currentFile = currentFile;
}

///
/// Represents an action to be executed by PKS-Edit.
///
class PksEditAction {
  static const String fileGroup = "file";
  static const String editGroup = "edit";
  static const String findGroup = "find";
  static const String viewGroup = "view";
  static const String windowGroup = "window";
  static const String functionGroup = "function";
  static const String defaultGroup = "default";
  final String id;
  final String? _description;
  final String group;
  final PksEditActionContext context;
  final MenuSerializableShortcut? shortcut;
  ///
  /// Add a separator before creating a button in the toolbar / in a menu before adding
  /// the button for this action.
  ///
  final bool separatorBefore;
  String? text;
  IconData? icon;
  ///
  /// Returns the label to be used to display the action in a UI.
  ///
  String get label => text ?? id;
  ///
  /// Returns the text to be displayed as a description (tooltip) for this action
  ///
  String get description => _description ?? label;
  final bool Function(PksEditActionContext context) isEnabled;
  final void Function(PksEditActionContext context) execute;

  bool get displayInToolbar => icon != null;
  bool get displayInMenu => true;

  void Function()? get onPressed => isEnabled(context) ? () { execute(context);} : null;

  static bool _alwaysEnabled(Object? context) => true;

  PksEditAction({required this.id, this.isEnabled = _alwaysEnabled,
    required this.execute,
    required this.context,
    this.separatorBefore = false,
    this.shortcut,
    this.group = defaultGroup,
    this.text, this.icon, String? description}) : _description = description;
}
