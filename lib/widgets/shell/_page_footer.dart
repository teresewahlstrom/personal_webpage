import 'package:flutter/material.dart';
import 'package:tw_primitives/theme.dart';
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
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: ShellUiConfig.footerMinHeight,
      ),
      padding: ShellUiConfig.footerPadding,
      decoration: BoxDecoration(
        color: context.twColors.transparent,
      ),
      child: Center(
        child: DefaultTextStyle(
          style: TwTextStyles.of(context).footerBodyForContext(
            context: context,
            color: context.twColors.pageBodyText,
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 2,
            children: <Widget>[
              Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: '\n\n',
                      style: TwTextStyles.of(context).transparentSelectionSpacer,
                    ),
                    TextSpan(
                      text: '\u00A9$year $brandName. All rights reserved. ',
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              TwLinkPill(
                label: privacyLabel,
                onTap: () => _openBuiltInPrivacyModal(context),
              ),
            ],
          ),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $rawUrl')));
      }
    } catch (_) {
      if (!context.mounted) {
        return;
      }
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


