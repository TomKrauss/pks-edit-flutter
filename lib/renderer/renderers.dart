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


import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
  /// A renderer widget displaying the [data] passed in in a preview like way (e.g. preview
  /// of HTML or Markdown). Data can either be a string in the case of an HTML or markdown
  /// document or a List<int> in case of binary data to render such as an image.
  ///
  Widget Function({dynamic data});

///
/// Factory class responsible for creating the widgets to render documents in preview / wysiwyg mode.
///
class Renderers {
  Renderers._();
  static final Renderers singleton = Renderers._();
  final Map<RendererType, Renderer> _renderers = {
    RendererType.markdown: ({dynamic data}) => Markdown(data: data)
  };

  Widget createWidget(RendererType rendererType, dynamic data) {
    final r = _renderers[rendererType];
    return r == null ? TextField(controller: TextEditingController(text: data),) : r(data: data);
  }
}
