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
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: ShellUiConfig.headerMinHeight,
      ),
      padding: ShellUiConfig.headerPadding,
      decoration: BoxDecoration(
        color: ShellUiConfig.headerBackgroundFor(brightness),
        border: Border(
          bottom: headerLine.borderSide,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: ShellUiConfig.headerMaxWidth,
          ),
          child: Row(
            children: <Widget>[
              Image.asset(
                logoAssetPath,
                width: ShellUiConfig.headerLogoWidth,
                height: ShellUiConfig.headerLogoHeight,
                fit: BoxFit.contain,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
