// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_bindings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ToolbarItemBinding _$ToolbarItemBindingFromJson(Map<String, dynamic> json) =>
    ToolbarItemBinding(
      context: json['context'] as String?,
      label: json['label'] as String?,
      isSeparator: json['separator'] as bool? ?? false,
      commandReference: json['command'] as String?,
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$ToolbarItemBindingToJson(ToolbarItemBinding instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('context', instance.context);
  writeNotNull('label', instance.label);
  writeNotNull('icon', instance.icon);
  val['separator'] = instance.isSeparator;
  writeNotNull('command', instance.commandReference);
  return val;
}

MenuItemBinding _$MenuItemBindingFromJson(Map<String, dynamic> json) =>
    MenuItemBinding(
      isSeparator: json['separator'] as bool? ?? false,
      isHistoryMenu: json['history-menu'] as bool? ?? false,
      isMacroCommand: json['macro-menu'] as bool? ?? false,
      context: json['context'] as String?,
      labelId: json['label-id'] as int?,
      label: json['label'] as String?,
      children: (json['sub-menu'] as List<dynamic>?)
          ?.map((e) => MenuItemBinding.fromJson(e as Map<String, dynamic>))
          .toList(),
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
  writeNotNull('label', instance.label);
  writeNotNull('label-id', instance.labelId);
  val['separator'] = instance.isSeparator;
  val['history-menu'] = instance.isHistoryMenu;
  val['macro-menu'] = instance.isMacroCommand;
  writeNotNull('command', instance.commandReference);
  writeNotNull('sub-menu', instance.children);
  return val;
}

KeyBinding _$KeyBindingFromJson(Map<String, dynamic> json) => KeyBinding(
      context: json['context'] as String?,
      key: json['key'] as String,
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
  val['key'] = instance.key;
  writeNotNull('command', instance.commandReference);
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
