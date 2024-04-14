// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(file) =>
      "File ${file} is changed. Do you want to reload it?";

  static String m1(shortcut) => "Search incrementally (${shortcut})";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("About..."),
        "aboutInfoText": MessageLookupByLibrary.simpleMessage(
            "Flutter version of the famous Atari Code Editor"),
        "anErrorOccurred": MessageLookupByLibrary.simpleMessage(
            "An error occurred executing the command"),
        "apply": MessageLookupByLibrary.simpleMessage("Apply"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "compactEditorTabs":
            MessageLookupByLibrary.simpleMessage("Compact Editor Tabs"),
        "confirmation": MessageLookupByLibrary.simpleMessage("Confirmation"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "file": MessageLookupByLibrary.simpleMessage("File"),
        "find": MessageLookupByLibrary.simpleMessage("Find"),
        "functions": MessageLookupByLibrary.simpleMessage("Functions"),
        "iconSize": MessageLookupByLibrary.simpleMessage("Icon Size"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "maximumNumberOfWindows":
            MessageLookupByLibrary.simpleMessage("Maximum Number of Windows"),
        "no": MessageLookupByLibrary.simpleMessage("No"),
        "reloadChangedFile": m0,
        "searchIncrementally": m1,
        "showStatusbar": MessageLookupByLibrary.simpleMessage("Show Statusbar"),
        "showToolbar": MessageLookupByLibrary.simpleMessage("Show Toolbar"),
        "window": MessageLookupByLibrary.simpleMessage("Window"),
        "yes": MessageLookupByLibrary.simpleMessage("Yes")
      };
}
