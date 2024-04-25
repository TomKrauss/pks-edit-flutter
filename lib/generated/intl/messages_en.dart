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
        "actionCharToLower":
            MessageLookupByLibrary.simpleMessage("Convert to Lower Case"),
        "actionCharToUpper":
            MessageLookupByLibrary.simpleMessage("Convert to Upper Case"),
        "actionCharToggleUpperLower":
            MessageLookupByLibrary.simpleMessage("Toggle Upper/Lower Case"),
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
        "actionFind": MessageLookupByLibrary.simpleMessage("Find..."),
        "actionFindAgainForward":
            MessageLookupByLibrary.simpleMessage("Find Next..."),
        "actionFindBackward":
            MessageLookupByLibrary.simpleMessage("Find Previous..."),
        "actionFindWordBackward": MessageLookupByLibrary.simpleMessage(
            "Find current word backward..."),
        "actionFindWordForward":
            MessageLookupByLibrary.simpleMessage("Find current word..."),
        "actionGotoLine": MessageLookupByLibrary.simpleMessage("Goto line..."),
        "actionNewFile": MessageLookupByLibrary.simpleMessage("New File..."),
        "actionOpenFile": MessageLookupByLibrary.simpleMessage("Open File..."),
        "actionPaste": MessageLookupByLibrary.simpleMessage("Paste"),
        "actionRedo": MessageLookupByLibrary.simpleMessage("Redo"),
        "actionReplace": MessageLookupByLibrary.simpleMessage("Replace..."),
        "actionSaveFile": MessageLookupByLibrary.simpleMessage("Save File"),
        "actionSaveFileAs":
            MessageLookupByLibrary.simpleMessage("Save File As..."),
        "actionSelectAll": MessageLookupByLibrary.simpleMessage("Select All"),
        "actionSelectPreviousWindow":
            MessageLookupByLibrary.simpleMessage("Cycle window backward"),
        "actionSetOptions":
            MessageLookupByLibrary.simpleMessage("Change Settings..."),
        "actionShiftRangeLeft":
            MessageLookupByLibrary.simpleMessage("Apply Outdent"),
        "actionShiftRangeRight":
            MessageLookupByLibrary.simpleMessage("Apply Indent"),
        "actionShowCopyright":
            MessageLookupByLibrary.simpleMessage("About PKS Edit..."),
        "actionToggleComment":
            MessageLookupByLibrary.simpleMessage("Comment Single Line"),
        "actionToggleShowLineNumbers":
            MessageLookupByLibrary.simpleMessage("Show Line Numbers"),
        "actionToggleSyntaxHighlighting":
            MessageLookupByLibrary.simpleMessage("Syntax Highlighting"),
        "actionUndo": MessageLookupByLibrary.simpleMessage("Undo"),
        "actionUseLinuxLineEnds":
            MessageLookupByLibrary.simpleMessage("Use LF for Line Ends"),
        "actionUseWindowsLineEnds":
            MessageLookupByLibrary.simpleMessage("Use CR+LF for Line Ends"),
        "anErrorOccurred": MessageLookupByLibrary.simpleMessage(
            "An error occurred executing the command"),
        "apply": MessageLookupByLibrary.simpleMessage("Apply"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "changeSettings":
            MessageLookupByLibrary.simpleMessage("Change Settings"),
        "closeWithoutSaving":
            MessageLookupByLibrary.simpleMessage("Close without Saving"),
        "compactEditorTabs":
            MessageLookupByLibrary.simpleMessage("Compact Editor Tabs"),
        "confirmation": MessageLookupByLibrary.simpleMessage("Confirmation"),
        "copiedToClipboardHint": m0,
        "enterTextToFind":
            MessageLookupByLibrary.simpleMessage("Enter text to find"),
        "enterTextToReplace":
            MessageLookupByLibrary.simpleMessage("Enter text to replace"),
        "exitPksEdit": MessageLookupByLibrary.simpleMessage("Exit PKS Edit"),
        "exitWithoutSaving":
            MessageLookupByLibrary.simpleMessage("Exit without Saving"),
        "fileName": MessageLookupByLibrary.simpleMessage("File name"),
        "filesChangedAndExit": MessageLookupByLibrary.simpleMessage(
            "Some files are changed and not yet saved. How should we proceed?"),
        "find": MessageLookupByLibrary.simpleMessage("Find"),
        "gotoLine": MessageLookupByLibrary.simpleMessage("Goto Line"),
        "iconSize": MessageLookupByLibrary.simpleMessage("Icon Size"),
        "ignoreCase": MessageLookupByLibrary.simpleMessage("Ignore Case"),
        "initializeWithTemplate":
            MessageLookupByLibrary.simpleMessage("Initialize with Template"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "lineNumber": MessageLookupByLibrary.simpleMessage("Line number"),
        "lineNumberRangeHint": m1,
        "maximumNumberOfWindows":
            MessageLookupByLibrary.simpleMessage("Maximum Number of Windows"),
        "newFile": MessageLookupByLibrary.simpleMessage("New File"),
        "no": MessageLookupByLibrary.simpleMessage("No"),
        "reallyDiscardAllChanges": MessageLookupByLibrary.simpleMessage(
            "Do you really want to discard all changes?"),
        "recentFiles": MessageLookupByLibrary.simpleMessage("Recent Files"),
        "regularExpressions":
            MessageLookupByLibrary.simpleMessage("Regular Expressions"),
        "reloadChangedFile": m2,
        "replace": MessageLookupByLibrary.simpleMessage("Replace"),
        "replaceAll": MessageLookupByLibrary.simpleMessage("Replace All"),
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
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "saveAllAndExit":
            MessageLookupByLibrary.simpleMessage("Save All and Exit"),
        "searchIncrementally": m3,
        "showStatusbar": MessageLookupByLibrary.simpleMessage("Show Statusbar"),
        "showToolbar": MessageLookupByLibrary.simpleMessage("Show Toolbar"),
        "silentlyReloadFilesChangedExternally":
            MessageLookupByLibrary.simpleMessage(
                "Silently reload files changed externally"),
        "window": MessageLookupByLibrary.simpleMessage("Window"),
        "yes": MessageLookupByLibrary.simpleMessage("Yes")
      };
}
