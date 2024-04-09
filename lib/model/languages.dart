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

import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart';
import 'package:re_highlight/languages/asciidoc.dart';
import 'package:re_highlight/languages/bash.dart';
import 'package:re_highlight/languages/basic.dart';
import 'package:re_highlight/languages/c.dart';
import 'package:re_highlight/languages/cpp.dart';
import 'package:re_highlight/languages/css.dart';
import 'package:re_highlight/languages/dart.dart';
import 'package:re_highlight/languages/dockerfile.dart';
import 'package:re_highlight/languages/dos.dart';
import 'package:re_highlight/languages/excel.dart';
import 'package:re_highlight/languages/go.dart';
import 'package:re_highlight/languages/groovy.dart';
import 'package:re_highlight/languages/ini.dart';
import 'package:re_highlight/languages/java.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/languages/markdown.dart';
import 'package:re_highlight/languages/properties.dart';
import 'package:re_highlight/languages/protobuf.dart';
import 'package:re_highlight/languages/python.dart';
import 'package:re_highlight/languages/typescript.dart';
import 'package:re_highlight/languages/xml.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/re_highlight.dart';

class Language {
  final Mode mode;
  final String name;
  final String? description;
  final List<String> extensions;
  const Language({required this.name, required this.mode, this.description, this.extensions = const[]});
}

///
/// Support for programming languages.
///
class Languages {
  static final Languages singleton = Languages._();
  Languages._();
  final Map<RegExp, Language> _languageMappings = {
    RegExp(r".*\.java"): Language(name: "java", mode: langJava, extensions: ["java"], description: "Java Files"),
    RegExp(r".*\.dart"): Language(name: "dart", mode: langDart, extensions: ["dart"], description: "Dart Files"),
    RegExp(r".*\.go"): Language(name: "go", mode: langGo, extensions: ["go"]),
    RegExp(r".*\.protobuf"): Language(name: "protobuf", mode: langProtobuf, extensions: ["protobuf"]),
    RegExp(r".*\.ini"): Language(name: "ini", mode: langIni),
    RegExp(r".*\.(properties|prop)"): Language(name: "properties", mode: langProperties),
    RegExp(r".*\.(json|jsonx)"): Language(name: "json", mode: langJson, extensions: ["json", "jsonx"]),
    RegExp(r".*\.(yaml|yml)"): Language(name: "yaml", mode: langYaml, extensions: ["yaml", "yml"]),
    RegExp(r".*\.adoc"): Language(name: "adoc", mode: langAsciidoc),
    RegExp(r"Dockerfile"): Language(name: "docker", mode: langDockerfile),
    RegExp(r".*\.js"): Language(name: "javascript", mode: langJavascript, extensions: ["js"], description: "JavaScript Files"),
    RegExp(r".*\.ts"): Language(name: "typescript", mode: langTypescript, extensions: ["ts"], description: "TypeScript Files"),
    RegExp(r".*\.css"): Language(name: "css", mode: langCss),
    RegExp(r".*\.csv"): Language(name: "csv", mode: langExcel),
    RegExp(r".*\.c"): Language(name: "c", mode: langC, extensions: ["c"]),
    RegExp(r".*\.(c\+\+|cpp)"): Language(name: "c++", mode: langCpp, extensions: ["cpp"]),
    RegExp(r".*\.(html|xhtml|htm)"): Language(name: "html", mode: langXml),
    RegExp(r".*\.md"): Language(name: "markdown", mode: langMarkdown),
    RegExp(r".*\.bat"): Language(name: "batch", mode: langDos),
    RegExp(r".*\.(xml|pom)"): Language(name: "xml", mode: langXml),
    RegExp(r".*\.(gradle|groovy)"): Language(name: "groovy", mode: langGroovy),
    RegExp(r".*\.py"): Language(name: "python", mode: langPython),
    RegExp(r"[^.]+"): Language(name: "shell", mode: langBash),
  };
  final Language defaultLanguage = Language(name: "basic", mode: langBasic);

  Language modeForFilename(String fileName) {
    for (var e in _languageMappings.entries) {
      if (e.key.hasMatch(fileName)) {
        return e.value;
      }
    }
    return defaultLanguage;
  }

  List<XTypeGroup> getFileGroups(String currentFile) {
    final result = <XTypeGroup>[];
    var ext = extension(currentFile);
    if (ext.startsWith(".")) {
      ext = ext.substring(1);
    }
    bool extFound = false;
    for (var e in _languageMappings.entries) {
      if (e.value.extensions.isNotEmpty) {
        final group = XTypeGroup(label: e.value.description ?? e.value.name, extensions: e.value.extensions);
        if (e.value.extensions.contains(ext)) {
          result.insert(0, group);
          extFound = true;
        } else {
          result.add(group);
        }
      }
    }
    const group = XTypeGroup(label: "Other files", extensions: ["*"]);
    if (extFound) {
      result.add(group);
    } else {
      result.insert(0, group);
    }
    return result;
  }
}
