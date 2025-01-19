// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pks_sys.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MainWindowPlacement _$MainWindowPlacementFromJson(Map<String, dynamic> json) =>
    MainWindowPlacement(
      flags: (json['flags'] as num?)?.toInt() ?? 0,
      show: (json['show'] as num?)?.toInt() ?? 1,
      top: (json['top'] as num?)?.toInt() ?? 0,
      left: (json['left'] as num?)?.toInt() ?? 0,
      right: (json['right'] as num?)?.toInt() ?? 1000,
      bottom: (json['bottom'] as num?)?.toInt() ?? 1000,
    );

Map<String, dynamic> _$MainWindowPlacementToJson(
        MainWindowPlacement instance) =>
    <String, dynamic>{
      'flags': instance.flags,
      'show': instance.show,
      'top': instance.top,
      'bottom': instance.bottom,
      'left': instance.left,
      'right': instance.right,
    };

MainFrameDock _$MainFrameDockFromJson(Map<String, dynamic> json) =>
    MainFrameDock(
      name: json['name'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      w: (json['w'] as num).toDouble(),
      h: (json['h'] as num).toDouble(),
    );

Map<String, dynamic> _$MainFrameDockToJson(MainFrameDock instance) =>
    <String, dynamic>{
      'name': instance.name,
      'x': instance.x,
      'y': instance.y,
      'w': instance.w,
      'h': instance.h,
    };

PksEditSession _$PksEditSessionFromJson(Map<String, dynamic> json) =>
    PksEditSession(
      screenWidth: (json['screen-width'] as num?)?.toInt(),
      screenHeight: (json['screen-height'] as num?)?.toInt(),
      searchReplaceOptions: (json['search-replace-options'] as num).toInt(),
      mainWindowPlacement: MainWindowPlacement.fromJson(
          json['main-window-placement'] as Map<String, dynamic>),
      dock1:
          PksEditSession._dockFromJson(json['dock1'] as Map<String, dynamic>?),
      dock2:
          PksEditSession._dockFromJson(json['dock2'] as Map<String, dynamic>?),
      dock3:
          PksEditSession._dockFromJson(json['dock3'] as Map<String, dynamic>?),
      openFiles: (json['open-files'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      filePatterns: (json['file-patterns'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      searchPatterns: (json['search-patterns'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      replacePatterns: (json['replace-patterns'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      folders:
          (json['folders'] as List<dynamic>?)?.map((e) => e as String).toList(),
      openEditors: json['open-editors'] == null
          ? const []
          : PksEditSession._panelsFromString(json['open-editors'] as List),
    );

Map<String, dynamic> _$PksEditSessionToJson(PksEditSession instance) =>
    <String, dynamic>{
      if (instance.screenWidth case final value?) 'screen-width': value,
      if (instance.screenHeight case final value?) 'screen-height': value,
      'search-replace-options': instance.searchReplaceOptions,
      'open-files': instance.openFiles,
      'folders': instance.folders,
      'search-patterns': instance.searchPatterns,
      'replace-patterns': instance.replacePatterns,
      'file-patterns': instance.filePatterns,
      'open-editors': PksEditSession._panelsToString(instance.openEditors),
      'main-window-placement': instance.mainWindowPlacement.toJson(),
      if (instance.dock1?.toJson() case final value?) 'dock1': value,
      if (instance.dock2?.toJson() case final value?) 'dock2': value,
      if (instance.dock3?.toJson() case final value?) 'dock3': value,
    };
