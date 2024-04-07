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

///
/// Represents an action to be executed by PKS-Edit.
///
class PksEditAction {
  final String id;
  String? text;
  IconData? icon;
  ///
  /// Returns the label to be used to display the action in a UI.
  ///
  String get label => text ?? id;
  final bool Function(Object? context) isEnabled;
  final void Function(Object? context) execute;

  bool get displayInToolbar => icon != null;
  bool get displayInMenu => true;

  static bool _alwaysEnabled(Object? context) => true;

  PksEditAction({required this.id, this.isEnabled = _alwaysEnabled, required this.execute,
    this.text, this.icon});
}
