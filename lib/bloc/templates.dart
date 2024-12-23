//
// templates.dart
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

class Template {
  final bool useCopyright;
  final String text;
  Template({required this.useCopyright, required this.text});
}

class Templates {
  static final Templates singleton = Templates._();
  Templates._();
  final Map<RegExp, Template> _templates = {
    RegExp(r".*\.java"): Template(useCopyright: true, text: 'public void main(String[] args)\n    System.out.println("hello world");\n}'),
    RegExp(r".*\.dart"): Template(useCopyright: true, text: "void main(args) {\n   print('hello world');\n}"),
    RegExp(r".*\.(yaml|yml)"): Template(useCopyright: false, text: "sample:\n  property: hello"),
    RegExp(r".*\.(html|xhtml|htm)"): Template(useCopyright: false, text: '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">\n<html>\n</html>'),
    RegExp(r".*\.py"): Template(useCopyright: false, text:""),
  };

  String _evaluate(Template template) => template.text;

  String generateInitialContent(String fileName) {
    for (final e in _templates.entries) {
      if (e.key.hasMatch(fileName)) {
        return _evaluate(e.value);
      }
    }
    return "";
  }
}
