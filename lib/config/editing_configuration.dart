//
// editing_configuration.dart
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

import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart' as path;
import 'package:pks_edit_flutter/util/platform_extension.dart';

part 'editing_configuration.g.dart';

///
/// A configuration to be applied to files opened defining modes, how the files are edited.
/// Can be changed during runtime.
///
@JsonSerializable(includeIfNull: false)
class EditingConfiguration {
  /// Configuration name - multiple configurations may exist and may be associated with different file types.
  final String name;
  /// left and right margins (used e.g. for wrapping and formatting text).
  final int leftMargin;
  final int rightMargin;
  /// Number of columns for the tab character
  final int tabSize;
  /// When inserting a tabulator - replace with this (fill character). If null - tabs are not expanded.
  final String? expandTabsWith;
  /// Returns the regular expression used to match a word for the described document type.
  final String wordTokenExpression;
  /// Returns the regular expression used to match a word for the described document type.
  RegExp get wordTokenRE => RegExp(wordTokenExpression);
  /// The filename extension used, when creating backup files during save.
  final String backupExtension;
  /// Whether line numbers should be displayed.
  final bool showLineNumbers;
  /// Whether syntax highlighting should be performed.
  final bool showSyntaxHighlight;
  /// Toggle the editor window to display the document using a hex editing component.
  final bool hexMode;
  /// For document types supporting a what you see is what you get display, open the preview editor.
  final bool showWysiwyg;

  const EditingConfiguration({
    this.name = "default",
    this.leftMargin = 0,
    this.rightMargin = 80,
    this.tabSize = 4,
    this.hexMode = false,
    this.showWysiwyg = false,
    this.expandTabsWith,
    this.showLineNumbers = true,
    this.showSyntaxHighlight = true,
    this.backupExtension = "bak",
    this.wordTokenExpression = r'[a-zA-ZöäüÖÄÜß][a-zA-Z0-9_öäüÖÄÜß]*'});

  ///
  /// To modify the current editing configuration use this copy constructor.
  ///
  EditingConfiguration copyWith({
    int? leftMargin,
    int? rightMargin,
    int? tabSize,
    bool? hexMode,
    bool? showWysiwyg,
    String? expandTabsWith,
    bool? showLineNumbers,
    bool? showSyntaxHighlight,
    String? backupExtension,
    String? wordTokenExpression}) => EditingConfiguration(
      name: name,
      hexMode: hexMode ?? this.hexMode,
      showWysiwyg: showWysiwyg ?? this.showWysiwyg,
      leftMargin: leftMargin ?? this.leftMargin,
      rightMargin: rightMargin ?? this.rightMargin,
      tabSize: tabSize ?? this.tabSize,
      expandTabsWith: expandTabsWith ?? this.expandTabsWith,
      showLineNumbers: showLineNumbers ?? this.showLineNumbers,
      showSyntaxHighlight: showSyntaxHighlight ?? this.showSyntaxHighlight,
      backupExtension: backupExtension ?? this.backupExtension,
      wordTokenExpression: wordTokenExpression ?? this.wordTokenExpression
  );

  static const EditingConfiguration defaultConfiguration = EditingConfiguration(name: "default");

  static EditingConfiguration fromJson(Map<String, dynamic> map) =>
      _$EditingConfigurationFromJson(map);
  Map<String, dynamic> toJson() => _$EditingConfigurationToJson(this);
}

///
/// Describes various types of documents, which can be edited with PKS EDIT.
///
@JsonSerializable(includeIfNull: false)
class DocumentType {
  /// The name of this document type.
  final String name;
  /// Name of the grammar associated with this file type - is also used as primary language name.
  final String grammar;
  /// The list of alternative language names - if any.
  final List<String> languages;
  /// Description for the file selector.
  final String? description;
  /// File name pattern to match
  final String filenamePatterns;
  ///
  /// File name patterns as a list.
  ///
  List<String> get filePatterns => filenamePatterns.split(PlatformExtension.filePathSeparator);

