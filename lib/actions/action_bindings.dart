//
// action_bindings.dart
//
// PKS-EDIT - Flutter
//
// Last modified: 2024
// Author: Tom Krauß
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter_named/font_awesome_flutter_named.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:material_icons_named/material_icons_named.dart';
import 'package:pks_edit_flutter/actions/actions.dart';
import 'package:pks_edit_flutter/util/logger.dart';

part 'action_bindings.g.dart';

final _logicalKeyMapping = <String, LogicalKeyboardKey>{
  "space": LogicalKeyboardKey.space,
  "enter": LogicalKeyboardKey.enter,
  "return": LogicalKeyboardKey.enter,
  "escape": LogicalKeyboardKey.escape,
  "home": LogicalKeyboardKey.home,
  "tab": LogicalKeyboardKey.tab,
  "end": LogicalKeyboardKey.end,
  "up": LogicalKeyboardKey.arrowUp,
  "subtract": LogicalKeyboardKey.numpadSubtract,
  "numpad0": LogicalKeyboardKey.numpad0,
  "numpad1": LogicalKeyboardKey.numpad1,
  "numpad2": LogicalKeyboardKey.numpad2,
  "numpad3": LogicalKeyboardKey.numpad3,
  "numpad4": LogicalKeyboardKey.numpad4,
  "numpad5": LogicalKeyboardKey.numpad5,
  "numpad6": LogicalKeyboardKey.numpad6,
  "numpad7": LogicalKeyboardKey.numpad7,
  "numpad8": LogicalKeyboardKey.numpad8,
  "numpad9": LogicalKeyboardKey.numpad9,
  "add": LogicalKeyboardKey.numpadAdd,
  "asterisk": LogicalKeyboardKey.asterisk,
  "divide": LogicalKeyboardKey.numpadDivide,
  "multiply": LogicalKeyboardKey.numpadMultiply,
  // Bug on Flutter Desktop: + on German Keyboard mapped to logical key =
  "plus": LogicalKeyboardKey.equal,
  "minus": LogicalKeyboardKey.minus,
  "down": LogicalKeyboardKey.arrowDown,
  "left": LogicalKeyboardKey.arrowLeft,
  "right": LogicalKeyboardKey.arrowRight,
  "delete": LogicalKeyboardKey.delete,
  "back": LogicalKeyboardKey.backspace,
  "help": LogicalKeyboardKey.help,
  "prior": LogicalKeyboardKey.pageUp,
  "next": LogicalKeyboardKey.pageDown,
  "cancel": LogicalKeyboardKey.cancel,
  "insert": LogicalKeyboardKey.insert,
  "period": LogicalKeyboardKey.period,
  "0": LogicalKeyboardKey.digit0,
  "1": LogicalKeyboardKey.digit1,
  "2": LogicalKeyboardKey.digit2,
  "3": LogicalKeyboardKey.digit3,
  "4": LogicalKeyboardKey.digit4,
  "5": LogicalKeyboardKey.digit5,
  "6": LogicalKeyboardKey.digit6,
  "7": LogicalKeyboardKey.digit7,
  "8": LogicalKeyboardKey.digit8,
  "9": LogicalKeyboardKey.digit9,
  "a": LogicalKeyboardKey.keyA,
  "b": LogicalKeyboardKey.keyB,
  "c": LogicalKeyboardKey.keyC,
  "d": LogicalKeyboardKey.keyD,
  "e": LogicalKeyboardKey.keyE,
  "f": LogicalKeyboardKey.keyF,
  "g": LogicalKeyboardKey.keyG,
  "h": LogicalKeyboardKey.keyH,
  "i": LogicalKeyboardKey.keyI,
  "j": LogicalKeyboardKey.keyJ,
  "k": LogicalKeyboardKey.keyK,
  "l": LogicalKeyboardKey.keyL,
  "m": LogicalKeyboardKey.keyM,
  "n": LogicalKeyboardKey.keyN,
  "o": LogicalKeyboardKey.keyO,
  "p": LogicalKeyboardKey.keyP,
  "q": LogicalKeyboardKey.keyQ,
  "r": LogicalKeyboardKey.keyR,
  "s": LogicalKeyboardKey.keyS,
  "t": LogicalKeyboardKey.keyT,
  "u": LogicalKeyboardKey.keyU,
  "v": LogicalKeyboardKey.keyV,
  "w": LogicalKeyboardKey.keyW,
  "x": LogicalKeyboardKey.keyX,
  "y": LogicalKeyboardKey.keyY,
  "z": LogicalKeyboardKey.keyZ,
  "f1": LogicalKeyboardKey.f1,
  "f2": LogicalKeyboardKey.f2,
  "f3": LogicalKeyboardKey.f3,
  "f4": LogicalKeyboardKey.f4,
  "f5": LogicalKeyboardKey.f5,
  "f6": LogicalKeyboardKey.f6,
  "f7": LogicalKeyboardKey.f7,
  "f8": LogicalKeyboardKey.f8,
  "f9": LogicalKeyboardKey.f9,
  "f10": LogicalKeyboardKey.f10,
  "f11": LogicalKeyboardKey.f11,
  "f12": LogicalKeyboardKey.f12,
};

