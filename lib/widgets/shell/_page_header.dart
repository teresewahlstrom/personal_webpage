import 'package:flutter/material.dart';

import '../../config/app_ui_config.dart';
import 'header_logo_asset.dart';

class PageHeader extends StatefulWidget {
  const PageHeader({super.key, this.logoAssetPath = kHeaderLogoAssetPath});

  final String logoAssetPath;

  @override
  State<PageHeader> createState() => _PageHeaderState();
}

class _PageHeaderState extends State<PageHeader> {
  late final AssetImage _logoImage;

  @override
  void initState() {
    super.initState();
    _logoImage = widget.logoAssetPath == kHeaderLogoAssetPath
        ? kHeaderLogoImage
        : AssetImage(widget.logoAssetPath);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(_logoImage, context);
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final AppLineStyle headerLine = ShellUiConfig.headerBorderFor(brightness);
    final EdgeInsets safeInsets = MediaQuery.viewPaddingOf(context);
    final EdgeInsets contentPadding = ShellUiConfig.headerPadding.add(
      EdgeInsets.only(
        top: safeInsets.top,
        left: safeInsets.left,
        right: safeInsets.right,
      ),
    );
    return SizedBox(
      width: double.infinity,
      height: ShellUiConfig.headerMinHeight + safeInsets.top,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ShellUiConfig.headerBackgroundFor(brightness),
          border: Border(bottom: headerLine.borderSide),
        ),
        child: Padding(
          padding: contentPadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ShellUiConfig.headerMaxWidth,
              ),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: ShellUiConfig.headerLogoWidth,
                    height: ShellUiConfig.headerLogoHeight,
                    child: Image(
                      image: _logoImage,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
