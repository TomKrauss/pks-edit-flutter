// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'copyright.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LanguageOption _$LanguageOptionFromJson(Map<String, dynamic> json) =>
    LanguageOption(
      singleLineComments: json['single-line-comments'] as bool? ?? false,
      addBlankLineBefore: json['add-blank-line-before'] as bool? ?? false,
      addBlankLineAfter: json['add-blank-line-after'] as bool? ?? false,
      language: json['language'] as String,
    );

Map<String, dynamic> _$LanguageOptionToJson(LanguageOption instance) =>
    <String, dynamic>{
      'single-line-comments': instance.singleLineComments,
      'add-blank-line-before': instance.addBlankLineBefore,
      'add-blank-line-after': instance.addBlankLineAfter,
      'language': instance.language,
    };

CopyrightProfile _$CopyrightProfileFromJson(Map<String, dynamic> json) =>
    CopyrightProfile(
      name: json['name'] as String,
      notice: json['notice'] as String,
    );

Map<String, dynamic> _$CopyrightProfileToJson(CopyrightProfile instance) =>
    <String, dynamic>{
      'name': instance.name,
      'notice': instance.notice,
    };

CopyrightProfiles _$CopyrightProfilesFromJson(Map<String, dynamic> json) =>
    CopyrightProfiles(
      currentProfile: json['default'] as String?,
      profiles: (json['profiles'] as List<dynamic>)
          .map((e) => CopyrightProfile.fromJson(e as Map<String, dynamic>))
          .toList(),
      languageOptions: (json['language-options'] as List<dynamic>?)
              ?.map((e) => LanguageOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CopyrightProfilesToJson(CopyrightProfiles instance) =>
    <String, dynamic>{
      'default': instance.currentProfile,
      'profiles': instance.profiles,
      'language-options': instance.languageOptions,
    };
