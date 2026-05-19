import 'package:flutter/material.dart';

import '../../config/app_color_theme.dart';

import 'embed_config.dart';

Widget buildNewsletterEmbed() {
  return Builder(
    builder: (BuildContext context) {
      final brightness = Theme.of(context).brightness;

      return SizedBox(
        width: newsletterEmbedWidth,
        height: newsletterEmbedHeight,
        child: ColoredBox(
          key: const ValueKey<String>('newsletter-embed-stub'),
          color: AppColorTheme.modalBackgroundFor(brightness),
        ),
      );
    },
  );
}
