// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

const String _newsletterViewType = "newsletter-sibform-iframe";
bool _registeredViewFactory = false;

void _registerViewFactoryIfNeeded() {
  if (_registeredViewFactory) {
    return;
  }

  ui_web.platformViewRegistry.registerViewFactory(_newsletterViewType, (
    int viewId,
  ) {
    final html.IFrameElement iframe = html.IFrameElement()
      ..src =
          "https://sibforms.com/serve/MUIFALacijj-Gm_7_5NdvnOGr3ECgmv2aMTsHl6lF7cGsIwdtxewz1YRowtenm7DKATFzm-OEC3Vi8ULPriXsjl9DNNIY3uAxR4hkKDKk2RagWMLodj1FHTbVlWVRMx9W8QGdodlpNJvk4tnxWLXpfVhpqQf6M-7RZEIJoDb9KKFkPGHzsROhNdcRF6EF728A01BtHw_TsBN3MG2"
      ..style.border = "0"
      ..width = "540"
      ..height = "590"
      ..setAttribute("allow", "fullscreen");

    return iframe;
  });

  _registeredViewFactory = true;
}

Widget buildNewsletterEmbed() {
  _registerViewFactoryIfNeeded();

  return const SizedBox(
    width: 540,
    height: 590,
    child: HtmlElementView(viewType: _newsletterViewType),
  );
}
