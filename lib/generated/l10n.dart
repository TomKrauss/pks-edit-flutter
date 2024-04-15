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
