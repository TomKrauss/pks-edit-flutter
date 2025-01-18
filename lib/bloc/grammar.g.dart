// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grammar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Template _$TemplateFromJson(Map<String, dynamic> json) => Template(
      name: json['name'] as String?,
      match: json['match'] as String?,
      contents: json['contents'] as String,
      auto: json['auto-insert'] as bool? ?? false,
    );

Map<String, dynamic> _$TemplateToJson(Template instance) => <String, dynamic>{
      'name': instance.name,
      'match': instance.match,
      'contents': instance.contents,
      'auto-insert': instance.auto,
    };

GrammarPattern _$GrammarPatternFromJson(Map<String, dynamic> json) =>
    GrammarPattern(
      name: json['name'] as String,
      begin: json['begin'] as String?,
      end: json['end'] as String?,
      match: json['match'] as String?,
      ignoreCase: json['ignoreCase'] as bool?,
      keywordsNoIdentifiers: json['keywordsNoIdentifiers'] as bool?,
      keywords: (json['keywords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$GrammarPatternToJson(GrammarPattern instance) =>
    <String, dynamic>{
      'name': instance.name,
      'begin': instance.begin,
      'end': instance.end,
      'match': instance.match,
      'keywordsNoIdentifiers': instance.keywordsNoIdentifiers,
      'keywords': instance.keywords,
      'ignoreCase': instance.ignoreCase,
    };

Grammar _$GrammarFromJson(Map<String, dynamic> json) => Grammar(
      scopeName: json['scopeName'] as String,
      description: json['description'] as String?,
      patterns: (json['patterns'] as List<dynamic>?)
          ?.map((e) => GrammarPattern.fromJson(e as Map<String, dynamic>))
          .toList(),
      imports: (json['import'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      templates: (json['templates'] as List<dynamic>?)
          ?.map((e) => Template.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GrammarToJson(Grammar instance) => <String, dynamic>{
      'scopeName': instance.scopeName,
      'import': instance.imports,
      'description': instance.description,
      'templates': instance.templates,
      'patterns': instance.patterns,
    };

Grammars _$GrammarsFromJson(Map<String, dynamic> json) => Grammars(
      grammars: (json['grammars'] as List<dynamic>)
          .map((e) => Grammar.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GrammarsToJson(Grammars instance) => <String, dynamic>{
      'grammars': instance.grammars,
    };
