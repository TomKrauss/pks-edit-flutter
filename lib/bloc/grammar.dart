//
// grammar.dart
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

/// Describes the primary ways to comment code in the described language
class CommentDescriptor {
  final String commentStart;		// This contains the 0-terminated string to start a comment - e.g. "/*"
  final String commentEnd;		  // If only a block line comment feature is available, this contains the 0-terminated string to end it - e.g. "*/"
  final String? comment2Start;	// This may contain an alternate 0-terminated string to start a comment - e.g. "/*"
  final String? comment2End;		// If only a block line comment feature is available, this an alternate 0-terminated string to end it - e.g. "*/"
  final String commentSingle;

  CommentDescriptor({required this.commentStart, required this.commentEnd,
    this.comment2Start, this.comment2End, required this.commentSingle});		// This contains the 0-terminated string to start a single line comment - e.g. "//"
}

///
/// Describes the grammar of a source file edited.
///
class Grammar {
  final String scopeName;
  final CommentDescriptor commentDescriptor;

  Grammar({required this.scopeName, required this.commentDescriptor});
}
