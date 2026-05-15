import 'package:flutter/material.dart';
import 'package:tw_primitives/scrollbar.dart' show TwScrollArea;

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

          return TwScrollArea.scrollView(
            thumbVisibility: false,
            primary: true,
            child: TwScrollArea.scrollView(
              scrollDirection: Axis.horizontal,
              thumbVisibility: false,
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
