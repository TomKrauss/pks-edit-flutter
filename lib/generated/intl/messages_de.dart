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

  static String m0(length) =>
      "${length} Zeichen auf die Zwischenablage kopiert.";

  static String m1(lineCount) =>
      "Zeilennummer muss im Bereich 1 - ${lineCount} liegen.";

  static String m2(file) =>
      "Datei ${file} ist geändert. Soll sie neu geladen und die Änderungen überschrieben werden?";

  static String m3(shortcut) => "Inkrementell suchen (${shortcut})";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "aboutInfoText": MessageLookupByLibrary.simpleMessage(
            "Flutter Version des beliebten Atari Code Editors"),
        "actionCharToLower": MessageLookupByLibrary.simpleMessage(
            "In Kleinschreibung konvertieren"),
        "actionCharToUpper": MessageLookupByLibrary.simpleMessage(
            "In Großschreibung konvertieren"),
        "actionCharToggleUpperLower": MessageLookupByLibrary.simpleMessage(
            "Groß-/Kleinschreibung invertieren"),
        "actionCloseAllButCurrentWindow":
            MessageLookupByLibrary.simpleMessage("Andere Fenster schließen"),
        "actionCloseAllWindows":
            MessageLookupByLibrary.simpleMessage("Alle Fenster schließen"),
        "actionCloseWindow":
            MessageLookupByLibrary.simpleMessage("Fenster schließen"),
        "actionCopy": MessageLookupByLibrary.simpleMessage("Kopieren"),
        "actionCursorWordLeft":
            MessageLookupByLibrary.simpleMessage("Cursor Wort nach links"),
        "actionCursorWordRight":
            MessageLookupByLibrary.simpleMessage("Cursor Wort nach rechts"),
        "actionCut": MessageLookupByLibrary.simpleMessage("Ausschneiden"),
        "actionCycleWindow":
            MessageLookupByLibrary.simpleMessage("Nächstes Fester auswählen"),
        "actionDescriptionCloseAllButCurrentWindow":
            MessageLookupByLibrary.simpleMessage(
                "Schließt alle Fenster außer dem aktuellen"),
        "actionDescriptionCloseAllWindows":
            MessageLookupByLibrary.simpleMessage(
                "Schließt alle Bearbeitungsfenster"),
        "actionDescriptionCloseWindow": MessageLookupByLibrary.simpleMessage(
            "Schließt das aktuelle Bearbeitungsfenster"),
        "actionDescriptionDiscardChangesInFile":
            MessageLookupByLibrary.simpleMessage(
                "Alle Änderungen ignorieren und Datei neu laden"),
        "actionDescriptionExit":
            MessageLookupByLibrary.simpleMessage("PKS Edit beenden"),
        "actionDescriptionSaveCurrentFile":
            MessageLookupByLibrary.simpleMessage("Aktuelle Datei speichern"),
        "actionDescriptionSaveFileAs": MessageLookupByLibrary.simpleMessage(
            "Datei unter einem neuen Namen speichern"),
        "actionDiscardChangesInFile":
            MessageLookupByLibrary.simpleMessage("Datei neu laden"),
        "actionErase":
            MessageLookupByLibrary.simpleMessage("Selection löschen"),
        "actionExit": MessageLookupByLibrary.simpleMessage("Ende"),
        "actionFind": MessageLookupByLibrary.simpleMessage("Suchen..."),
        "actionFindAgainForward":
            MessageLookupByLibrary.simpleMessage("Suche wiederholen..."),
        "actionFindBackward": MessageLookupByLibrary.simpleMessage(
            "Suche rückwärts wiederholen..."),
        "actionFindWordBackward":
            MessageLookupByLibrary.simpleMessage("Wort rückwärts suchen..."),
        "actionFindWordForward":
            MessageLookupByLibrary.simpleMessage("Aktuelles Wort suchen..."),
        "actionGotoLine":
            MessageLookupByLibrary.simpleMessage("Gehe zu Zeile..."),
        "actionNewFile":
            MessageLookupByLibrary.simpleMessage("Neue Datei anlegen..."),
        "actionOpenFile":
            MessageLookupByLibrary.simpleMessage("Datei öffnen..."),
        "actionPaste": MessageLookupByLibrary.simpleMessage("Einfügen"),
        "actionRedo": MessageLookupByLibrary.simpleMessage("Wiederholen"),
        "actionReplace": MessageLookupByLibrary.simpleMessage("Ersetzen..."),
        "actionSaveFile":
            MessageLookupByLibrary.simpleMessage("Datei speichern"),
        "actionSaveFileAs":
            MessageLookupByLibrary.simpleMessage("Datei speichern unter..."),
        "actionSelectAll":
            MessageLookupByLibrary.simpleMessage("Alles auswählen"),
        "actionSelectCursorWordLeft":
            MessageLookupByLibrary.simpleMessage("Wort links selektieren"),
        "actionSelectCursorWordRight":
            MessageLookupByLibrary.simpleMessage("Wort rechts selektieren"),
        "actionSelectPreviousWindow": MessageLookupByLibrary.simpleMessage(
            "Vorheriges Fenster auswählen"),
        "actionSetOptions":
            MessageLookupByLibrary.simpleMessage("Einstellungen ändern..."),
        "actionShiftRangeLeft":
            MessageLookupByLibrary.simpleMessage("Bereich nach links rücken"),
        "actionShiftRangeRight":
            MessageLookupByLibrary.simpleMessage("Bereich nach rechts rücken"),
        "actionShowCopyright":
            MessageLookupByLibrary.simpleMessage("Über PKS Edit..."),
        "actionToggleComment":
            MessageLookupByLibrary.simpleMessage("Kommentare umschalten"),
        "actionToggleShowLineNumbers":
            MessageLookupByLibrary.simpleMessage("Zeilennummern anzeigen"),
        "actionToggleSyntaxHighlighting":
            MessageLookupByLibrary.simpleMessage("Syntax Highlighting"),
        "actionToggleWysiwyg":
            MessageLookupByLibrary.simpleMessage("Wysiwyg Darstellung"),
        "actionUndo": MessageLookupByLibrary.simpleMessage("Rückgängig"),
        "actionUseLinuxLineEnds": MessageLookupByLibrary.simpleMessage(
            "Linefeed als Zeilenende verwenden"),
        "actionUseWindowsLineEnds": MessageLookupByLibrary.simpleMessage(
            "CR+LF als Zeilenende verwenden"),
        "anErrorOccurred": MessageLookupByLibrary.simpleMessage(
            "Ein Fehler ist beim Ausführen des Kommandos aufgetreten"),
        "apply": MessageLookupByLibrary.simpleMessage("Anwenden"),
        "cancel": MessageLookupByLibrary.simpleMessage("Abbruch"),
        "changeSettings":
            MessageLookupByLibrary.simpleMessage("Einstellungen ändern"),
        "closeWithoutSaving":
            MessageLookupByLibrary.simpleMessage("Schließen ohne speichern"),
        "compactEditorTabs":
            MessageLookupByLibrary.simpleMessage("Editor Reiter kompakt"),
        "confirmation": MessageLookupByLibrary.simpleMessage("Bestätigung"),
        "copiedToClipboardHint": m0,
        "enterTextToFind":
            MessageLookupByLibrary.simpleMessage("Text eingeben zur Suche"),
        "enterTextToReplace":
            MessageLookupByLibrary.simpleMessage("Text eingeben zum Ersetzen"),
        "exitPksEdit":
            MessageLookupByLibrary.simpleMessage("PKS Edit verlassen"),
        "exitWithoutSaving":
            MessageLookupByLibrary.simpleMessage("Beenden ohne Speicherung"),
        "fileName": MessageLookupByLibrary.simpleMessage("Dateinnamen"),
        "filesChangedAndExit": MessageLookupByLibrary.simpleMessage(
            "Einige Daeien wurden geändert und müssten gespeichert werden. Wie soll verfahren werden?"),
        "find": MessageLookupByLibrary.simpleMessage("Suchen"),
        "gotoLine": MessageLookupByLibrary.simpleMessage("Gehe zu Zeile"),
        "iconSize": MessageLookupByLibrary.simpleMessage("Icongröße"),
        "ignoreCase": MessageLookupByLibrary.simpleMessage(
            "Groß-/Klein-Schreibung ignorieren"),
        "initializeWithTemplate":
            MessageLookupByLibrary.simpleMessage("Mit Template initialisieren"),
        "language": MessageLookupByLibrary.simpleMessage("Sprache"),
        "lineNumber": MessageLookupByLibrary.simpleMessage("Zeilennummer"),
        "lineNumberRangeHint": m1,
        "maximumNumberOfWindows":
            MessageLookupByLibrary.simpleMessage("Maximale Anzahl Fenster"),
        "newFile": MessageLookupByLibrary.simpleMessage("Neue Datei"),
        "no": MessageLookupByLibrary.simpleMessage("Nein"),
        "reallyDiscardAllChanges": MessageLookupByLibrary.simpleMessage(
            "Willst Du wirklich alle Änderungen verwerfen?"),
        "recentFiles": MessageLookupByLibrary.simpleMessage(
            "Kürzlich bearbeitete Dateien"),
        "regularExpressions":
            MessageLookupByLibrary.simpleMessage("Reguläre Ausdrücke"),
        "reloadChangedFile": m2,
        "replace": MessageLookupByLibrary.simpleMessage("Ersetzen"),
        "replaceAll": MessageLookupByLibrary.simpleMessage("Alle ersetzen"),
        "resource1901": MessageLookupByLibrary.simpleMessage("Datei"),
        "resource1902": MessageLookupByLibrary.simpleMessage("Bearbeiten"),
        "resource1903": MessageLookupByLibrary.simpleMessage("Suchen"),
        "resource1904": MessageLookupByLibrary.simpleMessage("Funktionen"),
        "resource1905": MessageLookupByLibrary.simpleMessage("Makros"),
        "resource1906": MessageLookupByLibrary.simpleMessage("Ansicht"),
        "resource1907": MessageLookupByLibrary.simpleMessage("Extra"),
        "resource1908": MessageLookupByLibrary.simpleMessage("Fenster"),
        "resource1909": MessageLookupByLibrary.simpleMessage("Drucken"),
        "resource1910": MessageLookupByLibrary.simpleMessage("Konvertieren"),
        "resource1911": MessageLookupByLibrary.simpleMessage("Überblick"),
        "resource1913": MessageLookupByLibrary.simpleMessage("Vergleichen"),
        "save": MessageLookupByLibrary.simpleMessage("Speichern"),
        "saveAllAndExit":
            MessageLookupByLibrary.simpleMessage("All speichern und beenden"),
        "searchIncrementally": m3,
        "showStatusbar":
            MessageLookupByLibrary.simpleMessage("Statuszeile anzeigen"),
        "showToolbar": MessageLookupByLibrary.simpleMessage("Toolbar anzeigen"),
        "silentlyReloadFilesChangedExternally":
            MessageLookupByLibrary.simpleMessage(
                "Extern geänderte Dateien ohne Abfrage neu laden"),
        "window": MessageLookupByLibrary.simpleMessage("Fenster"),
        "yes": MessageLookupByLibrary.simpleMessage("Ja")
      };
}
