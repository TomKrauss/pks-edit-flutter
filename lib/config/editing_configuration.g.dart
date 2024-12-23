// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editing_configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditingConfiguration _$EditingConfigurationFromJson(
        Map<String, dynamic> json) =>
    EditingConfiguration(
      name: json['name'] as String? ?? "default",
      leftMargin: (json['leftMargin'] as num?)?.toInt() ?? 0,
      rightMargin: (json['rightMargin'] as num?)?.toInt() ?? 80,
      tabSize: (json['tabSize'] as num?)?.toInt() ?? 4,
      hexMode: json['hexMode'] as bool? ?? false,
      showWysiwyg: json['showWysiwyg'] as bool? ?? false,
      expandTabsWith: json['expandTabsWith'] as String?,
      showLineNumbers: json['showLineNumbers'] as bool? ?? true,
      showSyntaxHighlight: json['showSyntaxHighlight'] as bool? ?? true,
      backupExtension: json['backupExtension'] as String? ?? "bak",
      wordTokenExpression: json['wordTokenExpression'] as String? ??
          '[a-zA-ZöäüÖÄÜß][a-zA-Z0-9_öäüÖÄÜß]*',
    );

Map<String, dynamic> _$EditingConfigurationToJson(
        EditingConfiguration instance) =>
    <String, dynamic>{
      'name': instance.name,
      'leftMargin': instance.leftMargin,
      'rightMargin': instance.rightMargin,
      'tabSize': instance.tabSize,
      if (instance.expandTabsWith case final value?) 'expandTabsWith': value,
      'wordTokenExpression': instance.wordTokenExpression,
      'backupExtension': instance.backupExtension,
      'showLineNumbers': instance.showLineNumbers,
      'showSyntaxHighlight': instance.showSyntaxHighlight,
      'hexMode': instance.hexMode,
      'showWysiwyg': instance.showWysiwyg,
    };

DocumentType _$DocumentTypeFromJson(Map<String, dynamic> json) => DocumentType(
      name: json['name'] as String,
      grammar: json['grammar'] as String? ?? "default",
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      description: json['description'] as String?,
      editorConfiguration: json['editorConfiguration'] as String? ?? "default",
      filenamePatterns: json['filenamePatterns'] as String,
      firstLineMatch: json['firstLineMatch'] as String?,
    );

Map<String, dynamic> _$DocumentTypeToJson(DocumentType instance) =>
    <String, dynamic>{
      'name': instance.name,
      'grammar': instance.grammar,
      'languages': instance.languages,
      if (instance.description case final value?) 'description': value,
      'filenamePatterns': instance.filenamePatterns,
      'editorConfiguration': instance.editorConfiguration,
      if (instance.firstLineMatch case final value?) 'firstLineMatch': value,
    };

EditingConfigurations _$EditingConfigurationsFromJson(
        Map<String, dynamic> json) =>
    EditingConfigurations(
      documentTypes: (json['documentTypes'] as List<dynamic>?)
              ?.map((e) => DocumentType.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [DocumentType.defaultConfiguration],
      editorConfigurations: (json['editorConfigurations'] as List<dynamic>?)
              ?.map((e) =>
                  EditingConfiguration.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [EditingConfiguration.defaultConfiguration],
    );

Map<String, dynamic> _$EditingConfigurationsToJson(
        EditingConfigurations instance) =>
    <String, dynamic>{
      'documentTypes': instance.documentTypes,
      'editorConfigurations': instance.editorConfigurations,
    };
