import 'package:flutter/material.dart';

import 'embed.dart';

class NewsletterModalContent extends StatelessWidget {
  const NewsletterModalContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Widget centeredEmbed = Center(child: buildNewsletterEmbed());

          return SingleChildScrollView(
            primary: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: centeredEmbed,
              ),
            ),
          );
        },
      ),
    );
  }
}
