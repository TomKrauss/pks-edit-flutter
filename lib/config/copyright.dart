//
// copyright.dart
//
// PKS-EDIT - Flutter
//
// Last modified: 2025
// Author: Tom Krauß
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:pks_edit_flutter/bloc/grammar.dart';
import 'package:pks_edit_flutter/config/pks_sys.dart';
import 'package:pks_edit_flutter/util/logger.dart';

part 'copyright.g.dart';

///
/// Describes how a profile is to be inserted depending on the language of
/// the file.
///
@JsonSerializable()
class LanguageOption {
  /// Whether we should use single line comments to insert a template.
  @JsonKey(name: "single-line-comments")
  final bool singleLineComments;
  /// Whether a blank line should be added in front of the copyright
  @JsonKey(name: "add-blank-line-before")
  final bool addBlankLineBefore;
  /// Whether a blank line should be added at the end of the copyright
  @JsonKey(name: "add-blank-line-after")
  final bool addBlankLineAfter;
  final String language;

  LanguageOption({this.singleLineComments = false, this.addBlankLineBefore = false, this.addBlankLineAfter = false, required this.language});

  static LanguageOption fromJson(Map<String, dynamic> jsonInput) =>
      _$LanguageOptionFromJson(jsonInput);
  Map<String, dynamic> toJson() => _$LanguageOptionToJson(this);

}

///
/// The actual profile definition.
///
@JsonSerializable()
class CopyrightProfile {
  /// The name of the copyright profile
  final String name;
  /// The notice of the copyright profile - the actual contents.
  final String notice;

  CopyrightProfile({required this.name, required this.notice});

  static CopyrightProfile fromJson(Map<String, dynamic> jsonInput) =>
      _$CopyrightProfileFromJson(jsonInput);
  Map<String, dynamic> toJson() => _$CopyrightProfileToJson(this);

}

@JsonSerializable()
class CopyrightProfiles {
  /// The name of the currently selected copyright profile
  @JsonKey(name: "default")
  final String? currentProfile;
  final List<CopyrightProfile> profiles;
  @JsonKey(name: "language-options")
  final List<LanguageOption> languageOptions;

  CopyrightProfile get activeProfile => profiles.firstWhereOrNull((p) => p.name == currentProfile) ?? profiles.firstOrNull ??
      CopyrightProfile(name: "default", notice: "");

  LanguageOption forLanguage(String language) {
    var o = languageOptions.firstWhereOrNull((l) => l.language == language);
    return o ?? LanguageOption(language: "generic");
  }

  CopyrightProfiles({this.currentProfile, required this.profiles, this.languageOptions = const[]});

  static CopyrightProfiles fromJson(Map<String, dynamic> jsonInput) =>
      _$CopyrightProfilesFromJson(jsonInput);
  Map<String, dynamic> toJson() => _$CopyrightProfilesToJson(this);

}

///
/// Helps us to manage copyright notices to be inserted into newly
/// created files or when updating the copyrights in files.
///
class CopyrightManager {
  final Logger logger = createLogger("CopyrightManager");
  CopyrightProfiles? _profiles;
  CopyrightManager._() {
    _readDefaultProfiles();
  }
  static final CopyrightManager current = CopyrightManager._();

  ///
  /// Read the default copyright profiles.
  ///
  void _readDefaultProfiles() {
    var file = PksConfiguration.singleton.findFile(PksConfiguration.copyrightProfilesFilename);
    if (file == null) {
      logger.w("No copyright profiles defined.");
      return;
    }
    logger.i("Reading copyright profiles from $file");
    var s = file.readAsStringSync();
    _profiles = CopyrightProfiles.fromJson(jsonDecode(s));
  }

  ///
  /// Returns the profile string to insert into a file depending
  /// on the [grammar] of the file.
  ///
  String getCopyrightFormatted(Grammar grammar) {
    var p = _profiles;
    if (p == null) {
      return "";
    }
    var profile = p.activeProfile;
    var options = p.forLanguage(grammar.scopeName);
    var result = StringBuffer();
    var cd = grammar.commentDescriptor;
    var singleLineComment = cd.commentSingle ?? "//";
    var linePrefix = options.singleLineComments ? "$singleLineComment " : (cd.commentStart?.length ?? 0) > 1 ? " ${cd.commentStart?[1]} " : "";
    if (options.addBlankLineBefore) {
      if (options.singleLineComments) {
        result.writeln(linePrefix);
      } else {
        result.writeln();
      }
    }
    if (!options.singleLineComments) {
      result.writeln(cd.commentStart);
    }
    result.write(linePrefix);
    for (int i = 0; i < profile.notice.length; i++) {
      var c = profile.notice[i];
      result.write(c);
      if (c == '\n' && i < profile.notice.length-1) {
        result.write(linePrefix);
      }
    }
    if (!options.singleLineComments) {
      if (linePrefix.isNotEmpty) {
        result.write(" ");
      }
      result.writeln(cd.commentEnd);
    }
    if (options.addBlankLineAfter) {
      if (options.singleLineComments) {
        result.writeln(linePrefix);
      } else {
        result.writeln();
      }
    }
    return result.toString();
  }
}
