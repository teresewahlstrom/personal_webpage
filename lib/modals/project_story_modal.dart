import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SelectedContent;
import 'package:tw_primitives/markdown.dart';
import 'package:tw_primitives/scrollbar.dart' show TwSelectableRegionState;
import 'package:tw_primitives/theme.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_ui_config.dart';
import '../widgets/selection_copy_interceptor.dart';

class ProjectStoryModalContent extends StatefulWidget {
  const ProjectStoryModalContent({
    super.key,
    required this.contentDocument,
    this.overlapHeaderTopInset = ModalUiConfig.headerHeight,
  });

  final MarkupDocument contentDocument;
  final double overlapHeaderTopInset;

  @override
  State<ProjectStoryModalContent> createState() =>
      _ProjectStoryModalContentState();
}

class _ProjectStoryModalContentState extends State<ProjectStoryModalContent> {
  final Map<String, TapGestureRecognizer> _linkRecognizersByHref =
      <String, TapGestureRecognizer>{};

  final GlobalKey<TwSelectableRegionState> _selectionKey =
      GlobalKey<TwSelectableRegionState>();

  @override
  void dispose() {
    for (final TapGestureRecognizer recognizer
        in _linkRecognizersByHref.values) {
      recognizer.dispose();
    }
    _linkRecognizersByHref.clear();
    super.dispose();
  }

  Future<void> _openHref(String href) async {
    final String normalizedHref =
        href.startsWith('http://') ||
            href.startsWith('https://') ||
            href.startsWith('mailto:') ||
            href.startsWith('tel:')
        ? href
        : 'https://$href';
    final Uri uri = Uri.parse(normalizedHref);
    try {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open $href')));
    }
  }

  TapGestureRecognizer _recognizerForHref(String href) {
    return _linkRecognizersByHref.putIfAbsent(href, () {
      final TapGestureRecognizer recognizer = TapGestureRecognizer();
      recognizer.onTap = () {
        _openHref(href);
      };
      return recognizer;
    });
  }

  MarkdownSurfaceStyle _buildSurface(BuildContext context) {
    return buildMarkdownSurfaceStyle(
      MarkdownThemeConfig(
        isDark: context.twIsDark,
        textScale: MarkdownThemeConfig.bodyTextScaleOf(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MarkdownSurfaceStyle markdownSurface = _buildSurface(context);
    return SelectionCopyInterceptor(
      builder: (BuildContext context, ValueChanged<SelectedContent?> onSelectionChanged) {
        return SafeArea(
          top: false,
          bottom: false,
          child: TwPanelScrollArea(
            selectable: true,
            selectionKey: _selectionKey,
            overlapHeaderTopInset: widget.overlapHeaderTopInset,
            onSelectionChanged: onSelectionChanged,
            child: MarkupView(
              document: widget.contentDocument,
              theme: markdownSurface.theme,
              gestureRecognizerFactory: _recognizerForHref,
              textAlign: TextAlign.start,
              selectable: true,
              chromeVisible: true,
            ),
          ),
        );
      },
    );
  }
}
