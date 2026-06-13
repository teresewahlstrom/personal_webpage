import 'package:flutter/material.dart' hide SelectionListener, SelectionListenerNotifier;

import '../../scrollbar.dart' show SelectionListener;
import 'copy/markup_selection_registry.dart';
import 'markup_ast.dart';
import 'markup_rendering.dart';
import 'markup_view_renderer.dart';

class MarkupView extends StatefulWidget {
  const MarkupView({
    super.key,
    required this.document,
    required this.theme,
    required this.gestureRecognizerFactory,
    this.selectable = true,
    this.chromeVisible = true,
    this.textAlign = TextAlign.start,
    this.title,
  });

  final MarkupDocument document;
  final MarkupTheme theme;
  final LinkGestureRecognizerFactory gestureRecognizerFactory;
  final bool selectable;
  final bool chromeVisible;
  final TextAlign textAlign;
  final String? title;

  @override
  State<MarkupView> createState() => _MarkupViewState();
}

class _MarkupViewState extends State<MarkupView> {
  final Object _stateKey = Object();
  MarkupSelectionRegistry? _registeredRegistry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.selectable) {
      _unregister();
      return;
    }
    final registry = MarkupSelectionRegistry.maybeOf(context);
    if (registry != _registeredRegistry) {
      _unregister();
      registry?.copyHelper.registerDocument(_stateKey, widget.document, title: widget.title);
      _registeredRegistry = registry;
    }
  }

  @override
  void didUpdateWidget(covariant MarkupView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectable) {
      final registry = MarkupSelectionRegistry.maybeOf(context);
      if (registry != _registeredRegistry ||
          !oldWidget.selectable ||
          widget.document != oldWidget.document ||
          widget.title != oldWidget.title) {
        _unregister();
        registry?.copyHelper.registerDocument(_stateKey, widget.document, title: widget.title);
        _registeredRegistry = registry;
      }
    } else {
      _unregister();
    }
  }

  @override
  void dispose() {
    _unregister();
    super.dispose();
  }

  void _unregister() {
    _registeredRegistry?.copyHelper.unregisterDocument(_stateKey);
    _registeredRegistry = null;
  }

  @override
  Widget build(BuildContext context) {
    final registry = _registeredRegistry;
    if (widget.selectable && registry != null) {
      final notifier = registry.copyHelper.notifierFor(_stateKey);
      return SelectionListener(
        selectionNotifier: notifier,
        child: Builder(
          builder: (BuildContext context) {
            return MarkupViewRenderer(
              context: context,
              document: widget.document,
              theme: widget.theme,
              gestureRecognizerFactory: widget.gestureRecognizerFactory,
              selectable: widget.selectable,
              chromeVisible: widget.chromeVisible,
              textAlign: widget.textAlign,
            ).build();
          },
        ),
      );
    }

    return MarkupViewRenderer(
      context: context,
      document: widget.document,
      theme: widget.theme,
      gestureRecognizerFactory: widget.gestureRecognizerFactory,
      selectable: widget.selectable,
      chromeVisible: widget.chromeVisible,
      textAlign: widget.textAlign,
    ).build();
  }
}
