// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThemeConfiguration _$ThemeConfigurationFromJson(Map<String, dynamic> json) =>
    ThemeConfiguration(
      name: json['name'] as String? ?? "default",
      backgroundColor: json['backgroundColor'] == null
          ? Colors.black
          : ThemeConfiguration._parseColor(json['backgroundColor'] as String),
      darkMode: (json['darkMode'] as num?)?.toInt(),
      dialogLightBackground: json['dialogLightBackground'] == null
          ? Colors.black26
          : ThemeConfiguration._parseColor(
              json['dialogLightBackground'] as String),
      optDialogBackground: ThemeConfiguration._parseOptColor(
          json['dialogBackground'] as String?),
      dialogLight: json['dialogLight'] == null
          ? Colors.white38
          : ThemeConfiguration._parseColor(json['dialogLight'] as String),
      dialogBorder: json['dialogBorder'] == null
          ? Colors.black12
          : ThemeConfiguration._parseColor(json['dialogBorder'] as String),
      changedLineColor: json['changedLineColor'] == null
          ? Colors.white30
          : ThemeConfiguration._parseColor(json['changedLineColor'] as String),
      iconColor: json['iconColor'] == null
          ? Colors.blueAccent
          : ThemeConfiguration._parseColor(json['iconColor'] as String),
    );

Map<String, dynamic> _$ThemeConfigurationToJson(ThemeConfiguration instance) =>
    <String, dynamic>{
      'name': instance.name,
      if (instance.darkMode case final value?) 'darkMode': value,
      'backgroundColor':
          ThemeConfiguration._printColor(instance.backgroundColor),
      'iconColor': ThemeConfiguration._printColor(instance.iconColor),
      'changedLineColor':
          ThemeConfiguration._printColor(instance.changedLineColor),
      'dialogLightBackground':
          ThemeConfiguration._printColor(instance.dialogLightBackground),
      if (ThemeConfiguration._printOptColor(instance.optDialogBackground)
          case final value?)
        'dialogBackground': value,
      'dialogLight': ThemeConfiguration._printColor(instance.dialogLight),
      'dialogBorder': ThemeConfiguration._printColor(instance.dialogBorder),
    };

Themes _$ThemesFromJson(Map<String, dynamic> json) => Themes(
      themes: (json['themes'] as List<dynamic>)
          .map((e) => ThemeConfiguration.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ThemesToJson(Themes instance) => <String, dynamic>{
      'themes': instance.themes,
    };
