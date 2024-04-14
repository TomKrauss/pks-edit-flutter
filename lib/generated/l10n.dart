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
  String get file {
    return Intl.message(
      'File',
      name: 'file',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
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

  /// `Functions`
  String get functions {
    return Intl.message(
      'Functions',
      name: 'functions',
      desc: '',
      args: [],
    );
  }

  /// `About...`
  String get about {
    return Intl.message(
      'About...',
      name: 'about',
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
