import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';

import 'tw_svg_asset_stub.dart'
    if (dart.library.html) 'tw_svg_asset_web.dart' as impl;

const Duration kTwSvgAssetPrecacheTimeout = Duration(seconds: 3);

Future<void> precacheTwSvgAsset(
  String assetName, {
  String? package,
  Duration timeout = kTwSvgAssetPrecacheTimeout,
}) {
  return rootBundle
      .loadString(_bundleAssetKey(assetName, package))
      .then((_) {})
      .timeout(timeout, onTimeout: () {});
}

class TwSvgAsset extends StatelessWidget {
  const TwSvgAsset(
    this.assetName, {
    super.key,
    this.package,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
  });

  final String assetName;
  final String? package;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return impl.buildTwSvgAsset(
      assetName: assetName,
      package: package,
      width: width,
      height: height,
      fit: fit,
      color: color,
    );
  }
}

String _bundleAssetKey(String assetName, String? package) {
  return package == null ? assetName : 'packages/$package/$assetName';
}