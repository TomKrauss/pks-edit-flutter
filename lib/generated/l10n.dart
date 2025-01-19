// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `File {file} is changed. Do you want to reload it?`
  String reloadChangedFile(Object file) {
    return Intl.message(
      'File $file is changed. Do you want to reload it?',
      name: 'reloadChangedFile',
      desc: '',
      args: [file],
    );
  }

  /// `An error occurred executing the command`
  String get anErrorOccurred {
    return Intl.message(
      'An error occurred executing the command',
      name: 'anErrorOccurred',
      desc: '',
      args: [],
    );
  }

  /// `Flutter version of the famous Atari Code Editor`
  String get aboutInfoText {
    return Intl.message(
      'Flutter version of the famous Atari Code Editor',
      name: 'aboutInfoText',
      desc: '',
      args: [],
    );
  }

  /// `File`
  String get resource1901 {
    return Intl.message(
      'File',
      name: 'resource1901',
      desc: '',
      args: [],
    );
  }

  /// `Print`
  String get resource1909 {
    return Intl.message(
      'Print',
      name: 'resource1909',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get resource1902 {
    return Intl.message(
      'Edit',
      name: 'resource1902',
      desc: '',
      args: [],
    );
  }

  /// `Find`
  String get resource1903 {
    return Intl.message(
      'Find',
      name: 'resource1903',
      desc: '',
      args: [],
    );
  }

  /// `Functions`
  String get resource1904 {
    return Intl.message(
      'Functions',
      name: 'resource1904',
      desc: '',
      args: [],
    );
  }

  /// `Diff`
  String get resource1913 {
    return Intl.message(
      'Diff',
      name: 'resource1913',
      desc: '',
      args: [],
    );
  }

  /// `Convert`
  String get resource1910 {
    return Intl.message(
      'Convert',
      name: 'resource1910',
      desc: '',
      args: [],
    );
  }

  /// `Macros`
  String get resource1905 {
    return Intl.message(
      'Macros',
      name: 'resource1905',
      desc: '',
      args: [],
    );
  }

  /// `Overview`
  String get resource1911 {
    return Intl.message(
      'Overview',
      name: 'resource1911',
      desc: '',
      args: [],
    );
  }

  /// `View`
  String get resource1906 {
    return Intl.message(
      'View',
      name: 'resource1906',
      desc: '',
      args: [],
    );
  }

  /// `Extra`
  String get resource1907 {
    return Intl.message(
      'Extra',
      name: 'resource1907',
      desc: '',
      args: [],
    );
  }

  /// `Windows`
  String get resource1908 {
    return Intl.message(
      'Windows',
      name: 'resource1908',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Compact Editor Tabs`
  String get compactEditorTabs {
    return Intl.message(
      'Compact Editor Tabs',
      name: 'compactEditorTabs',
      desc: '',
      args: [],
    );
  }

  /// `Show Toolbar`
  String get showToolbar {
    return Intl.message(
      'Show Toolbar',
      name: 'showToolbar',
      desc: '',
      args: [],
    );
  }

  /// `Show Statusbar`
  String get showStatusbar {
    return Intl.message(
      'Show Statusbar',
      name: 'showStatusbar',
      desc: '',
      args: [],
    );
  }

  /// `Maximum Number of Windows`
  String get maximumNumberOfWindows {
    return Intl.message(
      'Maximum Number of Windows',
      name: 'maximumNumberOfWindows',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get apply {
    return Intl.message(
      'Apply',
      name: 'apply',
      desc: '',
      args: [],
    );
  }

  /// `Icon Size`
  String get iconSize {
    return Intl.message(
      'Icon Size',
      name: 'iconSize',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Confirmation`
  String get confirmation {
    return Intl.message(
      'Confirmation',
      name: 'confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Search incrementally ({shortcut})`
  String searchIncrementally(Object shortcut) {
    return Intl.message(
      'Search incrementally ($shortcut)',
      name: 'searchIncrementally',
      desc: '',
      args: [shortcut],
    );
  }

  /// `Window`
  String get window {
    return Intl.message(
      'Window',
      name: 'window',
      desc: '',
      args: [],
    );
  }

  /// `Open File...`
  String get actionOpenFile {
    return Intl.message(
      'Open File...',
      name: 'actionOpenFile',
      desc: '',
      args: [],
    );
  }

  /// `New File...`
  String get actionNewFile {
    return Intl.message(
      'New File...',
      name: 'actionNewFile',
      desc: '',
      args: [],
    );
  }

  /// `Save File`
  String get actionSaveFile {
    return Intl.message(
      'Save File',
      name: 'actionSaveFile',
      desc: '',
      args: [],
    );
  }

  /// `Refresh File Contents`
  String get actionDiscardChangesInFile {
    return Intl.message(
      'Refresh File Contents',
      name: 'actionDiscardChangesInFile',
      desc: '',
      args: [],
    );
  }

  /// `Ignore all changes in the current file and refresh contents`
  String get actionDescriptionDiscardChangesInFile {
    return Intl.message(
      'Ignore all changes in the current file and refresh contents',
      name: 'actionDescriptionDiscardChangesInFile',
      desc: '',
      args: [],
    );
  }

  /// `Save File As...`
  String get actionSaveFileAs {
    return Intl.message(
      'Save File As...',
      name: 'actionSaveFileAs',
      desc: '',
      args: [],
    );
  }

  /// `Save current file under new name`
  String get actionDescriptionSaveFileAs {
    return Intl.message(
      'Save current file under new name',
      name: 'actionDescriptionSaveFileAs',
      desc: '',
      args: [],
    );
  }

  /// `Close Window`
  String get actionCloseWindow {
    return Intl.message(
      'Close Window',
      name: 'actionCloseWindow',
      desc: '',
      args: [],
    );
  }

  /// `Closes the current editor window`
  String get actionDescriptionCloseWindow {
    return Intl.message(
      'Closes the current editor window',
      name: 'actionDescriptionCloseWindow',
      desc: '',
      args: [],
    );
  }

  /// `Close All Windows`
  String get actionCloseAllWindows {
    return Intl.message(
      'Close All Windows',
      name: 'actionCloseAllWindows',
      desc: '',
      args: [],
    );
  }

  /// `Closes all editor windows`
  String get actionDescriptionCloseAllWindows {
    return Intl.message(
      'Closes all editor windows',
      name: 'actionDescriptionCloseAllWindows',
      desc: '',
      args: [],
    );
  }

  /// `Close All other Windows`
  String get actionCloseAllButCurrentWindow {
    return Intl.message(
      'Close All other Windows',
      name: 'actionCloseAllButCurrentWindow',
      desc: '',
      args: [],
    );
  }

  /// `Closes all other editor windows but current`
  String get actionDescriptionCloseAllButCurrentWindow {
    return Intl.message(
      'Closes all other editor windows but current',
      name: 'actionDescriptionCloseAllButCurrentWindow',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get actionExit {
    return Intl.message(
      'Exit',
      name: 'actionExit',
      desc: '',
      args: [],
    );
  }

  /// `Search Word on Internet`
  String get actionSearchOnInternet {
    return Intl.message(
      'Search Word on Internet',
      name: 'actionSearchOnInternet',
      desc: '',
      args: [],
    );
  }

  /// `Use LF for Line Ends`
  String get actionUseLinuxLineEnds {
    return Intl.message(
      'Use LF for Line Ends',
      name: 'actionUseLinuxLineEnds',
      desc: '',
      args: [],
    );
  }

  /// `Use CR+LF for Line Ends`
  String get actionUseWindowsLineEnds {
    return Intl.message(
      'Use CR+LF for Line Ends',
      name: 'actionUseWindowsLineEnds',
      desc: '',
      args: [],
    );
  }

  /// `Apply Outdent`
  String get actionShiftRangeLeft {
    return Intl.message(
      'Apply Outdent',
      name: 'actionShiftRangeLeft',
      desc: '',
      args: [],
    );
  }

  /// `Apply Indent`
  String get actionShiftRangeRight {
    return Intl.message(
      'Apply Indent',
      name: 'actionShiftRangeRight',
      desc: '',
      args: [],
    );
  }

  /// `Show Line Numbers`
  String get actionToggleShowLineNumbers {
    return Intl.message(
      'Show Line Numbers',
      name: 'actionToggleShowLineNumbers',
      desc: '',
      args: [],
    );
  }

  /// `Syntax Highlighting`
  String get actionToggleSyntaxHighlighting {
    return Intl.message(
      'Syntax Highlighting',
      name: 'actionToggleSyntaxHighlighting',
      desc: '',
      args: [],
    );
  }

  /// `Show Wysiwyg`
  String get actionToggleWysiwyg {
    return Intl.message(
      'Show Wysiwyg',
      name: 'actionToggleWysiwyg',
      desc: '',
      args: [],
    );
  }

  /// `Exit PKS Edit`
  String get actionDescriptionExit {
    return Intl.message(
      'Exit PKS Edit',
      name: 'actionDescriptionExit',
      desc: '',
      args: [],
    );
  }

  /// `Save current file`
  String get actionDescriptionSaveCurrentFile {
    return Intl.message(
      'Save current file',
      name: 'actionDescriptionSaveCurrentFile',
      desc: '',
      args: [],
    );
  }

  /// `Undo`
  String get actionUndo {
    return Intl.message(
      'Undo',
      name: 'actionUndo',
      desc: '',
      args: [],
    );
  }

  /// `Delete Selection`
  String get actionErase {
    return Intl.message(
      'Delete Selection',
      name: 'actionErase',
      desc: '',
      args: [],
    );
  }

  /// `Redo`
  String get actionRedo {
    return Intl.message(
      'Redo',
      name: 'actionRedo',
      desc: '',
      args: [],
    );
  }

  /// `Find...`
  String get actionFind {
    return Intl.message(
      'Find...',
      name: 'actionFind',
      desc: '',
      args: [],
    );
  }

  /// `Find in Files...`
  String get actionFindInFiles {
    return Intl.message(
      'Find in Files...',
      name: 'actionFindInFiles',
      desc: '',
      args: [],
    );
  }

  /// `Find Next...`
  String get actionFindAgainForward {
    return Intl.message(
      'Find Next...',
      name: 'actionFindAgainForward',
      desc: '',
      args: [],
    );
  }

  /// `Find Previous...`
  String get actionFindBackward {
    return Intl.message(
      'Find Previous...',
      name: 'actionFindBackward',
      desc: '',
      args: [],
    );
  }

  /// `Find current word...`
  String get actionFindWordForward {
    return Intl.message(
      'Find current word...',
      name: 'actionFindWordForward',
      desc: '',
      args: [],
    );
  }

  /// `Find current word backward...`
  String get actionFindWordBackward {
    return Intl.message(
      'Find current word backward...',
      name: 'actionFindWordBackward',
      desc: '',
      args: [],
    );
  }

  /// `Cursor word left`
  String get actionCursorWordLeft {
    return Intl.message(
      'Cursor word left',
      name: 'actionCursorWordLeft',
      desc: '',
      args: [],
    );
  }

  /// `Cursor word right`
  String get actionCursorWordRight {
    return Intl.message(
      'Cursor word right',
      name: 'actionCursorWordRight',
      desc: '',
      args: [],
    );
  }

  /// `Select word left`
  String get actionSelectCursorWordLeft {
    return Intl.message(
      'Select word left',
      name: 'actionSelectCursorWordLeft',
      desc: '',
      args: [],
    );
  }

  /// `Select word right`
  String get actionSelectCursorWordRight {
    return Intl.message(
      'Select word right',
      name: 'actionSelectCursorWordRight',
      desc: '',
      args: [],
    );
  }

  /// `Toggle Full-screen`
  String get actionToggleFullScreen {
    return Intl.message(
      'Toggle Full-screen',
      name: 'actionToggleFullScreen',
      desc: '',
      args: [],
    );
  }

  /// `Increase zoom factor`
  String get actionZoomIncrease {
    return Intl.message(
      'Increase zoom factor',
      name: 'actionZoomIncrease',
      desc: '',
      args: [],
    );
  }

  /// `Decrease zoom factor`
  String get actionZoomDecrease {
    return Intl.message(
      'Decrease zoom factor',
      name: 'actionZoomDecrease',
      desc: '',
      args: [],
    );
  }

  /// `Replace...`
  String get actionReplace {
    return Intl.message(
      'Replace...',
      name: 'actionReplace',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get actionCopy {
    return Intl.message(
      'Copy',
      name: 'actionCopy',
      desc: '',
      args: [],
    );
  }

  /// `Cut`
  String get actionCut {
    return Intl.message(
      'Cut',
      name: 'actionCut',
      desc: '',
      args: [],
    );
  }

  /// `Paste`
  String get actionPaste {
    return Intl.message(
      'Paste',
      name: 'actionPaste',
      desc: '',
      args: [],
    );
  }

  /// `Select All`
  String get actionSelectAll {
    return Intl.message(
      'Select All',
      name: 'actionSelectAll',
      desc: '',
      args: [],
    );
  }

  /// `Convert to Upper Case`
  String get actionCharToUpper {
    return Intl.message(
      'Convert to Upper Case',
      name: 'actionCharToUpper',
      desc: '',
      args: [],
    );
  }

  /// `Convert to Lower Case`
  String get actionCharToLower {
    return Intl.message(
      'Convert to Lower Case',
      name: 'actionCharToLower',
      desc: '',
      args: [],
    );
  }

  /// `Toggle Upper/Lower Case`
  String get actionCharToggleUpperLower {
    return Intl.message(
      'Toggle Upper/Lower Case',
      name: 'actionCharToggleUpperLower',
      desc: '',
      args: [],
    );
  }

  /// `Comment Single Line`
  String get actionToggleComment {
    return Intl.message(
      'Comment Single Line',
      name: 'actionToggleComment',
      desc: '',
      args: [],
    );
  }

  /// `Cycle window forward`
  String get actionCycleWindow {
    return Intl.message(
      'Cycle window forward',
      name: 'actionCycleWindow',
      desc: '',
      args: [],
    );
  }

  /// `Change Settings...`
  String get actionSetOptions {
    return Intl.message(
      'Change Settings...',
      name: 'actionSetOptions',
      desc: '',
      args: [],
    );
  }

  /// `Goto line...`
  String get actionGotoLine {
    return Intl.message(
      'Goto line...',
      name: 'actionGotoLine',
      desc: '',
      args: [],
    );
  }

  /// `About PKS Edit...`
  String get actionShowCopyright {
    return Intl.message(
      'About PKS Edit...',
      name: 'actionShowCopyright',
      desc: '',
      args: [],
    );
  }

  /// `Cycle window backward`
  String get actionSelectPreviousWindow {
    return Intl.message(
      'Cycle window backward',
      name: 'actionSelectPreviousWindow',
      desc: '',
      args: [],
    );
  }

  /// `Copied {length} characters to the clipboard.`
  String copiedToClipboardHint(Object length) {
    return Intl.message(
      'Copied $length characters to the clipboard.',
      name: 'copiedToClipboardHint',
      desc: '',
      args: [length],
    );
  }

  /// `Do you really want to discard all changes?`
  String get reallyDiscardAllChanges {
    return Intl.message(
      'Do you really want to discard all changes?',
      name: 'reallyDiscardAllChanges',
      desc: '',
      args: [],
    );
  }

  /// `Goto Line`
  String get gotoLine {
    return Intl.message(
      'Goto Line',
      name: 'gotoLine',
      desc: '',
      args: [],
    );
  }

  /// `Line number`
  String get lineNumber {
    return Intl.message(
      'Line number',
      name: 'lineNumber',
      desc: '',
      args: [],
    );
  }

  /// `Line number must be in range: 1 - {lineCount}.`
  String lineNumberRangeHint(Object lineCount) {
    return Intl.message(
      'Line number must be in range: 1 - $lineCount.',
      name: 'lineNumberRangeHint',
      desc: '',
      args: [lineCount],
    );
  }

  /// `Change Settings`
  String get changeSettings {
    return Intl.message(
      'Change Settings',
      name: 'changeSettings',
      desc: '',
      args: [],
    );
  }

  /// `Initialize with Template`
  String get initializeWithTemplate {
    return Intl.message(
      'Initialize with Template',
      name: 'initializeWithTemplate',
      desc: '',
      args: [],
    );
  }

  /// `New File`
  String get newFile {
    return Intl.message(
      'New File',
      name: 'newFile',
      desc: '',
      args: [],
    );
  }

  /// `File name`
  String get fileName {
    return Intl.message(
      'File name',
      name: 'fileName',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Close without Saving`
  String get closeWithoutSaving {
    return Intl.message(
      'Close without Saving',
      name: 'closeWithoutSaving',
      desc: '',
      args: [],
    );
  }

  /// `Save All and Exit`
  String get saveAllAndExit {
    return Intl.message(
      'Save All and Exit',
      name: 'saveAllAndExit',
      desc: '',
      args: [],
    );
  }

  /// `Exit without Saving`
  String get exitWithoutSaving {
    return Intl.message(
      'Exit without Saving',
      name: 'exitWithoutSaving',
      desc: '',
      args: [],
    );
  }

  /// `Exit PKS Edit`
  String get exitPksEdit {
    return Intl.message(
      'Exit PKS Edit',
      name: 'exitPksEdit',
      desc: '',
      args: [],
    );
  }

  /// `Some files are changed and not yet saved. How should we proceed?`
  String get filesChangedAndExit {
    return Intl.message(
      'Some files are changed and not yet saved. How should we proceed?',
      name: 'filesChangedAndExit',
      desc: '',
      args: [],
    );
  }

  /// `Recent Files`
  String get recentFiles {
    return Intl.message(
      'Recent Files',
      name: 'recentFiles',
      desc: '',
      args: [],
    );
  }

  /// `Find`
  String get find {
    return Intl.message(
      'Find',
      name: 'find',
      desc: '',
      args: [],
    );
  }

  /// `Replace`
  String get replace {
    return Intl.message(
      'Replace',
      name: 'replace',
      desc: '',
      args: [],
    );
  }

  /// `Replace All`
  String get replaceAll {
    return Intl.message(
      'Replace All',
      name: 'replaceAll',
      desc: '',
      args: [],
    );
  }

  /// `Ignore Case`
  String get ignoreCase {
    return Intl.message(
      'Ignore Case',
      name: 'ignoreCase',
      desc: '',
      args: [],
    );
  }

  /// `Regular Expressions`
  String get regularExpressions {
    return Intl.message(
      'Regular Expressions',
      name: 'regularExpressions',
      desc: '',
      args: [],
    );
  }

  /// `Enter text to find`
  String get enterTextToFind {
    return Intl.message(
      'Enter text to find',
      name: 'enterTextToFind',
      desc: '',
      args: [],
    );
  }

  /// `Enter text to replace`
  String get enterTextToReplace {
    return Intl.message(
      'Enter text to replace',
      name: 'enterTextToReplace',
      desc: '',
      args: [],
    );
  }

  /// `Silently reload files changed externally`
  String get silentlyReloadFilesChangedExternally {
    return Intl.message(
      'Silently reload files changed externally',
      name: 'silentlyReloadFilesChangedExternally',
      desc: '',
      args: [],
    );
  }

  /// `Saving`
  String get saving {
    return Intl.message(
      'Saving',
      name: 'saving',
      desc: '',
      args: [],
    );
  }

  /// `Hints`
  String get warnings {
    return Intl.message(
      'Hints',
      name: 'warnings',
      desc: '',
      args: [],
    );
  }

  /// `Layout`
  String get layout {
    return Intl.message(
      'Layout',
      name: 'layout',
      desc: '',
      args: [],
    );
  }

  /// `Autosave files on exit`
  String get autosaveFilesOnExit {
    return Intl.message(
      'Autosave files on exit',
      name: 'autosaveFilesOnExit',
      desc: '',
      args: [],
    );
  }

  /// `Autosave time in seconds`
  String get autosaveTimeInSeconds {
    return Intl.message(
      'Autosave time in seconds',
      name: 'autosaveTimeInSeconds',
      desc: '',
      args: [],
    );
  }

  /// `Play sound on error`
  String get playSoundOnError {
    return Intl.message(
      'Play sound on error',
      name: 'playSoundOnError',
      desc: '',
      args: [],
    );
  }

  /// `Show errors in toast popup`
  String get showErrorsInToastPopup {
    return Intl.message(
      'Show errors in toast popup',
      name: 'showErrorsInToastPopup',
      desc: '',
      args: [],
    );
  }

  /// `Select Directory`
  String get selectDirectory {
    return Intl.message(
      'Select Directory',
      name: 'selectDirectory',
      desc: '',
      args: [],
    );
  }

  /// `Find in Folder`
  String get findInFolder {
    return Intl.message(
      'Find in Folder',
      name: 'findInFolder',
      desc: '',
      args: [],
    );
  }

  /// `Single Match in File`
  String get singleMatchInFile {
    return Intl.message(
      'Single Match in File',
      name: 'singleMatchInFile',
      desc: '',
      args: [],
    );
  }

  /// `Ignore Binary Files`
  String get ignoreBinaryFiles {
    return Intl.message(
      'Ignore Binary Files',
      name: 'ignoreBinaryFiles',
      desc: '',
      args: [],
    );
  }

  /// `File Name Patterns`
  String get fileNamePatterns {
    return Intl.message(
      'File Name Patterns',
      name: 'fileNamePatterns',
      desc: '',
      args: [],
    );
  }

  /// `Match regular Expressions`
  String get matchRegularExpressions {
    return Intl.message(
      'Match regular Expressions',
      name: 'matchRegularExpressions',
      desc: '',
      args: [],
    );
  }

  /// `Preserve Case`
  String get preserveCase {
    return Intl.message(
      'Preserve Case',
      name: 'preserveCase',
      desc: '',
      args: [],
    );
  }

  /// `Search and Replace in Files`
  String get searchAndReplaceInFiles {
    return Intl.message(
      'Search and Replace in Files',
      name: 'searchAndReplaceInFiles',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
