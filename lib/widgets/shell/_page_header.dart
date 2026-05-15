import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_ui_config.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    this.logoAssetPath = 'assets/images/logo.png',
  });

  final String logoAssetPath;

  Future<void> _launchUrl(BuildContext context) async {
    final Uri uri = Uri.parse('https://www.t1grid.com');
    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open https://www.t1grid.com'),
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open https://www.t1grid.com'),
        ),
      );
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
              SelectionContainer.disabled(
                child: Semantics(
                  button: true,
                  label: 'Open t1grid.com home page',
                  child: Tooltip(
                    message: 'Open t1grid.com home page',
                    child: GestureDetector(
                      onTap: () => _launchUrl(context),
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