  /// Name of the editing configuration to use for this document type.
  final String editorConfiguration;
  /// Can be used to match a file type by parsing the 1st line contained in that file rather than by filename pattern.
  final String? firstLineMatch;
  const DocumentType({required this.name, this.grammar = "default", this.languages = const [], this.description, this.editorConfiguration = "default",
    required this.filenamePatterns, this.firstLineMatch});

  static const DocumentType defaultConfiguration = DocumentType(name: "default", filenamePatterns: "*.*");

  static DocumentType fromJson(Map<String, dynamic> map) =>
      _$DocumentTypeFromJson(map);
  Map<String, dynamic> toJson() => _$DocumentTypeToJson(this);

}

///
/// The configurations with the document types and editor configurations available.
///
@JsonSerializable(includeIfNull: false)
class EditingConfigurations {
  final List<DocumentType> documentTypes;
  final List<EditingConfiguration> editorConfigurations;
  late final Map<String,EditingConfiguration> _editingConfigLookup;
  late final Map<String,DocumentType> _documentTypeByExtensionLookup;
  EditingConfigurations({this.documentTypes = const [ DocumentType.defaultConfiguration], this.editorConfigurations = const[ EditingConfiguration.defaultConfiguration]}) {
    _editingConfigLookup = {};
    for (final e in editorConfigurations) {
      _editingConfigLookup[e.name] = e;
    }
    _documentTypeByExtensionLookup = {};
    for (final dt in documentTypes) {
      if (dt.firstLineMatch != null) {
        continue;
      }
      for (var ext in dt.filePatterns) {
        ext = path.extension(ext);
        if (ext.isNotEmpty && ext != "*") {
          _documentTypeByExtensionLookup[ext] = dt;
        }
      }
    }
  }

  static EditingConfigurations fromJson(Map<String, dynamic> map) =>
      _$EditingConfigurationsFromJson(map);
  Map<String, dynamic> toJson() => _$EditingConfigurationsToJson(this);

  ///
  /// Return the editing configuration to use for a file with the given [filename].
  ///
  Future<EditingConfiguration> forFile(String filename) async {
    var extension = path.extension(filename);
    // try a quick extension lookup first
    final documentType = _documentTypeByExtensionLookup[extension] ?? await _findDocumentType(filename);
    return _editingConfigLookup[documentType.editorConfiguration] ?? EditingConfiguration.defaultConfiguration;
  }

  Future<DocumentType> _findDocumentType(String filename) async {
    for (final dt in documentTypes) {
      if (dt.firstLineMatch != null) {
        final s = await File(filename).openRead().transform(utf8.decoder).transform(const LineSplitter()).first;
        if (RegExp(dt.firstLineMatch!).hasMatch(s)) {
          return dt;
        }
      }
      for (final pattern in dt.filePatterns) {
        /// todo: implement complete file name match.
        if ((pattern == "*" && path.extension(filename).isEmpty) || pattern == "*.*") {
          return dt;
        }
      }
    }
    return DocumentType.defaultConfiguration;
  }

  ///
  /// The file groups to display in file selectors, when selecting a file.
  ///
  List<XTypeGroup> getFileGroups(String currentFile) {
    final result = <XTypeGroup>[];
    var ext = path.extension(currentFile);
    if (ext.startsWith(".")) {
      ext = ext.substring(1);
    }
    for (final e in documentTypes) {
      if (e.filePatterns.isNotEmpty) {
        var patterns = e.filePatterns;
        if (patterns.contains("*.*")) {
          patterns = [...patterns, "*"];
        }
        final group = XTypeGroup(label: e.description ?? e.name, extensions: patterns);
        if (e.filePatterns.contains(ext)) {
          result.insert(0, group);
        } else {
          result.add(group);
        }
      }
    }
    return result;
  }
}
