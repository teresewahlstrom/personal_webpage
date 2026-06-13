import 'package:flutter/material.dart';

import 'package:tw_primitives/theme.dart';

import 'embed_config.dart';

Widget buildNewsletterEmbed() {
  return Builder(
    builder: (BuildContext context) {
      return SizedBox(
        width: newsletterEmbedWidth,
        height: newsletterEmbedHeight,
        child: ColoredBox(
          key: const ValueKey<String>('newsletter-embed-stub'),
          color: context.twColors.modalBackground,
        ),
      );
    },
  );
}
