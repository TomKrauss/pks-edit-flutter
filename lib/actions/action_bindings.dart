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
import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';

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
  "plus": LogicalKeyboardKey.add,
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
/// Describes a toolbar button.
///
@JsonSerializable(includeIfNull: false)
class ToolbarItemBinding {
  /// The logical context in which this item is active.
  final String? context;
  /// The help text (tooltip) to display for the button. If no label is specified, a default from the referenced action is used.
  final String? label;
  /// The name of the icon to display for the toolbar. If no label is specified, a default from the referenced action is used.
  final String? icon;
  /// true for separator items. Separator menus do not need a label and no command reference.
  @JsonKey(name: "separator")
  final bool isSeparator;
  /// the associated command to execute. If that starts with a @, we are referring to a named action.
  @JsonKey(name: "command")
  final String? commandReference;

  ToolbarItemBinding({this.context, this.label, this.isSeparator = false, this.commandReference, this.icon});

  static ToolbarItemBinding fromJson(Map<String, dynamic> map) =>
      _$ToolbarItemBindingFromJson(map);
  Map<String, dynamic> toJson() => _$ToolbarItemBindingToJson(this);
}

///
/// Describes a menu item.
///
@JsonSerializable(includeIfNull: false)
class MenuItemBinding {
  /// The logical context in which this item is active.
  final String? context;
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
  /// the associated command to execute. If that starts with a @, we are referring to a named action.
  @JsonKey(name: "command")
  final String? commandReference;
  /// Optional children for nested menus.
  @JsonKey(name: "sub-menu")
  final List<MenuItemBinding>? children;
  MenuItemBinding({this.isSeparator = false, this.isHistoryMenu = false, this.isMacroCommand = false,
    this.context,
    this.labelId, this.label, this.children, this.commandReference});

  static MenuItemBinding fromJson(Map<String, dynamic> map) =>
      _$MenuItemBindingFromJson(map);
  Map<String, dynamic> toJson() => _$MenuItemBindingToJson(this);
}

///
/// Describes the connection between a key press and an action to execute.
///
@JsonSerializable(includeIfNull: false)
class KeyBinding {
  static final Logger _logger = Logger();
  static bool convertControl = Platform.isMacOS;
  /// The logical context in which this item is active.
  final String? context;
  /// The specification of the key - e.g. 'Ctrl escape'.
  final String key;
  late final SingleActivator activator;

  SingleActivator _calculateActivator(String key) {
    var split = key.split(r"+");
    bool alt = false;
    bool shift = false;
    bool control = false;
    bool meta = false;
    var logicalKey = LogicalKeyboardKey.add;
    for (var segment in split) {
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
        if (s.startsWith("oem_")) {
          s = s.substring(4);
        }
        final k = _logicalKeyMapping[s];
        if (k == null) {
          _logger.i("Cannot determine logical key for $s");
        }
        logicalKey = k ?? LogicalKeyboardKey.add;
      }
    }
    return SingleActivator(logicalKey, alt: alt, shift: shift, meta: meta || (control && convertControl), control: control && !convertControl);
  }

  /// the associated command to execute. If that starts with a @, we are referring to a named action.
  @JsonKey(name: "command")
  final String? commandReference;
  KeyBinding({this.context, required this.key, this.commandReference}) {
    activator = _calculateActivator(key);
  }

  static KeyBinding fromJson(Map<String, dynamic> map) =>
      _$KeyBindingFromJson(map);
  Map<String, dynamic> toJson() => _$KeyBindingToJson(this);
}

@JsonSerializable(includeIfNull: false)
class MouseBinding {
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
  final List<MenuItemBinding> menu;
  /// Describes the context menu.
  @JsonKey(name: "context-menu")
  final List<MenuItemBinding> contextMenu;
  /// Describes the mouse button action association.
  @JsonKey(name: "mouse-bindings")
  final List<MouseBinding> mouseBindings;
  /// Describes the toolbar buttons.
  final List<ToolbarItemBinding> toolbar;
  @JsonKey(name: "key-bindings")
  final List<KeyBinding> keys;

  ActionBindings({this.menu = const [], this.contextMenu = const[], this.toolbar = const[], this.keys = const[], this.mouseBindings = const[]});
  static ActionBindings fromJson(Map<String, dynamic> map) =>
      _$ActionBindingsFromJson(map);
  Map<String, dynamic> toJson() => _$ActionBindingsToJson(this);
}
