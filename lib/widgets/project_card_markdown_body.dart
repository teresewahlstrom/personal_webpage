import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:tw_chat/chat.dart' show ChatSkin;
import 'package:tw_primitives/markdown.dart';
import 'package:tw_primitives/theme.dart';
import 'package:url_launcher/url_launcher.dart';

MarkdownSurfaceStyle _buildProjectCardMarkdownSurface(BuildContext context) {
  return buildMarkdownSurfaceStyle(
    MarkdownThemeConfig(
      isDark: ChatSkin.isDarkOf(context),
      textScale: MarkdownThemeConfig.bodyTextScaleOf(context),
    ),
  );
}

class ProjectCardMarkdownBody extends StatefulWidget {
  const ProjectCardMarkdownBody({
    super.key,
    required this.document,
    required this.selectable,
  });

  final MarkupDocument document;
  final bool selectable;

  @override
  State<ProjectCardMarkdownBody> createState() =>
      _ProjectCardMarkdownBodyState();
}

class _ProjectCardMarkdownBodyState extends State<ProjectCardMarkdownBody> {
  final Map<String, TapGestureRecognizer> _linkRecognizersByHref =
      <String, TapGestureRecognizer>{};

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

  @override
  Widget build(BuildContext context) {
    final MarkdownSurfaceStyle markdownSurface =
        _buildProjectCardMarkdownSurface(context);
    return Opacity(
      opacity: context.twColors.cardMarkdownOpacity,
      child: MarkupView(
        document: widget.document,
        theme: markdownSurface.theme,
        gestureRecognizerFactory: _recognizerForHref,
        textAlign: TextAlign.start,
        selectable: widget.selectable,
        chromeVisible: true,
      ),
    );
  }
}
