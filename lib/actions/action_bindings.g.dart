// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_bindings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ToolbarItemBinding _$ToolbarItemBindingFromJson(Map<String, dynamic> json) =>
    ToolbarItemBinding(
      label: json['label'] as String?,
      isSeparator: json['separator'] as bool? ?? false,
      icon: json['icon'] as String?,
      context: json['context'] as String?,
      commandReference: json['command'] as String?,
    );

Map<String, dynamic> _$ToolbarItemBindingToJson(ToolbarItemBinding instance) =>
    <String, dynamic>{
      if (instance.context case final value?) 'context': value,
      if (instance.commandReference case final value?) 'command': value,
      if (instance.icon case final value?) 'icon': value,
      if (instance.label case final value?) 'label': value,
      'separator': instance.isSeparator,
    };

MenuItemBinding _$MenuItemBindingFromJson(Map<String, dynamic> json) =>
    MenuItemBinding(
      isSeparator: json['separator'] as bool? ?? false,
      isHistoryMenu: json['history-menu'] as bool? ?? false,
      isMacroCommand: json['macro-menu'] as bool? ?? false,
      labelId: (json['label-id'] as num?)?.toInt(),
      label: json['label'] as String?,
      children: (json['sub-menu'] as List<dynamic>?)
          ?.map((e) => MenuItemBinding.fromJson(e as Map<String, dynamic>))
          .toList(),
      icon: json['icon'] as String?,
      context: json['context'] as String?,
      commandReference: json['command'] as String?,
    );

Map<String, dynamic> _$MenuItemBindingToJson(MenuItemBinding instance) =>
    <String, dynamic>{
      if (instance.context case final value?) 'context': value,
      if (instance.commandReference case final value?) 'command': value,
      if (instance.icon case final value?) 'icon': value,
      if (instance.label case final value?) 'label': value,
      if (instance.labelId case final value?) 'label-id': value,
      'separator': instance.isSeparator,
      'history-menu': instance.isHistoryMenu,
      'macro-menu': instance.isMacroCommand,
      if (instance.children case final value?) 'sub-menu': value,
    };

KeyBinding _$KeyBindingFromJson(Map<String, dynamic> json) => KeyBinding(
      key: json['key'] as String,
      context: json['context'] as String?,
      commandReference: json['command'] as String?,
    );

Map<String, dynamic> _$KeyBindingToJson(KeyBinding instance) =>
    <String, dynamic>{
      if (instance.context case final value?) 'context': value,
      if (instance.commandReference case final value?) 'command': value,
      'key': instance.key,
    };

MouseBinding _$MouseBindingFromJson(Map<String, dynamic> json) =>
    MouseBinding();

Map<String, dynamic> _$MouseBindingToJson(MouseBinding instance) =>
    <String, dynamic>{};

ActionBindings _$ActionBindingsFromJson(Map<String, dynamic> json) =>
    ActionBindings(
      menu: (json['menu'] as List<dynamic>?)
              ?.map((e) => MenuItemBinding.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      contextMenu: (json['context-menu'] as List<dynamic>?)
              ?.map((e) => MenuItemBinding.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      toolbar: (json['toolbar'] as List<dynamic>?)
              ?.map(
                  (e) => ToolbarItemBinding.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      keys: (json['key-bindings'] as List<dynamic>?)
              ?.map((e) => KeyBinding.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      mouseBindings: (json['mouse-bindings'] as List<dynamic>?)
              ?.map((e) => MouseBinding.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ActionBindingsToJson(ActionBindings instance) =>
    <String, dynamic>{
      'menu': instance.menu,
      'context-menu': instance.contextMenu,
      'mouse-bindings': instance.mouseBindings,
      'toolbar': instance.toolbar,
      'key-bindings': instance.keys,
    };
