import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:tw_primitives/markdown.dart';
import 'package:tw_primitives/scrollbar.dart' show TwScrollArea;

import '../config/app_ui_config.dart';

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

  MarkupTheme _buildTheme(BuildContext context) {
    final TextStyle bodyStyle = ModalTextStyles.body(context);
    final TextStyle headingStyle = ModalTextStyles.h3(context);
    final TextStyle linkStyle = ModalTextStyles.link(context);
    final TextStyle strikethroughStyle = bodyStyle.copyWith(
      decoration: TextDecoration.lineThrough,
      decorationColor: bodyStyle.color,
      decorationThickness: 2.0,
    );
    return MarkupTheme(
      baseStyle: bodyStyle,
      strongStyle: bodyStyle.copyWith(fontWeight: FontWeight.w700),
      emphasisStyle: bodyStyle.copyWith(fontStyle: FontStyle.italic),
      strikethroughStyle: strikethroughStyle,
      underlineStyle: bodyStyle.copyWith(
        decoration: TextDecoration.underline,
        decorationColor: bodyStyle.color,
        decorationThickness: 1.4,
      ),
      linkStyle: linkStyle,
      blockquoteStyle: bodyStyle.copyWith(fontStyle: FontStyle.italic),
      headingStyleResolver: (int level) {
        if (level <= 1) {
          return headingStyle.copyWith(fontSize: headingStyle.fontSize! + 2);
        }
        return headingStyle;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: TwScrollArea.scrollView(
        thumbVisibility: false,
        primary: true,
        child: MarkupView(
          document: _contentDocument,
          theme: _buildTheme(context),
          gestureRecognizerFactory: _recognizerForHref,
          textAlign: TextAlign.start,
          selectable: true,
          chromeVisible: true,
          blockquoteRailColor:
              ModalTextStyles.body(context).color ??
              Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }
}

const String _contentMarkdown =
    '''Controller: Terese Wahlstrom (EU resident)

## Cookies
We only set essential cookies via:
- [Brevo](https://www.brevo.com/legal/privacypolicy/)
- [Cal.com](https://cal.com/privacy)
- [Stripe](https://stripe.com/privacy)
- [Cloudflare](https://www.cloudflare.com/privacypolicy/)
- [GitHub](https://docs.github.com/en/site-policy/privacy-policies/github-privacy-statement)

## What We Collect
- Newsletter (via Brevo): Your name and email are stored by Brevo when you sign up; they use a double-opt-in to confirm your consent, and Brevo retains your data until you unsubscribe and an additional three years for record-keeping.
- Meetings (via Cal.com): Cal.com collects your name, email and any details you choose to share when you book a call; Cal.com holds this information for up to 12 months.
- Payments (via Stripe): Stripe processes and retains your name, email and billing information for seven years to meet legal and accounting requirements.

## Transfers & Safeguards
Our embedded services may transfer data outside the EEA under their own GDPR-compliant safeguards (Standard Contractual Clauses or adequacy).

## Your Rights
- Access, correct or delete your data
- Restrict or object to processing
- Data portability
- Withdraw consent anytime
- Lodge a complaint with your Data Protection Authority

To exercise any right, email [terese@t1grid.com](mailto:terese@t1grid.com).''';
