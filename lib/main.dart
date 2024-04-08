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
import 'package:pks_edit_flutter/ui/main_page.dart';
import 'package:window_manager/window_manager.dart';

///
/// Start the PKS Edit application
///
void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.setPreventClose(true);
  runApp(PksEditApplication(arguments: args));
}

///
/// The main window of PKS Edit.
///
class PksEditApplication extends StatelessWidget {
  final List<String> arguments;
  const PksEditApplication({super.key, required this.arguments});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PKS EDIT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: const ColorScheme.dark(), dividerColor: Colors.white24),
      home: SimpleBlocProvider(commandLineArguments: arguments, child: const PksEditMainPage(title: 'PKS EDIT')),
    );
  }
}

