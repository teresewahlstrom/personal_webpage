import 'package:flutter/material.dart';

import '../../config/app_ui_config.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    this.logoAssetPath = 'assets/images/logo.png',
  });

  final String logoAssetPath;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final AppLineStyle headerLine = ShellUiConfig.headerBorderFor(brightness);
    return SizedBox(
      width: double.infinity,
      height: ShellUiConfig.headerMinHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ShellUiConfig.headerBackgroundFor(brightness),
          border: Border(
            bottom: headerLine.borderSide,
          ),
        ),
        child: Padding(
          padding: ShellUiConfig.headerPadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ShellUiConfig.headerMaxWidth,
              ),
              child: Row(
                children: <Widget>[
                  RepaintBoundary(
                    child: SizedBox(
                      width: ShellUiConfig.headerLogoWidth,
                      height: ShellUiConfig.headerLogoHeight,
                      child: Image.asset(
                        logoAssetPath,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                        isAntiAlias: true,
                        filterQuality: FilterQuality.high,
                      ),
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
