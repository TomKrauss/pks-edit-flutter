//
// file_stat_extension.dart
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

///
/// Some extensions on the file stat object.
///
extension FileStatExtension on FileStat {
  ///
  /// Whether this file can be written or is readOnly for the current user.
  ///
  bool get readOnly {
    var permissions = mode & 0xFFF;
    return (permissions & ((0x2 << 6) + (0x2 << 3) + 2)) == 0;
  }
}
