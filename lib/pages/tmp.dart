// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

const String _textareaViewType = 'tmp-native-textarea';
bool _registeredTextareaFactory = false;

void _registerTextareaFactoryIfNeeded() {
  if (_registeredTextareaFactory) return;

  ui_web.platformViewRegistry.registerViewFactory(_textareaViewType, (
    int viewId,
  ) {
    return html.TextAreaElement()
      ..autofocus = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none'
      ..style.outline = 'none'
      ..style.resize = 'none'
      ..style.padding = '0'
      ..style.margin = '0'
      ..style.boxSizing = 'border-box'
      ..style.fontFamily = 'inherit'
      ..style.fontSize = 'inherit'
      ..style.background = 'transparent';
  });

  _registeredTextareaFactory = true;
}

class TmpPage extends StatelessWidget {
  const TmpPage({super.key});

  @override
  Widget build(BuildContext context) {
    _registerTextareaFactoryIfNeeded();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: HtmlElementView(viewType: _textareaViewType),
      ),
    );
  }
}
