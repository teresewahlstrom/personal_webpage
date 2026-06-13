import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

final Map<String, Future<String>> _svgMarkupCache = <String, Future<String>>{};

Widget buildTwSvgAsset({
  required String assetName,
  required String? package,
  required double? width,
  required double? height,
  required BoxFit fit,
  required Color? color,
}) {
  final Widget htmlElementView = color == null
      ? _buildNativeImageView(
          imageUrl: _resolveAssetUrl(assetName, package),
          fit: fit,
        )
      : FutureBuilder<String>(
          future: _buildTintedDataUrl(
            assetName: assetName,
            package: package,
            color: color,
          ),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasError) {
              return _buildNativeImageView(
                imageUrl: _resolveAssetUrl(assetName, package),
                fit: fit,
              );
            }

            final String? imageUrl = snapshot.data;
            if (imageUrl == null) {
              return const SizedBox.expand();
            }

            return _buildNativeImageView(imageUrl: imageUrl, fit: fit);
          },
        );

  if (width == null && height == null) {
    return htmlElementView;
  }

  return SizedBox(width: width, height: height, child: htmlElementView);
}

Widget _buildNativeImageView({
  required String imageUrl,
  required BoxFit fit,
}) {
  return HtmlElementView.fromTagName(
    key: ValueKey<String>('${fit.name}::$imageUrl'),
    tagName: 'img',
    onElementCreated: (Object element) {
      final web.HTMLImageElement image = element as web.HTMLImageElement;
      image.src = imageUrl;
      image.alt = '';
      image.draggable = false;
      image.style.width = '100%';
      image.style.height = '100%';
      image.style.display = 'block';
      image.style.pointerEvents = 'none';
      image.style.objectFit = _cssObjectFitForFit(fit);
    },
  );
}

Future<String> _buildTintedDataUrl({
  required String assetName,
  required String? package,
  required Color color,
}) async {
  final String bundleKey = _bundleAssetKey(assetName, package);
  final Future<String> rawSvgFuture = _svgMarkupCache.putIfAbsent(
    bundleKey,
    () => rootBundle.loadString(bundleKey),
  );
  final String rawSvg = await rawSvgFuture;
  final String tintedSvg = _tintSvgMarkup(rawSvg, color);
  return Uri.dataFromString(
    tintedSvg,
    mimeType: 'image/svg+xml',
    encoding: utf8,
  ).toString();
}

String _bundleAssetKey(String assetName, String? package) {
  return package == null ? assetName : 'packages/$package/$assetName';
}

String _resolveAssetUrl(String assetName, String? package) {
  return Uri.base.resolve(_bundleAssetKey(assetName, package)).toString();
}

String _cssObjectFitForFit(BoxFit fit) {
  return switch (fit) {
    BoxFit.contain => 'contain',
    BoxFit.cover => 'cover',
    BoxFit.fill => 'fill',
    BoxFit.fitHeight => 'contain',
    BoxFit.fitWidth => 'contain',
    BoxFit.none => 'none',
    BoxFit.scaleDown => 'scale-down',
  };
}

String _tintSvgMarkup(String rawSvg, Color color) {
  final String fillColor = _svgPaintColor(color);
  String svg = rawSvg
      .replaceFirst(RegExp(r'<\?xml[^>]*\?>\s*', multiLine: true), '')
      .replaceFirst(RegExp(r'<!DOCTYPE[^>]*>\s*', caseSensitive: false), '');

  svg = svg.replaceAllMapped(
    RegExp(r'\b(fill|stroke)="([^"]*)"', caseSensitive: false),
    (Match match) {
      final String paint = (match.group(2) ?? '').toLowerCase();
      if (paint == 'none') {
        return match.group(0)!;
      }
      return '${match.group(1)}="$fillColor"';
    },
  );

  return svg;
}

String _svgPaintColor(Color color) {
  final int argb = color.toARGB32();
  final int red = (argb >> 16) & 0xFF;
  final int green = (argb >> 8) & 0xFF;
  final int blue = argb & 0xFF;
  final double alpha = ((argb >> 24) & 0xFF) / 255.0;
  return 'rgba($red, $green, $blue, ${alpha.toStringAsFixed(3)})';
}