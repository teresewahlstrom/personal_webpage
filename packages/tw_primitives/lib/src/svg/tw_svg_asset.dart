import 'package:flutter/widgets.dart';

import 'tw_svg_asset_stub.dart'
    if (dart.library.html) 'tw_svg_asset_web.dart' as impl;

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