///
/// A general binding in PKS Edit.
class Binding {
  /// The logical context in which this item is active.
  final String? context;

  /// the associated command to execute. If that starts with a @, we are referring to a named action.
  @JsonKey(name: "command")
  final String? commandReference;
  Binding({this.context, this.commandReference});

  @JsonKey(includeFromJson: false, includeToJson: false )
  PksEditAction? action;
}

///
/// Describes a binding which allows to define an icon.
///
class BindingWithIcon extends Binding {
  static final Logger _logger = createLogger("ToolbarItemBinding");
  static const iconNameMappings = <String,String>{
    "floppy": "floppyDisk",
    "cut": "scissors",
    "copy": "clipboard",
    "undo": "arrowRotateLeft",
    "redo": "arrowRotateRight",
    "exchangeAlt": "rightLeft",
    "cog": "gear",
    "search": "magnifyingGlass",
    "searchPlus": "magnifyingGlassPlus",
    "searchMinus": "magnifyingGlassMinus",
    "stopCircle": "circleStop",
    "infoCircle": "circleInfo",
    "solidArrowAltCircleUp": "solidCircleUp"
  };
  /// The name of the icon to display for the toolbar. If no label is specified, a default from the referenced action is used.
  final String? icon;

  IconData? get iconData {
    var name = icon;
    if (name == null) {
      return action?.icon;
    }
    if (name.startsWith("fa-")) {
      name = name.substring(3);
    } else {
      return materialIcons[name.replaceAll('-', '_')];
    }
    var result = StringBuffer();
    var trySolid = true;
    if (name.endsWith("-o")) {
      name = name.substring(0, name.length-2);
      trySolid = false;
    }
    for (int i = 0; i < name.length; i++) {
      var c = name[i];
      if (c == '-' && ++i < name.length) {
        result.write(name[i].toUpperCase());
      } else {
        result.write(c);
      }
    }
    name = result.toString();
    name = iconNameMappings[name] ?? name;
    IconData? data;
    if (trySolid) {
      data = faIconNameMapping["solid${name[0].toUpperCase()}${name.substring(1)}"];
    }
    data ??= faIconNameMapping[name];
    if (data == null) {
      _logger.w("Icon $result not found.");
    }
    return data;
  }

  BindingWithIcon({this.icon, super.context, super.commandReference});

}

///
/// Describes a toolbar button.
///
@JsonSerializable(includeIfNull: false)
class ToolbarItemBinding extends BindingWithIcon {
  /// The help text (tooltip) to display for the button. If no label is specified, a default from the referenced action is used.
  final String? label;

  /// true for separator items. Separator menus do not need a label and no command reference.
  @JsonKey(name: "separator")
  final bool isSeparator;

  ToolbarItemBinding({this.label, this.isSeparator = false, super.icon, super.context, super.commandReference});

  static ToolbarItemBinding fromJson(Map<String, dynamic> map) =>
      _$ToolbarItemBindingFromJson(map);
  Map<String, dynamic> toJson() => _$ToolbarItemBindingToJson(this);
}

///
/// Describes a menu item.
///
@JsonSerializable(includeIfNull: false)
class MenuItemBinding extends BindingWithIcon {
  /// The label to display for the menu. If no label is specified, a default from the referenced action is used.
  final String? label;
  /// Used in the windows version only: the resource id - specified there as a number.
  @JsonKey(name: "label-id")
  final int? labelId;
  /// true for separator menus. Separator menus do not need a label and no command reference.
  @JsonKey(name: "separator")
  final bool isSeparator;
  /// true for "history" menus. Will be replaced during runtime by a list of recently opened files.
  @JsonKey(name: "history-menu")
  final bool isHistoryMenu;
  /// true for "macro" menus. Will be replaced during runtime by a list of global macro function bindings.
  @JsonKey(name: "macro-menu")
  final bool isMacroCommand;
  /// Optional children for nested menus.
  @JsonKey(name: "sub-menu")
  List<MenuItemBinding>? children;
  String get title {
    if (label != null) {
      return label!;
    }
    if (labelId != null) {
      return Intl.message("$labelId", name: "resource$labelId");
    }
    return action?.label ?? "Menu";
  }
  MenuItemBinding({this.isSeparator = false, this.isHistoryMenu = false, this.isMacroCommand = false,
    this.labelId, this.label, this.children,
    super.icon,
    super.context,
    super.commandReference});

  static MenuItemBinding fromJson(Map<String, dynamic> map) =>
      _$MenuItemBindingFromJson(map);
  Map<String, dynamic> toJson() => _$MenuItemBindingToJson(this);
}

