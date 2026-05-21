import 'package:flutter/material.dart';

import 'markup_ast.dart';
import 'markup_rendering.dart';
import 'markup_view_renderer.dart';

class MarkupView extends StatelessWidget {
  const MarkupView({
    super.key,
    required this.document,
    required this.theme,
    required this.gestureRecognizerFactory,
    this.selectable = true,
    this.chromeVisible = true,
    this.blockquoteRailColor,
    this.textAlign = TextAlign.start,
  });

  final MarkupDocument document;
  final MarkupTheme theme;
  final LinkGestureRecognizerFactory gestureRecognizerFactory;
  final bool selectable;
  final bool chromeVisible;
  final Color? blockquoteRailColor;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return MarkupViewRenderer(
      context: context,
      document: document,
      theme: theme,
      gestureRecognizerFactory: gestureRecognizerFactory,
      selectable: selectable,
      chromeVisible: chromeVisible,
      blockquoteRailColor: blockquoteRailColor,
      textAlign: textAlign,
    ).build();
  }
}
