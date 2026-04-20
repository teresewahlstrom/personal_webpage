import 'package:flutter/material.dart';

class PrivacyCookiesContent extends StatelessWidget {
  const PrivacyCookiesContent({
    super.key,
    required this.onLaunchUrl,
  });

  final Future<void> Function(String url) onLaunchUrl;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      primary: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Privacy & Cookies", style: _ModalStyles.h2),
          const SizedBox(height: 14),
          Text(
            "Controller: Terese Wahlstrom (EU resident)",
            style: _ModalStyles.body,
          ),
          const SizedBox(height: 16),
          Text("Cookies", style: _ModalStyles.h3),
          const SizedBox(height: 8),
          Text("We only set essential cookies via:", style: _ModalStyles.body),
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
          Text("What We Collect", style: _ModalStyles.h3),
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
          Text("Transfers & Safeguards", style: _ModalStyles.h3),
          const SizedBox(height: 8),
          Text(
            "Our embedded services may transfer data outside the EEA under their own GDPR-compliant safeguards (Standard Contractual Clauses or adequacy).",
            style: _ModalStyles.body,
          ),
          const SizedBox(height: 16),
          Text("Your Rights", style: _ModalStyles.h3),
          const SizedBox(height: 8),
          const _PrivacyModalBullet(
              text: "Access, correct or delete your data"),
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
              Text("To exercise any right, email", style: _ModalStyles.body),
              GestureDetector(
                onTap: () => onLaunchUrl("mailto:terese@t1grid.com"),
                child: Text("terese@t1grid.com", style: _ModalStyles.link),
              ),
              Text(".", style: _ModalStyles.body),
            ],
          ),
        ],
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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onLaunchUrl(widget.url),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            widget.label,
            style: _ModalStyles.link.copyWith(
              color: _isHovered ? Colors.white : const Color(0xFF78A9FF),
            ),
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
          Text("\u2022 ", style: _ModalStyles.body),
          Expanded(child: Text(text, style: _ModalStyles.body)),
        ],
      ),
    );
  }
}

class _ModalStyles {
  static const TextStyle h2 = TextStyle(
    fontFamily: "ComingSoon",
    fontWeight: FontWeight.w700,
    fontSize: 32,
    color: Colors.white,
    height: 1,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: "Inter18pt",
    fontWeight: FontWeight.w500,
    fontSize: 22,
    color: Colors.white,
    height: 1.2,
  );

  static const TextStyle body = TextStyle(
    fontFamily: "Inter18pt",
    fontWeight: FontWeight.w300,
    fontSize: 16,
    height: 1.6,
    color: Colors.white,
  );

  static const TextStyle link = TextStyle(
    fontFamily: "Inter18pt",
    fontWeight: FontWeight.w300,
    fontSize: 16,
    height: 1.6,
    color: Color(0xFF78A9FF),
    decoration: TextDecoration.underline,
  );
}
