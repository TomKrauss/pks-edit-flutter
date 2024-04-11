// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pks_ini.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplicationConfiguration _$EditorConfigurationFromJson(Map<String, dynamic> json) =>
    ApplicationConfiguration(
      theme: json['theme'] as String? ?? "dark",
      includePath: json['include-path'] as String? ?? "includes;inc",
      language: json['language'] as String? ?? "English",
      maximumOpenWindows: json['maximum-open-windows'] as int? ?? -1,
      showStatusbar: json['show-statusbar'] as bool? ?? true,
      showToolbar: json['show-toolbar'] as bool? ?? true,
      showFunctionKeys: json['show-functionkeys'] as bool? ?? true,
      showOptionBar: json['show-optionbar'] as bool? ?? true,
      autoSaveOnExit: json['autosave-on-exit'] as bool? ?? false,
      autoSaveToTemp: json['autosave-to-temp'] as bool? ?? false,
      preserveHistory: json['preserve-history'] as bool? ?? true,
      createBackInTempPath: json['create-back-in-temp-path'] as bool? ?? true,
      lockFilesForEdit: json['lock-files-for-edit'] as bool? ?? false,
      reuseApplicationRunningInstance:
          json['reuse-application-running-instance'] as bool? ?? true,
      defaultFont: json['default-font'] as String?,
      searchEngine: json['search-engine'] as String? ?? "Google",
    );

Map<String, dynamic> _$EditorConfigurationToJson(
        ApplicationConfiguration instance) =>
    <String, dynamic>{
      'theme': instance.theme,
      'include-path': instance.includePath,
      'language': instance.language,
      'default-font': instance.defaultFont,
      'search-engine': instance.searchEngine,
      'maximum-open-windows': instance.maximumOpenWindows,
      'show-statusbar': instance.showStatusbar,
      'show-functionkeys': instance.showFunctionKeys,
      'show-optionbar': instance.showOptionBar,
      'show-toolbar': instance.showToolbar,
      'autosave-to-temp': instance.autoSaveToTemp,
      'autosave-on-exit': instance.autoSaveOnExit,
      'preserve-history': instance.preserveHistory,
      'create-back-in-temp-path': instance.createBackInTempPath,
      'lock-files-for-edit': instance.lockFilesForEdit,
      'reuse-application-running-instance':
          instance.reuseApplicationRunningInstance,
    };
