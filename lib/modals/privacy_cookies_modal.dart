import 'package:flutter/material.dart';
import 'package:tw_primitives/scrollbar.dart' show TwScrollArea;

import '../config/app_ui_config.dart';

class PrivacyCookiesContent extends StatelessWidget {
  const PrivacyCookiesContent({super.key, required this.onLaunchUrl});

  final Future<void> Function(String url) onLaunchUrl;

  @override
  Widget build(BuildContext context) {
    final TextStyle h3Style = ModalTextStyles.h3(context);
    final TextStyle linkStyle = ModalTextStyles.link(context);
    return SafeArea(
      top: false,
      bottom: false,
      child: TwScrollArea.scrollView(
        thumbVisibility: false,
        primary: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text("Controller: Terese Wahlstrom (EU resident)"),
            const SizedBox(height: 16),
            Text("Cookies", style: h3Style),
            const SizedBox(height: 8),
            const Text("We only set essential cookies via:"),
            const SizedBox(height: 4),
            _PrivacyModalLink(
              label: "Brevo",
              url: "https://www.brevo.com/legal/privacypolicy/",
              onLaunchUrl: onLaunchUrl,
            ),
            _PrivacyModalLink(
              label: "Cal.com",
              url: "https://cal.com/privacy",
              onLaunchUrl: onLaunchUrl,
            ),
            _PrivacyModalLink(
              label: "Stripe",
              url: "https://stripe.com/privacy",
              onLaunchUrl: onLaunchUrl,
            ),
            _PrivacyModalLink(
              label: "Cloudflare",
              url: "https://www.cloudflare.com/privacypolicy/",
              onLaunchUrl: onLaunchUrl,
            ),
            _PrivacyModalLink(
              label: "GitHub",
              url:
                  "https://docs.github.com/en/site-policy/privacy-policies/github-privacy-statement",
              onLaunchUrl: onLaunchUrl,
            ),
            const SizedBox(height: 16),
            Text("What We Collect", style: h3Style),
            const SizedBox(height: 8),
            const _PrivacyModalBullet(
              text:
                  "Newsletter (via Brevo): Your name and email are stored by Brevo when you sign up; they use a double-opt-in to confirm your consent, and Brevo retains your data until you unsubscribe and an additional three years for record-keeping.",
            ),
            const _PrivacyModalBullet(
              text:
                  "Meetings (via Cal.com): Cal.com collects your name, email and any details you choose to share when you book a call; Cal.com holds this information for up to 12 months.",
            ),
            const _PrivacyModalBullet(
              text:
                  "Payments (via Stripe): Stripe processes and retains your name, email and billing information for seven years to meet legal and accounting requirements.",
            ),
            const SizedBox(height: 16),
            Text("Transfers & Safeguards", style: h3Style),
            const SizedBox(height: 8),
            const Text(
              "Our embedded services may transfer data outside the EEA under their own GDPR-compliant safeguards (Standard Contractual Clauses or adequacy).",
            ),
            const SizedBox(height: 16),
            Text("Your Rights", style: h3Style),
            const SizedBox(height: 8),
            const _PrivacyModalBullet(text: "Access, correct or delete your data"),
            const _PrivacyModalBullet(text: "Restrict or object to processing"),
            const _PrivacyModalBullet(text: "Data portability"),
            const _PrivacyModalBullet(text: "Withdraw consent anytime"),
            const _PrivacyModalBullet(
              text: "Lodge a complaint with your Data Protection Authority",
            ),
            const SizedBox(height: 16),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 2,
              children: <Widget>[
                const Text("To exercise any right, email"),
                GestureDetector(
                  onTap: () => onLaunchUrl("mailto:terese@t1grid.com"),
                  child: Text("terese@t1grid.com", style: linkStyle),
                ),
                const Text("."),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyModalLink extends StatefulWidget {
  const _PrivacyModalLink({
    required this.label,
    required this.url,
    required this.onLaunchUrl,
  });

  final String label;
  final String url;
  final Future<void> Function(String url) onLaunchUrl;

  @override
  State<_PrivacyModalLink> createState() => _PrivacyModalLinkState();
}

class _PrivacyModalLinkState extends State<_PrivacyModalLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color baseLinkColor = AppColorTheme.linkTextFor(brightness);
    final Color hoverLinkColor = AppColorTheme.linkTextHoverFor(brightness);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onLaunchUrl(widget.url),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            widget.label,
            style: ModalTextStyles.link(
              context,
            ).copyWith(color: _isHovered ? hoverLinkColor : baseLinkColor),
          ),
        ),
      ),
    );
  }
}

class _PrivacyModalBullet extends StatelessWidget {
  const _PrivacyModalBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("\u2022 "),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
