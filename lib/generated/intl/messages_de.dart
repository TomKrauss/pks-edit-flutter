// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
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
  String get localeName => 'de';

  static String m0(file) =>
      "Datei ${file} ist geändert. Soll sie neu geladen und die Änderungen überschrieben werden?";

  static String m1(shortcut) => "Inkrementell suchen (${shortcut})";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("Über..."),
        "aboutInfoText": MessageLookupByLibrary.simpleMessage(
            "Flutter Version des beliebten Atari Code Editors"),
        "anErrorOccurred": MessageLookupByLibrary.simpleMessage(
            "Ein Fehler ist beim Ausführen des Kommandos aufgetreten"),
        "apply": MessageLookupByLibrary.simpleMessage("Anwenden"),
        "cancel": MessageLookupByLibrary.simpleMessage("Abbruch"),
        "compactEditorTabs":
            MessageLookupByLibrary.simpleMessage("Editor Reiter kompakt"),
        "confirmation": MessageLookupByLibrary.simpleMessage("Bestätigung"),
        "edit": MessageLookupByLibrary.simpleMessage("Bearbeiten"),
        "file": MessageLookupByLibrary.simpleMessage("Datei"),
        "find": MessageLookupByLibrary.simpleMessage("Suchen"),
        "functions": MessageLookupByLibrary.simpleMessage("Funktionen"),
        "iconSize": MessageLookupByLibrary.simpleMessage("Icongröße"),
        "language": MessageLookupByLibrary.simpleMessage("Sprache"),
        "maximumNumberOfWindows":
            MessageLookupByLibrary.simpleMessage("Maximale Anzahl Fenster"),
        "no": MessageLookupByLibrary.simpleMessage("Nein"),
        "reloadChangedFile": m0,
        "searchIncrementally": m1,
        "showStatusbar":
            MessageLookupByLibrary.simpleMessage("Statuszeile anzeigen"),
        "showToolbar": MessageLookupByLibrary.simpleMessage("Toolbar anzeigen"),
        "window": MessageLookupByLibrary.simpleMessage("Fenster"),
        "yes": MessageLookupByLibrary.simpleMessage("Ja")
      };
}
