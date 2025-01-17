//
// grammar.dart
//
// PKS-EDIT - Flutter
//
// Last modified: 2025
// Author: Tom Krauß
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:pks_edit_flutter/config/editing_configuration.dart';
import 'package:pks_edit_flutter/config/pks_sys.dart';
import 'package:pks_edit_flutter/util/logger.dart';

part 'grammar.g.dart';

/// Describes the primary ways to comment code in the described language
class CommentDescriptor {
  final String? commentStart;		// This contains the 0-terminated string to start a comment - e.g. "/*"
  final String? commentEnd;		  // If only a block line comment feature is available, this contains the 0-terminated string to end it - e.g. "*/"
  final String? comment2Start;	// This may contain an alternate 0-terminated string to start a comment - e.g. "/*"
  final String? comment2End;		// If only a block line comment feature is available, this an alternate 0-terminated string to end it - e.g. "*/"
  final String? commentSingle;

  CommentDescriptor({this.commentStart, this.commentEnd,
    this.comment2Start, this.comment2End, this.commentSingle});		// This contains the 0-terminated string to start a single line comment - e.g. "//"

}

///
/// A template defined for a language.
///
@JsonSerializable()
class Template {
  final String? name;
  final String? pattern;
  final String contents;
  final bool auto;

  Template({required this.name, this.pattern, required this.contents, this.auto = false});

  static Template fromJson(Map<String, dynamic> jsonInput) =>
      _$TemplateFromJson(jsonInput);
  Map<String, dynamic> toJson() => _$TemplateToJson(this);
}

///
/// Describes a lexical token in a grammar.
///
@JsonSerializable()
class GrammarPattern {
  final String name;
  /// mutually exclusive with match, one may define a begin and end marker to match. May span multiple lines
  final String? begin;
  /// the end marker maybe e.g. '$' to match the end of line. Currently only one multi-line pattern supported.
  final String? end;
  final String? match;
  /// Special case: keywords are not delimited by word boundaries.
  final bool? keywordsNoIdentifiers;
  /// If an array list of keywords exists, these are matched after the pattern has matched.
  final List<String>? keywords;
  /// If matches should be performed in a case ignore way.
  final bool? ignoreCase;
  GrammarPattern({required this.name, this.begin, this.end, this.match, this.ignoreCase, this.keywordsNoIdentifiers, this.keywords});

  static GrammarPattern fromJson(Map<String, dynamic> jsonInput) =>
      _$GrammarPatternFromJson(jsonInput);
  Map<String, dynamic> toJson() => _$GrammarPatternToJson(this);
}

///
/// Describes the grammar of a source file edited.
///
@JsonSerializable()
class Grammar {
  /// Unique name of the grammar. One can associate document types with the scope name of a grammar
  /// in the document type definition.
  final String scopeName;
  @JsonKey(name: "import")
  final List<String> imports;
  /// The match patterns defining the lexical tokens. Currently mainly used to determine how comments
  /// will be inserted into a file.
  final List<GrammarPattern> _patterns;
  ///
  /// The code templates for this grammar.
  ///
  final List<Template> _templates;
  /// The description of the grammar;
  final String? description;

  List<Template> get templates => _templates;
  List<GrammarPattern> get patterns => _patterns;

  @JsonKey(includeFromJson: false, includeToJson: false)
  CommentDescriptor get commentDescriptor {
    GrammarPattern? singleLineCommentPattern;
    GrammarPattern? blockCommentPattern;
    GrammarPattern? otherBlockCommentPattern;
    for (final p in _patterns) {
      if (p.name.toLowerCase().contains("comment")) {
        if (p.begin != null && p.end != null) {
          var bDefault = p.name == "comment.multiLine";
          if (bDefault || blockCommentPattern == null) {
            blockCommentPattern = p;
          }
          if (!bDefault) {
            otherBlockCommentPattern = p;
          }
        } else {
          if (p.name == "comment.singleLine" || singleLineCommentPattern == null) {
            singleLineCommentPattern = p;
          }
        }
      }
    }
    var match = singleLineCommentPattern?.match;
    String? commentSingle;
    if (match != null) {
      var singleLineComment = StringBuffer();
      for (int i = 0; i < match.length; i++) {
        var c = match[i];
        if (c == '^') {
          continue;
        }
        if (c == '.' || c == '[') {
          break;
        }
        singleLineComment.write(c);
      }
      commentSingle = singleLineComment.toString();
    }
    return CommentDescriptor(commentStart: blockCommentPattern?.begin,
        commentEnd: blockCommentPattern?.end, commentSingle: commentSingle,
      comment2Start: otherBlockCommentPattern?.begin, comment2End: otherBlockCommentPattern?.end
    );
  }

  Grammar({required this.scopeName, this.description, List<GrammarPattern>? patterns, this.imports = const [], List<Template>? templates}) :
      _patterns = patterns ?? [],
      _templates = templates ?? [];

  static Grammar fromJson(Map<String, dynamic> jsonInput) =>
      _$GrammarFromJson(jsonInput);
  Map<String, dynamic> toJson() => _$GrammarToJson(this);

  void mergeWith(Grammar other) {
    _patterns.addAll(other._patterns);
    _templates.addAll(other._templates);

  }
}

///
/// We save always more than on grammar file in a grammar.
///
@JsonSerializable()
class Grammars {
  final List<Grammar> grammars;

  Grammars({required this.grammars});

  static Grammars fromJson(Map<String, dynamic> jsonInput) =>
      _$GrammarsFromJson(jsonInput);
  Map<String, dynamic> toJson() => _$GrammarsToJson(this);
}

///
/// Responsible for looking up grammars for a file.
///
class GrammarManager {
  static final GrammarManager instance = GrammarManager._();
  final Map<String,Grammar> _grammars = {};
  final Logger _logger = createLogger("GrammarManager");
  GrammarManager._();

  Grammar _lookupGrammar(String name) {
    var file = PksConfiguration.singleton.findFile("$name.grammar.json");
    if (file != null) {
      _logger.i("Parsing file $file");
      var s = file.readAsStringSync();
      try {
        for (final grammar in Grammars.fromJson(jsonDecode(s)).grammars) {
          for (final imp in grammar.imports) {
            var nested = _lookupGrammar(imp);
            grammar.mergeWith(nested);
          }
          _grammars[grammar.scopeName] = grammar;
        }
      } catch(ex) {
        _logger.e("invalid syntax in grammar file $file");
      }
    }
    var grammar = _grammars[name];
    if (grammar == null) {
      grammar = Grammar(scopeName: name, patterns: []);
      _grammars[name] = grammar;
    }
    return grammar;
  }

  ///
  /// Lookup a grammar for a file with a given document type.
  ///
  Grammar forDocumentType(DocumentType documentType) {
    var grammar = _grammars[documentType.grammar];
    return grammar ?? _lookupGrammar(documentType.grammar);
  }
}
