import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tw_keywords/tw_keywords.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_ui_config.dart';
import '../modals/newsletter/newsletter_modal.dart';
import '../services/subject_keywords_registry.dart';
import '../widgets/app_modal.dart';

class LandingPage extends StatefulWidget {
  /// The subject to display (defaults to Terese)
  final SubjectKeywordData? subject;

  const LandingPage({
    super.key,
    this.subject,
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late Future<SubjectKeywordData> _subjectFuture;

  @override
  void initState() {
    super.initState();
    _subjectFuture = widget.subject != null
        ? Future<SubjectKeywordData>.value(widget.subject)
        : SubjectRegistry.defaultSubject();
  }

  Future<void> _launchUrl(String rawUrl) async {
    final Uri uri = Uri.parse(rawUrl);
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.platformDefault,
    );
    if (!launched && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Could not open $rawUrl")));
    }
  }

  void _openNewsletterModal() {
    showAppModal(
      context: context,
      builder: (BuildContext context, VoidCallback close) {
        return const NewsletterModalContent();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SubjectKeywordData>(
      future: _subjectFuture,
      builder: (BuildContext context, AsyncSnapshot<SubjectKeywordData> snapshot) {
        Widget content;

        if (snapshot.hasError) {
          content = Center(
            child: Text('Failed to load subject data: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData) {
          content = const Center(child: CircularProgressIndicator());
        } else {
          final SubjectKeywordData subject = snapshot.data!;
          final Size viewport = MediaQuery.sizeOf(context);
          // heightRatio: taller on mobile (portrait), shallower on wide desktop.
          final double cloudHeightRatio = viewport.width >= 900 ? 0.52 : 0.80;

          content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 22),
                        _HeroStatement(),
                        SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: WordCloud(
                      keywords: subject.keywords,
                      heightRatio: cloudHeightRatio,
                      maxContentWidth: 980,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const _AboutDataDrivenResumeSection(),
                        const SizedBox(height: 24),
                        _SocialSection(
                          title: "Contact, Connect, Follow",
                          entries: <_SocialItem>[
                            _SocialItem(
                              icon: const Icon(Icons.email_outlined),
                              label: "terese@t1grid.com",
                              onTap: () => _launchUrl(
                                "mailto:terese@t1grid.com",
                              ),
                            ),
                            _SocialItem(
                              icon: const Icon(Icons.phone_outlined),
                              label: "+46 709 800 525",
                              onTap: () => _launchUrl(
                                "tel:+46709800525",
                              ),
                            ),
                            _SocialItem(
                              icon: const Icon(Icons.calendar_month_outlined),
                              label: "Video meeting",
                              onTap: () => _launchUrl(
                                "https://cal.com/teresew/intro",
                              ),
                            ),
                            _SocialItem(
                              icon: const Icon(
                                Icons.notifications_active_outlined,
                              ),
                              label: "Newsletter",
                              onTap: _openNewsletterModal,
                            ),
                            _SocialItem(
                              icon: const FaIcon(FontAwesomeIcons.linkedinIn),
                              label: "LinkedIn",
                              onTap: () => _launchUrl(
                                "https://www.linkedin.com/in/teresewahlstrom",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return DefaultTextStyle(
          style: LandingPageStyles.body,
          child: content,
        );
      },
    );
  }
}

class _HeroStatement extends StatelessWidget {
  const _HeroStatement();

  static const String _title = "About me";
  static const String _content =
      "Turns complexity into clarity. A rare blend of systems thinker, cross-domain integrator, and practical catalyst";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(_title, style: LandingPageStyles.h2),
        const SizedBox(height: 10),
        Text(_content, style: LandingPageStyles.body),
      ],
    );
  }
}

class _AboutDataDrivenResumeSection extends StatelessWidget {
  const _AboutDataDrivenResumeSection();

  static const String _title = "About the Data-driven resume";
  static const String _content =
      "An AI-augmented professional twin built on structured data. Instead of a static resume, it models experience, capabilities, and cross-domain strengths as an explorable chat and keywords tree. Everything data driven.";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(_title, style: LandingPageStyles.h2),
        const SizedBox(height: 10),
        Text(_content, style: LandingPageStyles.body),
      ],
    );
  }
}

class _SocialSection extends StatelessWidget {
  const _SocialSection({required this.title, required this.entries});

  final String title;
  final List<_SocialItem> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: LandingPageStyles.h2.copyWith(fontSize: 34)),
        const SizedBox(height: 6),
        for (final _SocialItem entry in entries) ...<Widget>[
          _SocialRow(entry: entry),
        ],
      ],
    );
  }
}

class _SocialRow extends StatefulWidget {
  const _SocialRow({required this.entry});

  final _SocialItem entry;

  @override
  State<_SocialRow> createState() => _SocialRowState();
}

class _SocialRowState extends State<_SocialRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color color = _isHovered
        ? LandingPagePalette.socialHover
        : LandingPagePalette.social;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.entry.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Use IconTheme so both Material Icon and FaIcon inherit size/color.
              IconTheme(
                data: IconThemeData(size: 24, color: color),
                child: widget.entry.icon,
              ),
              const SizedBox(width: 8),
              Text(
                widget.entry.label,
                style: LandingPageStyles.socialLink.copyWith(
                  color: color,
                  decoration: _isHovered
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialItem {
  const _SocialItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;
}
