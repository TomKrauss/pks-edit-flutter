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
import 'package:highlight/languages/dos.dart';
import 'package:highlight/languages/go.dart';
import 'package:highlight/languages/groovy.dart';
import 'package:highlight/languages/htmlbars.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/markdown.dart';
import 'package:highlight/languages/properties.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/xml.dart';
import 'package:highlight/languages/yaml.dart';

class Language {
  final Mode mode;
  final String name;
  const Language({required this.name, required this.mode});
}

///
/// Support for programming languages.
///
class Languages {
  static final Languages singleton = Languages._();
  Languages._();
  final Map<RegExp, Language> _languageMappings = {
    RegExp(r".*\.java"): Language(name: "java", mode: java),
    RegExp(r".*\.dart"): Language(name: "dart", mode: dart),
    RegExp(r".*\.go"): Language(name: "go", mode: go),
    RegExp(r".*\.(properties|prop)"): Language(name: "properties", mode: properties),
    RegExp(r".*\.(json|jsn)"): Language(name: "json", mode: json),
    RegExp(r".*\.(yaml|yml)"): Language(name: "yaml", mode: yaml),
    RegExp(r".*\.c"): Language(name: "cpp", mode: cpp),
    RegExp(r".*\.(c\+\+|cpp)"): Language(name: "c", mode: cpp),
    RegExp(r".*\.(html|xhtml|htm)"): Language(name: "html", mode: htmlbars),
    RegExp(r".*\.md"): Language(name: "markdown", mode: markdown),
    RegExp(r".*\.bat"): Language(name: "batch", mode: dos),
    RegExp(r".*\.(xml|pom)"): Language(name: "xml", mode: xml),
    RegExp(r".*\.(gradle|groovy)"): Language(name: "groovy", mode: groovy),
    RegExp(r".*\.py"): Language(name: "python", mode: python),
  };

  Language modeForFilename(String fileName) {
    for (var e in _languageMappings.entries) {
      if (e.key.hasMatch(fileName)) {
        return e.value;
      }
    }
    return Language(name: "Unknown", mode: Mode());
  }

}
