import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:tw_primitives/markdown.dart';
import 'package:tw_primitives/scrollbar.dart' show TwSelectableScrollArea;

import 'package:tw_primitives/theme.dart';

class PrivacyCookiesContent extends StatefulWidget {
  const PrivacyCookiesContent({super.key, required this.onLaunchUrl});

  final Future<void> Function(String url) onLaunchUrl;

  @override
  State<PrivacyCookiesContent> createState() => _PrivacyCookiesContentState();
}

class _PrivacyCookiesContentState extends State<PrivacyCookiesContent> {
  static final MarkupDocument _contentDocument = MessageMarkup.parse(
    _contentMarkdown,
  );
  final Map<String, TapGestureRecognizer> _linkRecognizersByHref =
      <String, TapGestureRecognizer>{};

  @override
  void dispose() {
    for (final TapGestureRecognizer recognizer
        in _linkRecognizersByHref.values) {
      recognizer.dispose();
    }
    _linkRecognizersByHref.clear();
    super.dispose();
  }

  TapGestureRecognizer _recognizerForHref(String href) {
    return _linkRecognizersByHref.putIfAbsent(href, () {
      final TapGestureRecognizer recognizer = TapGestureRecognizer();
      recognizer.onTap = () {
        widget.onLaunchUrl(href);
      };
      return recognizer;
    });
  }

  MarkdownSurfaceStyle _buildSurface(BuildContext context) {
    return buildMarkdownSurfaceStyle(
      MarkdownThemeConfig(
        isDark: context.twIsDark,
        textScale: MarkdownThemeConfig.bodyTextScaleOf(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MarkdownSurfaceStyle markdownSurface = _buildSurface(context);
    return SafeArea(
      top: false,
      bottom: false,
      child: TwSelectableScrollArea.scrollView(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
        thumbVisibility: true,
        child: MarkupView(
          document: _contentDocument,
          theme: markdownSurface.theme,
          gestureRecognizerFactory: _recognizerForHref,
          textAlign: TextAlign.start,
          selectable: true,
          chromeVisible: true,
        ),
      ),
    );
  }
}

const String _contentMarkdown = '''
**Controller:** Terese Wahlström, Sweden
**Contact:** [terese@t1grid.com](mailto:terese@t1grid.com)

We do not use analytics or advertising cookies on this website. Some third-party services may use essential cookies or similar technologies when you choose to interact with them.

## What is Collected and Why

* **Newsletter subscriptions:** If you sign up for the newsletter, your name and email address are processed by [Brevo](https://www.brevo.com/legal/privacypolicy/). We use this information to send the newsletter based on your consent, until you unsubscribe. Brevo uses a double-opt-in process to confirm your subscription.

* **Meeting bookings:** If you book a call, your name, email address and any information you choose to provide are processed by [Cal.com](https://cal.com/privacy). We use this information to arrange the meeting you request.

* **Payments:** If you make a payment, the information required to process the transaction is handled securely by [Stripe](https://stripe.com/privacy). We use this information to complete your purchase and meet applicable legal and accounting obligations. We do not store your payment-card details.

* **Website infrastructure and security:** [Cloudflare](https://www.cloudflare.com/privacypolicy/) may process technical information, such as your IP address and request data, to deliver and protect the website.

## Data Retention

We retain personal data only for as long as necessary for the purpose for which it was collected and to meet applicable legal obligations. Where data is processed by a third-party provider, the provider may also retain data in accordance with its own privacy policy and legal obligations.

## International Transfers

Some service providers may process data outside the EEA. Where required, they use appropriate safeguards for international data transfers, such as adequacy decisions or Standard Contractual Clauses.

## External Links

Our website may contain links to external websites, such as [GitHub](https://docs.github.com/en/site-policy/privacy-policies/github-privacy-statement). If you follow an external link, the external website processes your data under its own privacy policy.

## Your Rights

Depending on the circumstances, you may have the right to:

* Access, correct or delete your personal data
* Restrict or object to processing
* Receive a portable copy of your data
* Withdraw your consent at any time
* Lodge a complaint with your local data protection authority

To exercise your rights, email [terese@t1grid.com](mailto:terese@t1grid.com).

''';
