//
// renderers.dart
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

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart';
import 'package:pks_edit_flutter/bloc/editor_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

///
/// The types of renderers supported.
///
enum RendererType {
  none,
  markdown,
  image(dataType: List<int>);
  final Type dataType;
  const RendererType({this.dataType = String});
}

///
/// Delegate to implement to create widgets based on a type of data to display.
///
typedef Renderer =
  ///
  /// A renderer widget displaying the contents of [currentFile] passed in in a preview like way (e.g. preview
  /// of HTML or Markdown). The rendered is responsible for rendering the data of te current file, which can either be a string in the case of an HTML or markdown
  /// document or a List<int> in case of binary data to render such as an image.
  ///
  Widget Function({required OpenFile currentFile, required FocusNode focusNode, required EditorBloc bloc});

Widget _handleDataSchemeUri(
    Uri uri, final double? width, final double? height) {
  final String mimeType = uri.data!.mimeType;
  if (mimeType.startsWith('image/')) {
    return Image.memory(
      uri.data!.contentAsBytes(),
      width: width,
      height: height,
    );
  } else if (mimeType.startsWith('text/')) {
    return Text(uri.data!.contentAsString());
  }
  return const SizedBox();
}

Widget _markdownImageBuilder(
    Uri uri,
    String? title,
    String? alt) {
  var uriString = uri.toString();
  final isSvg = uriString.contains(".svg");
  if (uri.scheme == 'http' || uri.scheme == 'https') {
    // todo: should parse network bytes to determine image type.
    if (isSvg) {
      return SvgPicture.network(uriString);
    }
    return Image.network(uriString);
  } else if (uri.scheme == 'data') {
    return _handleDataSchemeUri(uri, null, null);
  } else if (uri.scheme == 'resource') {
    if (isSvg) {
      return SvgPicture.asset(uri.path);
    }
    return Image.asset(uri.path);
  } else {
    final f = File.fromUri(uri);
    if (isSvg) {
      return SvgPicture.file(f);
    }
    return Image.file(f);
  }
}

///
/// Factory class responsible for creating the widgets to render documents in preview / wysiwyg mode.
///
class Renderers {
  Renderers._();
  static final Renderers singleton = Renderers._();
  final Map<RendererType, Renderer> _renderers = {
    RendererType.markdown: ({required FocusNode focusNode, required OpenFile currentFile, required EditorBloc bloc}) => SelectionArea(focusNode: focusNode,
        child: Markdown(data: currentFile.text,
          imageDirectory: File(currentFile.filename).parent.path,
          imageBuilder: _markdownImageBuilder, onTapLink: (String text, String? href, String title) {
          if (href != null) {
            final uri = Uri.parse(href);
            if (uri.scheme == 'http' || uri.scheme == 'https') {
              launchUrl(uri);
            } else {
              var f = File(uri.path);
              if (!f.isAbsolute) {
                f = File(join(File(currentFile.filename).parent.path, uri.path));
              }
              bloc.openFile(f.path);
            }
          }
        },))
  };

  Widget createWidget(RendererType rendererType, FocusNode focusNode, OpenFile file, EditorBloc bloc) {
    final r = _renderers[rendererType];
    return r == null ? TextField(controller: TextEditingController(text: file.text),) : r(focusNode: focusNode, bloc: bloc, currentFile: file);
  }
}
