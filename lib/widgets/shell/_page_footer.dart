import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_ui_config.dart';
import '../../modals/privacy_cookies_modal.dart';
import '../app_modal.dart';

class PageFooter extends StatelessWidget {
  const PageFooter({
    super.key,
    required this.brandName,
    required this.privacyLabel,
  });

  final String brandName;
  final String privacyLabel;

  @override
  Widget build(BuildContext context) {
    final int year = DateTime.now().year;
    final Brightness brightness = Theme.of(context).brightness;
    final AppLineStyle footerLine = ShellUiConfig.footerBorderFor(brightness);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: ShellUiConfig.footerMinHeight,
      ),
      padding: ShellUiConfig.footerPadding,
      decoration: BoxDecoration(
        color: ShellUiConfig.footerBackgroundFor(brightness),
        border: Border(
          top: footerLine.borderSide,
        ),
      ),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 2,
          children: <Widget>[
            Text(
              '\u00A9$year $brandName. All rights reserved.',
              style: TextStyle(
                fontFamily: 'Inter18pt',
                fontWeight: FontWeight.w300,
                fontSize: 16,
                color: ShellUiConfig.footerTextFor(brightness),
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
            ),
            _LinkTextButton(
              label: privacyLabel,
              onTap: () => _openBuiltInPrivacyModal(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String rawUrl) async {
    final Uri uri = Uri.parse(rawUrl);
    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $rawUrl')),
        );
      }
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $rawUrl')),
      );
    }
  }

  void _openBuiltInPrivacyModal(BuildContext context) {
    showAppModal(
      context: context,
      headerTitle: 'Privacy & Cookies',
      builder: (BuildContext context, VoidCallback close) {
        return PrivacyCookiesContent(
          onLaunchUrl: (String url) => _launchUrl(context, url),
        );
      },
    );
  }
}

class _LinkTextButton extends StatelessWidget {
  const _LinkTextButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return TextButton(
      onPressed: onTap,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: WidgetStateProperty.all(Size.zero),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return AppColorTheme.transparent;
            }
            return null;
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return ShellUiConfig.linkTextHoverFor(brightness);
            }
            return ShellUiConfig.linkTextFor(brightness);
          },
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter18pt',
          fontWeight: FontWeight.w300,
          fontSize: 16,
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.solid,
          decorationColor: ShellUiConfig.linkTextFor(brightness),
          decorationThickness: 1.0,
        ),
      ),
    );
  }
}
