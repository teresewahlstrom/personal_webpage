import 'package:flutter/material.dart';

import '../../config/app_ui_config.dart';

Widget buildNewsletterEmbed() {
  return SizedBox(
    width: 540,
    child: Text(
      "Newsletter embed is available on Flutter Web.",
      style: TextStyle(color: AppColorTheme.newsletterEmbedText),
    ),
  );
}
