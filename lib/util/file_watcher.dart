//
// file_watcher.dart
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

import 'dart:async';
import 'dart:io';

import 'package:rxdart/rxdart.dart';

///
/// Helps us to keep track of file modifications.
///
class FileWatcher {
  static final FileWatcher singleton = FileWatcher._();
  FileWatcher._();
  final StreamController<FileSystemEvent> _controller = BehaviorSubject();
  final Map<String, Stream<FileSystemEvent>> _watchedEntities = {};

  ///
  /// Add a file to watch for changes. We should also support an API
  /// for getting rid of watches.
  ///
  void addWatchedFile(String fileName) {
    var f = File(fileName).parent.absolute;
    if (_watchedEntities.containsKey(f.path)) {
      return;
    }
    final stream = f.watch();
    _watchedEntities[f.path] = stream;
    stream.listen(_controller.add);
  }

  ///
  /// Returns a stream listening to changes.
  ///
  Stream<FileSystemEvent> get changeEvents => _controller.stream;

}
