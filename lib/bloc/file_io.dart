//
// file_io.dart
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

import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:charset/charset.dart';
import 'dart:convert' as convert;

import 'package:re_editor/re_editor.dart';

///
/// The specifics about the encoding of a file.
///
class FileEncoding {
  final convert.Encoding encoding;
  final TextLineBreak lineBreak;
  final BomType bomType;
  FileEncoding({required this.encoding, required this.lineBreak, required this.bomType});
}

///
/// The Byte Order Mark, which was used during read / should be written for a file.
///
enum BomType {
  /// File has no BOM
  none([], convert.latin1),
  /// File has a UTF8 BOM
  utf8([0xEF, 0xBB, 0xBF], convert.utf8),
  /// File has a UTF16 Big Endian Architecture BOM
  utf16be([0xFE, 0xFF], utf16),
  /// File has a UTF32 Big Endian Architecture BOM
  utf32be([0, 0, 0xFE, 0xFF], utf32),
  /// File has a UTF16 Little Endian Architecture BOM
  utf16le([0xFF, 0xFE], utf16),
  /// File has a UTF32 Little Endian Architecture BOM
  utf32le([0xFF, 0xFE, 0, 0], utf32);
  ///
  /// The bytes representing the BomType
  ///
  final List<int> bytes;
  final convert.Encoding defaultEncoding;
  const BomType(this.bytes, this.defaultEncoding);
}

///
/// Utility class for detecting file encoding specifics and reading and writing files.
///
class FileIO {
  const FileIO();

  ({convert.Encoding encoding, TextLineBreak lineBreak, BomType bomType}) _parseBytesToDetectEncoding(List<int> pData) {
    var i = 0;
    final end = pData.length;
    int nLength;
    var lb = TextLineBreak.lf;
    convert.Encoding encoding = convert.latin1;
    var bomType = BomType.none;
    for (final t in BomType.values) {
      if (t.bytes.isNotEmpty && end > t.bytes.length && const ListEquality<int>().equals(t.bytes, pData.sublist(0, t.bytes.length))) {
        bomType = t;
        encoding = t.defaultEncoding;
        break;
      }
    }
    while (i < end) {
      int byte = pData[i++];
      if (byte == 13 && i < end && pData[i] == 10) {
        lb = TextLineBreak.crlf;
      }
      if (byte <= 0x7F || i >= end) {
        /* 1 byte sequence: U+0000..U+007F */
        continue;
      }
      if (0xC2 <= byte && byte <= 0xDF) {
        nLength = 1;
      } else if (0xE0 <= byte && byte <= 0xEF) {
        nLength = 2;
      } else if (0xF0 <= byte && byte <= 0xF4) {
        nLength = 3;
      } else {
        continue;
      }
      if (i + nLength >= end) {
        /* truncated string or invalid byte sequence */
        return (encoding: encoding, lineBreak: lb, bomType: bomType);
      }

      /* Check continuation bytes: bit 7 should be set, bit 6 should be unset (b10xxxxxx). */
      for (i = 0; i < nLength; i++) {
        if ((pData[i] & 0xC0) != 0x80) {
          return (encoding: encoding, lineBreak: lb, bomType: bomType);
        }
        if (nLength == 1) {
          return (encoding: convert.utf8, lineBreak: lb, bomType: bomType);
        } else if (nLength == 2) {
          /* 3 bytes sequence: U+0800..U+FFFF */
          int ch = ((pData[0] & 0x0f) << 12) + ((pData[1] & 0x3f) << 6) +
              (pData[2] & 0x3f);
          /* (0xff & 0x0f) << 12 | (0xff & 0x3f) << 6 | (0xff & 0x3f) = 0xffff, so ch <= 0xffff */
          if (ch < 0x0800) {
            return (encoding: encoding, lineBreak: lb, bomType: bomType);
          }
          /* surrogates (U+D800-U+DFFF) are invalid in UTF-8: test if (0xD800 <= ch && ch <= 0xDFFF) */
          if ((ch >> 11) == 0x1b) {
            return (encoding: encoding, lineBreak: lb, bomType: bomType);
          }
          return (encoding: convert.utf8, lineBreak: lb, bomType: bomType);
        } else if (nLength == 3) {
          /* 4 bytes sequence: U+10000..U+10FFFF */
          int ch = ((pData[0] & 0x07) << 18) + ((pData[1] & 0x3f) << 12) +
              ((pData[2] & 0x3f) << 6) + (pData[3] & 0x3f);
          if ((ch < 0x10000) || (0x10FFFF < ch)) {
            return (encoding: encoding, lineBreak: lb, bomType: bomType);
          }
          return (encoding: convert.utf8, lineBreak: lb, bomType: bomType);
        }
        i += nLength;
      }
    }
    return (encoding: encoding, lineBreak: lb, bomType: bomType);
  }


  ///
  /// Utility which can be used to detect the details about how a file is encoded.
  ///
  Future<FileEncoding> detectEncoding(File file) async {
    final size = min(4096, await file.length());
    final tester = file.openRead(0, size);
    var result = _parseBytesToDetectEncoding(await tester.first);
    return FileEncoding(encoding: result.encoding, lineBreak: result.lineBreak, bomType: result.bomType);
  }

  ///
  /// Read the contents of a file as a string to be edited in PKS Edit.
  ///
  String readContents(File file, FileEncoding encodingDetails) {
    if (encodingDetails.bomType != BomType.none) {
      var bytes = file.readAsBytesSync();
      return encodingDetails.encoding.decode(bytes.sublist(encodingDetails.bomType.bytes.length));
    }
    return file.readAsStringSync(encoding: encodingDetails.encoding);
  }


}
