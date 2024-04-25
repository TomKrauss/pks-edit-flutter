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

Map<String, dynamic> _$ToolbarItemBindingToJson(ToolbarItemBinding instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('context', instance.context);
  writeNotNull('command', instance.commandReference);
  writeNotNull('icon', instance.icon);
  writeNotNull('label', instance.label);
  val['separator'] = instance.isSeparator;
  return val;
}

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

Map<String, dynamic> _$MenuItemBindingToJson(MenuItemBinding instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('context', instance.context);
  writeNotNull('command', instance.commandReference);
  writeNotNull('icon', instance.icon);
  writeNotNull('label', instance.label);
  writeNotNull('label-id', instance.labelId);
  val['separator'] = instance.isSeparator;
  val['history-menu'] = instance.isHistoryMenu;
  val['macro-menu'] = instance.isMacroCommand;
  writeNotNull('sub-menu', instance.children);
  return val;
}

KeyBinding _$KeyBindingFromJson(Map<String, dynamic> json) => KeyBinding(
      key: json['key'] as String,
      context: json['context'] as String?,
      commandReference: json['command'] as String?,
    );

Map<String, dynamic> _$KeyBindingToJson(KeyBinding instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('context', instance.context);
  writeNotNull('command', instance.commandReference);
  val['key'] = instance.key;
  return val;
}

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
