import 'package:flutter/widgets.dart';

import 'embed_config.dart';

Widget buildNewsletterEmbed() {
  return const SizedBox(
    width: newsletterEmbedWidth,
    height: newsletterEmbedHeight,
    child: ColoredBox(
      key: ValueKey<String>('newsletter-embed-stub'),
      color: Color(0xFFEFEFEF),
    ),
  );
}
