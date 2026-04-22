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
  final ValueChanged<bool>? onContentReadyChanged;

  const LandingPage({super.key, this.subject, this.onContentReadyChanged});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late Future<SubjectKeywordData> _subjectFuture;
  bool? _lastReportedContentReady;

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
      headerTitle: 'Subscribe',
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
        final bool isContentReady =
            snapshot.connectionState == ConnectionState.done;
        final Size viewport = MediaQuery.sizeOf(context);
        if (_lastReportedContentReady != isContentReady) {
          _lastReportedContentReady = isContentReady;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            widget.onContentReadyChanged?.call(isContentReady);
          });
        }

        Widget content;

        if (snapshot.hasError) {
          content = Center(
            child: Text('Failed to load subject data: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData) {
          content = SizedBox(
            height: (viewport.height * 0.72).clamp(320.0, 860.0),
          );
        } else {
          final SubjectKeywordData subject = snapshot.data!;
          final Brightness brightness = Theme.of(context).brightness;
          final Color keywordGraphicFill = ShellUiConfig.pageBackgroundFor(
            brightness,
          );
          final AppLineStyle keywordGraphicLine = AppLineTheme.subtleSecondaryFor(
            brightness,
          );
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
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    child: WordCloud(
                      keywords: subject.keywords,
                      heightRatio: cloudHeightRatio,
                      maxContentWidth: 700,
                      frameStyle: WordCloudFrameStyle(
                        backgroundColor: keywordGraphicFill,
                        borderSide: keywordGraphicLine.borderSide,
                        borderRadius: BorderRadius.zero,
                        padding: const EdgeInsets.all(5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const _ProjectsSection(),
                        const SizedBox(height: 40),
                        _SocialSection(
                          title: "Contact, Connect, Follow",
                          entries: <_SocialItem>[
                            _SocialItem(
                              icon: const Icon(Icons.email_outlined),
                              label: "terese@t1grid.com",
                              onTap: () =>
                                  _launchUrl("mailto:terese@t1grid.com"),
                            ),
                            _SocialItem(
                              icon: const Icon(Icons.phone_outlined),
                              label: "+46 709 800 525",
                              onTap: () => _launchUrl("tel:+46709800525"),
                            ),
                            _SocialItem(
                              icon: const Icon(Icons.calendar_month_outlined),
                              label: "Video meeting",
                              onTap: () =>
                                  _launchUrl("https://cal.com/teresew/intro"),
                            ),
                            _SocialItem(
                              icon: const Icon(
                                Icons.notifications_active_outlined,
                              ),
                              label: "Newsletter",
                              onTap: _openNewsletterModal,
                            ),
                            _SocialItem(
                              icon: const FaIcon(FontAwesomeIcons.linkedin),
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
          style: PageTextStyles.body(context),
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
      "Turns complexity into clarity. A rare blend of systems thinker, cross-domain integrator, and driver of change.";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(_title, style: PageTextStyles.h2(context)),
        const SizedBox(height: 10),
        Text(_content, style: PageTextStyles.body(context)),
      ],
    );
  }
}

class _ProjectsSection extends StatefulWidget {
  const _ProjectsSection();

  @override
  State<_ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<_ProjectsSection> {
  static const String _title = "Projects Portfolio";
  static const List<_ProjectCardData> _projectCards = <_ProjectCardData>[
    _ProjectCardData(
      title: "Data-driven resume",
      content:
          "An AI-augmented professional twin built on structured data. Instead of a static resume, it models experience, capabilities, and cross-domain strengths as an explorable chat and keywords tree. Everything data driven.",
    ),
  ];

  late List<bool> _expandedStates;

  @override
  void initState() {
    super.initState();
    _expandedStates = List<bool>.filled(_projectCards.length, false);
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color frameFill = ShellUiConfig.pageBackgroundFor(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(_title, style: PageTextStyles.h2(context)),
        const SizedBox(height: 10),
        for (int index = 0; index < _projectCards.length; index++) ...<Widget>[
          _ExpandableProjectCard(
            title: _projectCards[index].title,
            content: _projectCards[index].content,
            isExpanded: _expandedStates[index],
            onTap: () {
              setState(() {
                _expandedStates[index] = !_expandedStates[index];
              });
            },
            frameFill: frameFill,
          ),
          if (index < _projectCards.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ExpandableProjectCard extends StatefulWidget {
  const _ExpandableProjectCard({
    required this.title,
    required this.content,
    required this.isExpanded,
    required this.onTap,
    required this.frameFill,
  });

  final String title;
  final String content;
  final bool isExpanded;
  final VoidCallback onTap;
  final Color frameFill;

  @override
  State<_ExpandableProjectCard> createState() => _ExpandableProjectCardState();
}

class _ExpandableProjectCardState extends State<_ExpandableProjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _heightAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    if (widget.isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(_ExpandableProjectCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final AppLineStyle borderStyle = AppLineTheme.interactiveFor(
      brightness,
      hovered: _isHovered,
    );
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: widget.frameFill,
            border: borderStyle.borderAll,
            borderRadius: BorderRadius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.title,
                        style: PageTextStyles.body(context)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    RotationTransition(
                      turns: Tween<double>(begin: 0, end: 0.5)
                          .animate(_heightAnimation),
                      child: Icon(
                        Icons.expand_more,
                        color: borderStyle.color,
                      ),
                    ),
                  ],
                ),
                SizeTransition(
                  sizeFactor: _heightAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      widget.content,
                      style: PageTextStyles.body(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectCardData {
  const _ProjectCardData({required this.title, required this.content});

  final String title;
  final String content;
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
        Text(
          title,
          style: PageTextStyles.h2(context).copyWith(fontSize: 34),
        ),
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
    final Brightness brightness = Theme.of(context).brightness;
    final Color color = _isHovered
      ? ShellUiConfig.linkTextHoverFor(brightness)
      : ShellUiConfig.linkTextFor(brightness);
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
                style: PageTextStyles.socialLink(context).copyWith(
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
