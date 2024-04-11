//
// main.dart
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
import 'package:pks_edit_flutter/bloc/bloc_provider.dart';
import 'package:pks_edit_flutter/bloc/editor_bloc.dart';
import 'package:pks_edit_flutter/ui/main_page.dart';
import 'package:window_manager/window_manager.dart';

///
/// Start the PKS Edit application
///
void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.setPreventClose(true);
  runApp(SimpleBlocProvider(
      commandLineArguments: args,
      child: const PksEditApplication()));
}

///
/// The main window of PKS Edit.
///
class PksEditApplication extends StatelessWidget {
  const PksEditApplication({super.key});

  ThemeData _createTheme(BuildContext context) {
    final bloc = EditorBloc.of(context);
    var themeName = bloc.applicationConfiguration.theme;
    if (themeName == "dark") {
      return ThemeData(
          colorScheme: const ColorScheme.dark(),
          dividerColor: Colors.white24,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.white10));
    }
    if (themeName == "spring") {
      return ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
          dividerColor: Colors.green.shade200,
          appBarTheme: AppBarTheme(backgroundColor: Colors.green.shade50));
    }
    if (themeName == "pink") {
      return ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
          dividerColor: Colors.pink.shade200,
          appBarTheme: AppBarTheme(backgroundColor: Colors.pink.shade50));
    }
    return ThemeData(
        colorScheme: const ColorScheme.light(),
        dividerColor: Colors.black26,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black12));
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
          title: 'PKS EDIT',
          debugShowCheckedModeBanner: false,
          theme: _createTheme(context),
          home: const PksEditMainPage(title: 'PKS EDIT'),
        );
}
