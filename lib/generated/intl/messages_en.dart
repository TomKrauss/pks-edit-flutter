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

  static String m0(length) => "Copied ${length} characters to the clipboard.";

  static String m1(lineCount) =>
      "Line number must be in range: 1 - ${lineCount}.";

  static String m2(file) =>
      "File ${file} is changed. Do you want to reload it?";

  static String m3(shortcut) => "Search incrementally (${shortcut})";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "aboutInfoText": MessageLookupByLibrary.simpleMessage(
            "Flutter version of the famous Atari Code Editor"),
        "actionCloseAllButCurrentWindow":
            MessageLookupByLibrary.simpleMessage("Close All other Windows"),
        "actionCloseAllWindows":
            MessageLookupByLibrary.simpleMessage("Close All Windows"),
        "actionCloseWindow":
            MessageLookupByLibrary.simpleMessage("Close Window"),
        "actionCopy": MessageLookupByLibrary.simpleMessage("Copy"),
        "actionCut": MessageLookupByLibrary.simpleMessage("Cut"),
        "actionCycleWindow":
            MessageLookupByLibrary.simpleMessage("Cycle window forward"),
        "actionDescriptionCloseAllButCurrentWindow":
            MessageLookupByLibrary.simpleMessage(
                "Closes all other editor windows but current"),
        "actionDescriptionCloseAllWindows":
            MessageLookupByLibrary.simpleMessage("Closes all editor windows"),
        "actionDescriptionCloseWindow": MessageLookupByLibrary.simpleMessage(
            "Closes the current editor window"),
        "actionDescriptionDiscardChangesInFile":
            MessageLookupByLibrary.simpleMessage(
                "Ignore all changes in the current file and refresh contents"),
        "actionDescriptionExit":
            MessageLookupByLibrary.simpleMessage("Exit PKS Edit"),
        "actionDescriptionSaveCurrentFile":
            MessageLookupByLibrary.simpleMessage("Save current file"),
        "actionDescriptionSaveFileAs": MessageLookupByLibrary.simpleMessage(
            "Save current file under new name"),
        "actionDiscardChangesInFile":
            MessageLookupByLibrary.simpleMessage("Refresh File Contents"),
        "actionErase": MessageLookupByLibrary.simpleMessage("Delete Selection"),
        "actionExit": MessageLookupByLibrary.simpleMessage("Exit"),
        "actionGotoLine": MessageLookupByLibrary.simpleMessage("Goto line..."),
        "actionNewFile": MessageLookupByLibrary.simpleMessage("New File..."),
        "actionOpenFile": MessageLookupByLibrary.simpleMessage("Open File..."),
        "actionPaste": MessageLookupByLibrary.simpleMessage("Paste"),
        "actionRedo": MessageLookupByLibrary.simpleMessage("Redo"),
        "actionSaveFile": MessageLookupByLibrary.simpleMessage("Save File"),
        "actionSaveFileAs":
            MessageLookupByLibrary.simpleMessage("Save File As..."),
        "actionSelectAll": MessageLookupByLibrary.simpleMessage("Select All"),
        "actionSelectPreviousWindow":
            MessageLookupByLibrary.simpleMessage("Cycle window backward"),
        "actionSetOptions":
            MessageLookupByLibrary.simpleMessage("Change Settings..."),
        "actionShowCopyright":
            MessageLookupByLibrary.simpleMessage("About PKS Edit..."),
        "actionToggleComment":
            MessageLookupByLibrary.simpleMessage("Comment Single Line"),
        "actionUndo": MessageLookupByLibrary.simpleMessage("Undo"),
        "anErrorOccurred": MessageLookupByLibrary.simpleMessage(
            "An error occurred executing the command"),
        "apply": MessageLookupByLibrary.simpleMessage("Apply"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "compactEditorTabs":
            MessageLookupByLibrary.simpleMessage("Compact Editor Tabs"),
        "confirmation": MessageLookupByLibrary.simpleMessage("Confirmation"),
        "copiedToClipboardHint": m0,
        "gotoLine": MessageLookupByLibrary.simpleMessage("Goto Line"),
        "iconSize": MessageLookupByLibrary.simpleMessage("Icon Size"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "lineNumber": MessageLookupByLibrary.simpleMessage("Line number"),
        "lineNumberRangeHint": m1,
        "maximumNumberOfWindows":
            MessageLookupByLibrary.simpleMessage("Maximum Number of Windows"),
        "no": MessageLookupByLibrary.simpleMessage("No"),
        "reallyDiscardAllChanges": MessageLookupByLibrary.simpleMessage(
            "Do you really want to discard all changes?"),
        "reloadChangedFile": m2,
        "resource1901": MessageLookupByLibrary.simpleMessage("File"),
        "resource1902": MessageLookupByLibrary.simpleMessage("Edit"),
        "resource1903": MessageLookupByLibrary.simpleMessage("Find"),
        "resource1904": MessageLookupByLibrary.simpleMessage("Functions"),
        "resource1905": MessageLookupByLibrary.simpleMessage("Macros"),
        "resource1906": MessageLookupByLibrary.simpleMessage("View"),
        "resource1907": MessageLookupByLibrary.simpleMessage("Extra"),
        "resource1908": MessageLookupByLibrary.simpleMessage("Windows"),
        "resource1909": MessageLookupByLibrary.simpleMessage("Print"),
        "resource1910": MessageLookupByLibrary.simpleMessage("Convert"),
        "resource1911": MessageLookupByLibrary.simpleMessage("Overview"),
        "resource1913": MessageLookupByLibrary.simpleMessage("Diff"),
        "searchIncrementally": m3,
        "showStatusbar": MessageLookupByLibrary.simpleMessage("Show Statusbar"),
        "showToolbar": MessageLookupByLibrary.simpleMessage("Show Toolbar"),
        "window": MessageLookupByLibrary.simpleMessage("Window"),
        "yes": MessageLookupByLibrary.simpleMessage("Yes")
      };
}