///
/// Describes the connection between a key press and an action to execute.
///
@JsonSerializable(includeIfNull: false)
class KeyBinding extends Binding {
  static final Logger _logger = createLogger("KeyBinding");
  static bool convertControl = Platform.isMacOS;
  /// The specification of the key - e.g. 'Ctrl escape'.
  final String key;
  @JsonKey(includeFromJson: false, includeToJson: false )
  late final SingleActivator activator;

  SingleActivator _calculateActivator(String key) {
    var split = key.split("+");
    bool alt = false;
    bool shift = false;
    bool control = false;
    bool meta = false;
    LogicalKeyboardKey? logicalKey;
    for (final segment in split) {
      var s = segment.toLowerCase();
      if (s == 'alt') {
        alt = true;
      } else if (s == 'selected') {
        // special hack to mark an activator only being used on certain conditions - not supported yet.
        continue;
      } else if (s == 'shift') {
        shift = true;
      } else if (s == 'meta') {
        meta = true;
      } else if (s == 'control' || s == 'ctrl') {
        control = true;
      } else {
        if (s.startsWith("\\")) {
          final code = int.tryParse(s.substring(1));
          final key = code == null ? null : PhysicalKeyboardKey.findKeyByCode(code);
          if (key == null) {
            _logger.w("Cannot determine physical key for keycode==$code. Keybinding will not work.");
            continue;
          }
          logicalKey = HardwareKeyboard.instance.lookUpLayout(key);
        } else {
          if (s.startsWith("oem_")) {
            s = s.substring(4);
          }
          final k = _logicalKeyMapping[s];
          if (k == null) {
            _logger.w("Cannot determine logical key for $s");
          } else {
            logicalKey = k;
          }
        }
      }
    }
    return SingleActivator(logicalKey ?? LogicalKeyboardKey.avrInput, alt: alt, shift: shift, meta: meta || (control && convertControl), control: control && !convertControl);
  }

  KeyBinding({required this.key, super.context, super.commandReference}) {
    activator = _calculateActivator(key);
  }

  static KeyBinding fromJson(Map<String, dynamic> map) =>
      _$KeyBindingFromJson(map);
  Map<String, dynamic> toJson() => _$KeyBindingToJson(this);
}

@JsonSerializable(includeIfNull: false)
class MouseBinding extends Binding {
  static MouseBinding fromJson(Map<String, dynamic> map) =>
      _$MouseBindingFromJson(map);
  Map<String, dynamic> toJson() => _$MouseBindingToJson(this);
}

///
/// Defines all action bindings.
///
@JsonSerializable(includeIfNull: false)
class ActionBindings {
  /// Describes the menu bar.
  List<MenuItemBinding> menu;
  /// Describes the context menu.
  @JsonKey(name: "context-menu")
  List<MenuItemBinding> contextMenu;
  /// Describes the mouse button action association.
  @JsonKey(name: "mouse-bindings")
  List<MouseBinding> mouseBindings;
  /// Describes the toolbar buttons.
  List<ToolbarItemBinding> toolbar;
  @JsonKey(name: "key-bindings")
  List<KeyBinding> keys;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final Map<ShortcutActivator,VoidCallback> shortcuts = {};

  void registerAdditionalAction(ShortcutActivator activator, VoidCallback callback) {
    shortcuts[activator] = callback;
  }

  List<T> _processBindings<T extends Binding>(PksEditActions actions, List<T> bindings) {
    final result = <T>[];
    for (final b in bindings) {
      final command = b.commandReference;
      if (b is MenuItemBinding && b.isHistoryMenu) {
        result.add(b);
      } else if (command != null && command.startsWith("@")) {
        var action = actions.actions[command.substring(1)];
        if (action != null) {
          result.add(b);
          action.referenced = true;
          b.action = action;
          if (b is BindingWithIcon && b.icon != null && action.icon == null) {
            action.icon = b.iconData;
          }
          if (b is KeyBinding) {
            action.shortcut = b.activator;
            shortcuts[b.activator] = () {
              var f = action.onPressed;
              if (f != null) {
                f();
              }
            };
          }
        }
      } else if (command == null) {
        result.add(b);
      }
      if (b is MenuItemBinding && b.children != null) {
        b.children = _processBindings(actions, b.children!);
        if (b.children!.isEmpty) {
          result.removeLast();
        }
      }
    }
    return result;
  }

  void processBindingsWith(PksEditActions actions) {
    menu = _processBindings(actions, menu);
    contextMenu = _processBindings(actions, contextMenu);
    toolbar = _processBindings(actions, toolbar);
    mouseBindings = _processBindings(actions, mouseBindings);
    keys = _processBindings(actions, keys);
    // for (var a in actions.actions.values) {
    //  if (!a.referenced) {
    //    print("Command ${a.id} not referenced");
    //  }
    //}
  }

  ActionBindings({this.menu = const [], this.contextMenu = const[], this.toolbar = const[], this.keys = const[], this.mouseBindings = const[]});

  static ActionBindings fromJson(Map<String, dynamic> map) =>
      _$ActionBindingsFromJson(map);
  Map<String, dynamic> toJson() => _$ActionBindingsToJson(this);
}
