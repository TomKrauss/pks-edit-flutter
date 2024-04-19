
//
// bloc_provider.dart
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

import 'package:flutter/material.dart';
import 'package:pks_edit_flutter/bloc/editor_bloc.dart';

///
/// Widget providing the application context allowing to access the BLOCs of the application.
///
class ApplicationContextWidget extends InheritedWidget {
  const ApplicationContextWidget({
    super.key,
    required this.bloc,
    required super.child,
  });

  final EditorBloc bloc;

  @override
  bool updateShouldNotify(ApplicationContextWidget oldWidget) => bloc != oldWidget.bloc;
}

///
/// This stateful widget provides access to the Business Logic Components (BLOC)
/// of PKS Edit.
///
class SimpleBlocProvider extends StatefulWidget {
  final Widget child;
  final List<String> commandLineArguments;
  const SimpleBlocProvider({super.key, required this.child, required this.commandLineArguments});

  @override
  State<StatefulWidget> createState() => SimpleBlocState();

  static ApplicationContextWidget _contextWidget(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ApplicationContextWidget>()!;

  static EditorBloc of(BuildContext context) => _contextWidget(context).bloc;
}

///
/// State of the bloc provider widget.
///
class SimpleBlocState<S extends SimpleBlocProvider> extends State<S> {
  bool _initialized = false;
  late final EditorBloc bloc;

  @protected
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    bloc = EditorBloc();
    await bloc.initialize(arguments: widget.commandLineArguments);
    _initialized = true;
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
    _initialized = false;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(future: initialize(), builder: (context, snapshot) {
    if (!snapshot.hasData) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Theme(
            data: ThemeData(colorScheme: const ColorScheme.light(background: Colors.white), useMaterial3: false),
            child: const Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasError) {
        return ErrorWidget("Error initializing BLOC: ${snapshot.error}");
      }
    }
    return ApplicationContextWidget(
      bloc: bloc,
      child: widget.child,
    );
  }
  );
}

