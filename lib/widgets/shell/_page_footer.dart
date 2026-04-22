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
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: ShellUiConfig.footerMinHeight,
      ),
      padding: ShellUiConfig.footerPadding,
      decoration: BoxDecoration(
        color: ShellUiConfig.footerBackgroundFor(brightness),
        border: Border(
          top: BorderSide(
            color: ShellUiConfig.footerBorderFor(brightness),
            width: 1,
          ),
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
              '©$year $brandName. All rights reserved.',
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

class _FooterLinkButton extends StatefulWidget {
  const _FooterLinkButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_FooterLinkButton> createState() => _FooterLinkButtonState();
}

class _FooterLinkButtonState extends State<_FooterLinkButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color color = _isHovered
        ? ShellUiConfig.footerLinkHoverFor(brightness)
        : ShellUiConfig.footerLinkFor(brightness);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'Inter18pt',
            fontWeight: FontWeight.w300,
            fontSize: 14,
            color: color,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.solid,
            decorationColor: ShellUiConfig.footerLinkFor(brightness),
            decorationThickness: 1.0,
          ),
        ),
      ),
    );
  }
}
