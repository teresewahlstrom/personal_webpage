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
    final TextStyle buildStampStyle = TextStyle(
      fontFamily: 'Inter18pt',
      fontWeight: FontWeight.w300,
      fontSize: 11,
      height: 1.2,
      color: ShellUiConfig.footerTextFor(brightness).withValues(alpha: 0.72),
      decoration: TextDecoration.none,
    );

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Wrap(
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
                    fontSize: 14,
                    color: ShellUiConfig.footerTextFor(brightness),
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                _FooterLinkButton(
                  label: privacyLabel,
                  onTap: () => _openBuiltInPrivacyModal(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SelectableText(
              AppRuntimeConfig.buildStamp,
              style: buildStampStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String rawUrl) async {
    final Uri uri = Uri.parse(rawUrl);
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.platformDefault,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open $rawUrl')));
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

class _FooterLinkButton extends StatelessWidget {
  const _FooterLinkButton({required this.label, required this.onTap});

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
              return ShellUiConfig.footerLinkHoverFor(brightness);
            }
            return ShellUiConfig.footerLinkFor(brightness);
          },
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter18pt',
          fontWeight: FontWeight.w300,
          fontSize: 14,
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.solid,
          decorationColor: ShellUiConfig.footerLinkFor(brightness),
          decorationThickness: 1.0,
        ),
      ),
    );
  }
}
