import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget buildTwSvgAsset({
  required String assetName,
  required String? package,
  required double? width,
  required double? height,
  required BoxFit fit,
  required Color? color,
}) {
  return SvgPicture.asset(
    assetName,
    package: package,
    width: width,
    height: height,
    fit: fit,
    colorFilter:
        color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
  );
}