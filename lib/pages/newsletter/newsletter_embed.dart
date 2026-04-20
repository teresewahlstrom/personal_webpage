import 'package:flutter/widgets.dart';

import 'newsletter_embed_stub.dart'
    if (dart.library.html) 'newsletter_embed_web.dart' as impl;

Widget buildNewsletterEmbed() => impl.buildNewsletterEmbed();
