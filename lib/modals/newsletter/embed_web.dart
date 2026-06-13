import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'embed_config.dart';

const String _newsletterViewType = "newsletter-sibform-iframe";
bool _registeredViewFactory = false;

void _registerViewFactoryIfNeeded() {
  if (_registeredViewFactory) {
    return;
  }

  ui_web.platformViewRegistry.registerViewFactory(_newsletterViewType, (
    int viewId,
  ) {
    final web.HTMLIFrameElement iframe = web.HTMLIFrameElement()
      ..src =
          "https://sibforms.com/serve/MUIFALacijj-Gm_7_5NdvnOGr3ECgmv2aMTsHl6lF7cGsIwdtxewz1YRowtenm7DKATFzm-OEC3Vi8ULPriXsjl9DNNIY3uAxR4hkKDKk2RagWMLodj1FHTbVlWVRMx9W8QGdodlpNJvk4tnxWLXpfVhpqQf6M-7RZEIJoDb9KKFkPGHzsROhNdcRF6EF728A01BtHw_TsBN3MG2"
      ..style.border = "0"
      ..width = newsletterEmbedWidth.toStringAsFixed(0)
      ..height = newsletterEmbedHeight.toStringAsFixed(0)
      ..setAttribute("allow", "fullscreen");

    return iframe;
  });

  _registeredViewFactory = true;
}

Widget buildNewsletterEmbed() {
  _registerViewFactoryIfNeeded();

  return const SizedBox(
    width: newsletterEmbedWidth,
    height: newsletterEmbedHeight,
    child: HtmlElementView(viewType: _newsletterViewType),
  );
}
