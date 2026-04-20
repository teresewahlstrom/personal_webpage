import 'package:flutter/widgets.dart';

import 'embed_stub.dart'
    if (dart.library.html) 'embed_web.dart' as impl;

Widget buildNewsletterEmbed() => impl.buildNewsletterEmbed();
