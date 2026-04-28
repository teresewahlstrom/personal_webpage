import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_ui_config.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    this.logoAssetPath = 'assets/images/logo.png',
  });

  final String logoAssetPath;

  Future<void> _launchUrl() async {
    final Uri uri = Uri.parse('https://www.t1grid.com');
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.platformDefault,
    );
    if (!launched) {
      throw 'Could not launch https://www.t1grid.com';
    }
  }

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
              GestureDetector(
                onTap: _launchUrl,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Image.asset(
                    logoAssetPath,
                    width: ShellUiConfig.headerLogoWidth,
                    height: ShellUiConfig.headerLogoHeight,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
