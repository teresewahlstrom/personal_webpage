import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tw_primitives/theme.dart' show TwPanelScrollArea;

import 'embed.dart';
import 'embed_config.dart';

class NewsletterModalContent extends StatelessWidget {
  const NewsletterModalContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return TwPanelScrollArea(
            selectable: true,
            scrollbarColumnWidth: 0.0,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Center(
                child: _ResponsiveNewsletterEmbed(
                  maxWidth: constraints.maxWidth,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ResponsiveNewsletterEmbed extends StatelessWidget {
  const _ResponsiveNewsletterEmbed({required this.maxWidth});

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final safeMaxWidth = maxWidth.isFinite ? maxWidth : newsletterEmbedWidth;
    final availableWidth = math.max(0.0, safeMaxWidth);
    final scale = availableWidth <= 0
        ? 1.0
        : math.min(1.0, availableWidth / newsletterEmbedWidth);
    final scaledSize = Size(
      newsletterEmbedWidth * scale,
      newsletterEmbedHeight * scale,
    );

    return SizedBox(
      width: availableWidth > 0 ? availableWidth : newsletterEmbedWidth,
      child: Center(
        child: SizedBox(
          key: const ValueKey<String>('newsletter-embed-frame'),
          width: scaledSize.width,
          height: scaledSize.height,
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
            child: SizedBox.fromSize(
              size: newsletterEmbedSize,
              child: buildNewsletterEmbed(),
            ),
          ),
        ),
      ),
    );
  }
}
