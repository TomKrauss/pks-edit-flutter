// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pks_ini.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompilerOutputPattern _$CompilerOutputPatternFromJson(
        Map<String, dynamic> json) =>
    CompilerOutputPattern(
      name: json['name'] as String,
      pattern: json['pattern'] as String,
      filenameCapture: (json['filename-capture'] as num?)?.toInt() ?? 1,
      lineNumberCapture: (json['linenumber-capture'] as num?)?.toInt() ?? 2,
      commentCapture: (json['comment-capture'] as num?)?.toInt() ?? 3,
    );

Map<String, dynamic> _$CompilerOutputPatternToJson(
        CompilerOutputPattern instance) =>
    <String, dynamic>{
      'name': instance.name,
      'pattern': instance.pattern,
      'filename-capture': instance.filenameCapture,
      'linenumber-capture': instance.lineNumberCapture,
      'comment-capture': instance.commentCapture,
    };

ApplicationConfiguration _$ApplicationConfigurationFromJson(
        Map<String, dynamic> json) =>
    ApplicationConfiguration(
      compactEditorTabs: json['compact-editor-tabs'] as bool? ?? true,
      showErrorsInToast: json['show-error-toast'] as bool? ?? true,
      playSoundOnError: json['sound-on-error'] as bool? ?? false,
      silentlyReloadChangedFiles:
          json['silently-reload-changed-files'] as bool? ?? true,
      soundName: json['sound-name'] as String? ?? "default",
      compilerOutputPatterns:
          (json['compiler-output-patterns'] as List<dynamic>?)
                  ?.map((e) =>
                      CompilerOutputPattern.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              const [],
      formsFollowMouse: json['forms-follow-mouse'] as bool? ?? false,
      maintainClipboardHistory:
          json['maintain-clipboard-history'] as bool? ?? false,
      hideSelectionOnMove: json['hide-selection-on-move'] as bool? ?? true,
      theme: json['theme'] as String? ?? "dark",
      cleanupAutosaveFiles: json['cleanup-autosave-files'] as bool? ?? true,
      undoHistory: (json['undo-history'] as num?)?.toInt() ?? 100,
      includePath: json['include-path'] as String? ?? "includes;inc",
      language: json['language'] as String? ?? "English",
      maximumOpenWindows: (json['maximum-open-windows'] as num?)?.toInt() ?? -1,
      iconSize: $enumDecodeNullable(_$IconSizeEnumMap, json['icon-size']) ??
          IconSize.small,
      autosaveTimeSeconds: (json['autosave-time'] as num?)?.toInt(),
      undoEnabled: json['undo-enabled'] as bool? ?? true,
      showStatusbar: json['show-statusbar'] as bool? ?? true,
      showToolbar: json['show-toolbar'] as bool? ?? true,
      showFunctionKeys: json['show-functionkeys'] as bool? ?? true,
      showOptionBar: json['show-optionbar'] as bool? ?? true,
      autoSaveOnExit: json['autosave-on-exit'] as bool? ?? false,
      autoSaveToTemp: json['autosave-to-temp'] as bool? ?? true,
      preserveHistory: json['preserve-history'] as bool? ?? true,
      createBackInTempPath: json['create-back-in-temp-path'] as bool? ?? true,
      lockFilesForEdit: json['lock-files-for-edit'] as bool? ?? false,
      reuseApplicationRunningInstance:
          json['reuse-application-running-instance'] as bool? ?? true,
      defaultFont: json['default-font'] as String?,
      searchEngine: json['search-engine'] as String? ?? "Google",
    )..prunedSearchDirectories = json['pruned-search-directories'] as String;

Map<String, dynamic> _$ApplicationConfigurationToJson(
        ApplicationConfiguration instance) =>
    <String, dynamic>{
      'theme': instance.theme,
      'language': instance.language,
      'pruned-search-directories': instance.prunedSearchDirectories,
      'default-font': instance.defaultFont,
      'icon-size': _$IconSizeEnumMap[instance.iconSize]!,
      'show-statusbar': instance.showStatusbar,
      'show-functionkeys': instance.showFunctionKeys,
      'show-optionbar': instance.showOptionBar,
      'show-toolbar': instance.showToolbar,
      'compact-editor-tabs': instance.compactEditorTabs,
      'forms-follow-mouse': instance.formsFollowMouse,
      'show-error-toast': instance.showErrorsInToast,
      'sound-name': instance.soundName,
      'sound-on-error': instance.playSoundOnError,
      'maximum-open-windows': instance.maximumOpenWindows,
      'preserve-history': instance.preserveHistory,
      'reuse-application-running-instance':
          instance.reuseApplicationRunningInstance,
      'maintain-clipboard-history': instance.maintainClipboardHistory,
      'autosave-to-temp': instance.autoSaveToTemp,
      'autosave-on-exit': instance.autoSaveOnExit,
      'create-back-in-temp-path': instance.createBackInTempPath,
      'lock-files-for-edit': instance.lockFilesForEdit,
      'hide-selection-on-move': instance.hideSelectionOnMove,
      if (instance.autosaveTimeSeconds case final value?)
        'autosave-time': value,
      'undo-enabled': instance.undoEnabled,
      'undo-history': instance.undoHistory,
      'cleanup-autosave-files': instance.cleanupAutosaveFiles,
      'silently-reload-changed-files': instance.silentlyReloadChangedFiles,
      'search-engine': instance.searchEngine,
      'include-path': instance.includePath,
      'compiler-output-patterns': instance.compilerOutputPatterns,
    };

const _$IconSizeEnumMap = {
  IconSize.small: 'small',
  IconSize.medium: 'medium',
  IconSize.big: 'big',
  IconSize.large: 'large',
};

PksIniConfiguration _$PksIniConfigurationFromJson(Map<String, dynamic> json) =>
    PksIniConfiguration(
      configuration: ApplicationConfiguration.fromJson(
          json['configuration'] as Map<String, dynamic>),
      printConfiguration:
          json['print-configuration'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$PksIniConfigurationToJson(
        PksIniConfiguration instance) =>
    <String, dynamic>{
      'configuration': instance.configuration,
      'print-configuration': instance.printConfiguration,
    };
