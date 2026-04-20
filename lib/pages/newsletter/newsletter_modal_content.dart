import 'package:flutter/material.dart';

import 'newsletter_embed.dart';

class NewsletterModalContent extends StatelessWidget {
  const NewsletterModalContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      primary: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: buildNewsletterEmbed(),
      ),
    );
  }
}
