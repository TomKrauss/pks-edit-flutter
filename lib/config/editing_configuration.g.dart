// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editing_configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditingConfiguration _$EditingConfigurationFromJson(
        Map<String, dynamic> json) =>
    EditingConfiguration(
      name: json['name'] as String? ?? "default",
      leftMargin: json['leftMargin'] as int? ?? 0,
      rightMargin: json['rightMargin'] as int? ?? 80,
      tabSize: json['tabSize'] as int? ?? 4,
      expandTabsWith: json['expandTabsWith'] as String?,
    );

Map<String, dynamic> _$EditingConfigurationToJson(
    EditingConfiguration instance) {
  final val = <String, dynamic>{
    'name': instance.name,
    'leftMargin': instance.leftMargin,
    'rightMargin': instance.rightMargin,
    'tabSize': instance.tabSize,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('expandTabsWith', instance.expandTabsWith);
  return val;
}

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

Map<String, dynamic> _$DocumentTypeToJson(DocumentType instance) {
  final val = <String, dynamic>{
    'name': instance.name,
    'grammar': instance.grammar,
    'languages': instance.languages,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('description', instance.description);
  val['filenamePatterns'] = instance.filenamePatterns;
  val['editorConfiguration'] = instance.editorConfiguration;
  writeNotNull('firstLineMatch', instance.firstLineMatch);
  return val;
}

EditingConfigurations _$EditingConfigurationsFromJson(
        Map<String, dynamic> json) =>
    EditingConfigurations(
      documentTypes: (json['documentTypes'] as List<dynamic>?)
              ?.map((e) => DocumentType.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      editorConfigurations: (json['editorConfigurations'] as List<dynamic>?)
              ?.map((e) =>
                  EditingConfiguration.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EditingConfigurationsToJson(
        EditingConfigurations instance) =>
    <String, dynamic>{
      'documentTypes': instance.documentTypes,
      'editorConfigurations': instance.editorConfigurations,
    };
