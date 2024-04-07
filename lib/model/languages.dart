//
// languages.dart
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

import 'package:highlight/highlight.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/go.dart';
import 'package:highlight/languages/htmlbars.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/properties.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/xml.dart';
import 'package:highlight/languages/yaml.dart';

///
/// Support for programming languages.
///
class Languages {
  static final Languages singleton = Languages._();
  Languages._();
  final Map<RegExp, Mode> _languageMappings = {
    RegExp(r".*\.java"): java,
    RegExp(r".*\.dart"): dart,
    RegExp(r".*\.go"): go,
    RegExp(r".*\.(properties|prop)"): properties,
    RegExp(r".*\.(json|jsn)"): json,
    RegExp(r".*\.(yaml|yml)"): yaml,
    RegExp(r".*\.c"): cpp,
    RegExp(r".*\.(c\+\+|cpp)"): cpp,
    RegExp(r".*\.(html|xhtml|htm)"): htmlbars,
    RegExp(r".*\.xml"): xml,
    RegExp(r".*\.py"): python,
  };

  Mode modeForFilename(String fileName) {
    for (var e in _languageMappings.entries) {
      if (e.key.hasMatch(fileName)) {
        return e.value;
      }
    }
    return Mode();
  }

}
