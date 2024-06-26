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

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:jovial_svg/jovial_svg.dart';
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
    Widget Function(
        {required OpenFile currentFile,
        required FocusNode focusNode,
        required EditorBloc bloc});

Widget _handleDataSchemeUri(
    Uri uri, final double? width, final double? height) {
  final String mimeType = uri.data!.mimeType;
  if (mimeType.startsWith('image/')) {
    final bytes = uri.data!.contentAsBytes();
    if (_isSvg(bytes)) {
      return ScalableImageWidget.fromSISource(
          si: ScalableImageSource.fromSvgFile(url, () => utf8.decode(bytes)));
    }
    return Image.memory(
      bytes,
      width: width,
      height: height,
    );
  } else if (mimeType.startsWith('text/')) {
    final s = uri.data!.contentAsString();
    return Text(s);
  }
  return const SizedBox();
}

Future<Uint8List> _getContent(Uri url) async {
  final content = url.data?.contentAsBytes();
  if (content == null) {
    final client = http.Client();
    try {
      final response = await client.get(url);
      return response.bodyBytes;
    } finally {
      client.close();
    }
  }
  return content;
}

bool _isSvg(Uint8List data) {
  try {
    final s = utf8.decode(data);
    return s.contains("<svg");
  } catch(_) {
    return false;
  }
}
Widget _markdownImageBuilder(Uri uri, String? title, String? alt) {
  var uriString = uri.toString();
  final isSvg = uriString.contains(".svg");
  if (uri.scheme == 'http' || uri.scheme == 'https') {
    return FutureBuilder(future: _getContent(uri), builder: (context, snapshot) {
      final data = snapshot.data;
      if (data == null) {
        return const SizedBox();
      }
      if (_isSvg(data)) {
        return ScalableImageWidget.fromSISource(
            si: ScalableImageSource.fromSvgFile(url, () => utf8.decode(data)));
      }
      return Image.memory(data);
    });
  } else if (uri.scheme == 'data') {
    return _handleDataSchemeUri(uri, null, null);
  } else if (uri.scheme == 'resource') {
    if (isSvg) {
      return FutureBuilder(
          future: rootBundle.load(uri.path), builder: (context, snapshot) {
        var data = snapshot.data;
        if (data == null) {
          return const SizedBox();
        }
        return ScalableImageWidget.fromSISource(
            si: ScalableImageSource.fromSvgFile(url, () => utf8.decode(Uint8List.sublistView(data))));
      });
    }
    return Image.asset(uri.path);
  } else {
    final f = File.fromUri(uri);
    if (isSvg) {
      return ScalableImageWidget.fromSISource(
          si: ScalableImageSource.fromSvgFile(f, f.readAsStringSync));
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
    RendererType.markdown: (
            {required FocusNode focusNode,
            required OpenFile currentFile,
            required EditorBloc bloc}) =>
        SelectionArea(
            focusNode: focusNode,
            child: Markdown(
              data: currentFile.text,
              imageDirectory: File(currentFile.filename).parent.path,
              imageBuilder: _markdownImageBuilder,
              onTapLink: (String text, String? href, String title) {
                if (href != null) {
                  final uri = Uri.parse(href);
                  if (uri.scheme == 'http' || uri.scheme == 'https') {
                    launchUrl(uri);
                  } else {
                    var f = File(uri.path);
                    if (!f.isAbsolute) {
                      f = File(join(
                          File(currentFile.filename).parent.path, uri.path));
                    }
                    bloc.openFile(f.path);
                  }
                }
              },
            ))
  };

  Widget createWidget(RendererType rendererType, FocusNode focusNode,
      OpenFile file, EditorBloc bloc) {
    final r = _renderers[rendererType];
    return r == null
        ? TextField(
            controller: TextEditingController(text: file.text),
          )
        : r(focusNode: focusNode, bloc: bloc, currentFile: file);
  }
}
