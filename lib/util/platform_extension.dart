//
// platform_extension.dart
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
/// Some additional utilities for the OS platform.
///
extension PlatformExtension on Platform {
  ///
  /// In contrast to the [Platform.pathSeparator], this separator is commonly
  /// used on the platform to separate multiple paths (as in the PATH environment variable).
  ///
  static String get filePathSeparator => Platform.isWindows ? ";" : ":";
}
