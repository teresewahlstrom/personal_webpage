import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tw_chat/chat.dart' show ChatSkin;
import 'package:tw_keywords/tw_keywords.dart';
import 'package:tw_primitives/markdown.dart';
import 'package:tw_primitives/theme.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_ui_config.dart';
import '../modals/newsletter/newsletter_modal.dart';
import '../services/subject_keywords_registry.dart';
import '../widgets/app_modal.dart';
import '../widgets/shell/page_scaffold.dart';

class LandingPage extends StatefulWidget {
  /// The subject to display (defaults to Terese)
  final SubjectKeywordData? subject;
  final ValueChanged<bool>? onContentReadyChanged;

  const LandingPage({super.key, this.subject, this.onContentReadyChanged});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  static const bool _showKeywordGraph = false;
  static const String _projectCardsAssetPath =
      'lib/subjects/Terese/professional_story.md';

  late Future<SubjectKeywordData> _subjectFuture;
  late Future<_ProjectCardsContent> _projectCardsFuture;
  bool? _lastReportedContentReady;
  double _cachedCloudHeightRatio = 0.80;
  double _lastCloudHeightRatioWidth = double.infinity;
  bool? _lastCloudInWideLayout;

  @override
  void initState() {
    super.initState();
    _subjectFuture = widget.subject != null
        ? Future<SubjectKeywordData>.value(widget.subject)
        : SubjectRegistry.defaultSubject();
    _projectCardsFuture = _loadProjectCards();
  }

  Future<_ProjectCardsContent> _loadProjectCards() async {
    final String markdown = await rootBundle.loadString(_projectCardsAssetPath);
    return _ProjectCardsMarkdownLoader.parse(
      markdown,
      sourceAssetPath: _projectCardsAssetPath,
    );
  }

  Future<void> _launchUrl(String rawUrl) async {
    final Uri uri = Uri.parse(rawUrl);
    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $rawUrl')));
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open $rawUrl')));
    }
  }

  void _retrySubjectLoad() {
    SubjectRegistry.clearCache();
    setState(() {
      _subjectFuture = SubjectRegistry.defaultSubject();
    });
  }

  double _getCloudHeightRatio(double viewportWidth) {
    // Recalculate when width changes enough to matter, and always when crossing
    // the 900px layout breakpoint.
    final bool isWideLayout = viewportWidth >= 900;
    if (_lastCloudInWideLayout == null ||
        _lastCloudInWideLayout != isWideLayout ||
        (viewportWidth - _lastCloudHeightRatioWidth).abs() > 50.0) {
      _lastCloudInWideLayout = isWideLayout;
      _lastCloudHeightRatioWidth = viewportWidth;
      _cachedCloudHeightRatio = isWideLayout ? 0.52 : 0.80;
    }
    return _cachedCloudHeightRatio;
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Failed to load subject data.',
                    textAlign: TextAlign.center,
                    style: TwTextStyles.of(context).sectionTitleForContext(
                      context: context,
                      color: context.twColors.pageBodyText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TwTextStyles.of(context).bodyForContext(
                      context: context,
                      color: context.twColors.pageBodyText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _retrySubjectLoad,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else if (!snapshot.hasData) {
          // Use stable placeholder height to prevent jump when viewport changes (keyboard show/hide)
          // Fallback to 400px instead of dynamic viewport calculation
          content = const SizedBox(height: 400.0);
        } else {
          final SubjectKeywordData subject = snapshot.data!;
          final Color keywordGraphicFill = context.twColors.pageBackground;
          final AppLineStyle keywordGraphicLine = AppLineStyle(
            color: context.twColors.lineSubtle,
            width: AppLineTheme.subtleWidth,
          );
          // heightRatio: taller on mobile (portrait), shallower on wide desktop.
          final double cloudHeightRatio = _getCloudHeightRatio(viewport.width);

          content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 15),
                        const _HeroStatement(),
                        FutureBuilder<_ProjectCardsContent>(
                          future: _projectCardsFuture,
                          builder:
                              (
                                BuildContext context,
                                AsyncSnapshot<_ProjectCardsContent> snapshot,
                              ) {
                                if (!snapshot.hasData ||
                                    snapshot.data!.introDocument == null) {
                                  return const SizedBox.shrink();
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const _SelectableCopyBreak(
                                      height: 10,
                                      lineBreaks: 1,
                                    ),
                                    _ProjectCardMarkdownBody(
                                      document: snapshot.data!.introDocument!,
                                      selectable: true,
                                    ),
                                    const _SelectableCopyBreak(
                                      height: 28,
                                      lineBreaks: 2,
                                    ),
                                  ],
                                );
                              },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_showKeywordGraph)
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

              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const _SelectableCopyBreak(height: 18, lineBreaks: 2),
                        FutureBuilder<_ProjectCardsContent>(
                          future: _projectCardsFuture,
                          builder:
                              (
                                BuildContext context,
                                AsyncSnapshot<_ProjectCardsContent> snapshot,
                              ) {
                                if (snapshot.hasError) {
                                  return Text(
                                    'Could not load professional stories.',
                                    style: TwTextStyles.of(context)
                                        .bodyForContext(
                                          context: context,
                                          color: context.twColors.pageBodyText,
                                        ),
                                  );
                                }
                                if (!snapshot.hasData) {
                                  return const SizedBox(height: 37);
                                }

                                return _ProjectsSection(
                                  cards: snapshot.data!.cards,
                                );
                              },
                        ),
                        const _SelectableCopyBreak(height: 37, lineBreaks: 2),
                        _SocialSection(
                          title: "Contact Connect Follow",
                          entries: <_SocialItem>[
                            _SocialItem(
                              icon: const Icon(Icons.email_outlined),
                              label: "terese@t1grid.com",
                              copyUrl: "mailto:terese@t1grid.com",
                              onTap: () =>
                                  _launchUrl("mailto:terese@t1grid.com"),
                            ),
                            _SocialItem(
                              icon: const Icon(Icons.phone_outlined),
                              label: "+46 709 800 525",
                              copyUrl: "tel:+46709800525",
                              onTap: () => _launchUrl("tel:+46709800525"),
                            ),
                            _SocialItem(
                              icon: const Icon(Icons.calendar_month_outlined),
                              label: "Video meeting",
                              copyUrl: "https://cal.com/teresew/discuss",
                              onTap: () =>
                                  _launchUrl("https://cal.com/teresew/discuss"),
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
                              copyUrl:
                                  "https://www.linkedin.com/in/teresewahlstrom",
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
          style: TwTextStyles.of(context).bodyForContext(
            context: context,
            color: context.twColors.pageBodyText,
          ),
          child: content,
        );
      },
    );
  }
}

class _HeroStatement extends StatelessWidget {
  const _HeroStatement();

  static const String _title = "About Me";
  static const String _content =
      "Turns complexity into clarity. A rare breed of creative systems thinker, cross-domain integrator, and driver of change.\n";

  @override
  Widget build(BuildContext context) {
    final TextStyle baseBody = TwTextStyles.of(context).bodyForContext(
      context: context,
      color: context.twColors.pageBodyText,
    );
    final TextStyle h2Style =
        TwTextStyles.of(context).h2From(baseBody);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SelectableCopyBreak(height: 20, lineBreaks: 2),
        ClipOval(
          child: Image.asset(
            'assets/FB_IMG_1780682807710.jpg',
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Terese Wahlström',
          style: h2Style,
        ),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '# ',
                style: TwTextStyles.of(context).transparentSelectionSpacer,
              ),
              TextSpan(text: _title),
            ],
          ),
          style: TwTextStyles.of(context).h1DisplayForContext(
            context: context,
            color: context.twColors.pageBodyText,
          ),
        ),
        const _SelectableCopyBreak(height: 10),
        Text(
          _content,
          style: baseBody,
        ),
      ],
    );
  }
}

class _ProjectsSection extends StatefulWidget {
  const _ProjectsSection({required this.cards});

  final List<_ProjectCardData> cards;

  @override
  State<_ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<_ProjectsSection> {
  List<bool> _expandedStates = <bool>[];

  @override
  void initState() {
    super.initState();
    _expandedStates = List<bool>.filled(widget.cards.length, false);
  }

  @override
  void didUpdateWidget(covariant _ProjectsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cards.length != oldWidget.cards.length) {
      _expandedStates = List<bool>.filled(widget.cards.length, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLineStyle gridLineStyle = AppLineStyle(
      color: context.twColors.lineSubtle,
      width: AppLineTheme.subtleWidth,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int index = 0; index < widget.cards.length; index++) ...<Widget>[
          if (index > 0)
            const _SelectableCopyBreak(
              height: 16,
              padding: EdgeInsets.only(
                left: 12,
              ), // to match the proffessional story text indentation
            ),
          _PlainCopyHeadingRegistration(
            heading: widget.cards[index].title,
            child: TwExpandableCard(
              title: widget.cards[index].title,
              isExpanded: _expandedStates[index],
              border: gridLineStyle.borderAll,
              onTap: () {
                PageScaffold.clearPageSelection(context);
                setState(() {
                  _expandedStates[index] = !_expandedStates[index];
                });
              },
              childBuilder: (BuildContext context, bool isExpanded) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const _SelectableCopyBreak(height: 12),
                    _ProjectCardMarkdownBody(
                      document: widget.cards[index].contentDocument,
                      selectable: isExpanded,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _PlainCopyHeadingRegistration extends StatefulWidget {
  const _PlainCopyHeadingRegistration({
    required this.heading,
    required this.child,
  });

  final String heading;
  final Widget child;

  @override
  State<_PlainCopyHeadingRegistration> createState() =>
      _PlainCopyHeadingRegistrationState();
}

class _PlainCopyHeadingRegistrationState
    extends State<_PlainCopyHeadingRegistration> {
  final Object _registrationKey = Object();
  MarkupSelectionRegistry? _registry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateRegistration();
  }

  @override
  void didUpdateWidget(covariant _PlainCopyHeadingRegistration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.heading != oldWidget.heading) {
      _updateRegistration();
    }
  }

  @override
  void dispose() {
    _registry?.copyHelper.unregisterPlainHeading(_registrationKey);
    super.dispose();
  }

  void _updateRegistration() {
    final MarkupSelectionRegistry? registry = MarkupSelectionRegistry.maybeOf(
      context,
    );
    if (registry != _registry) {
      _registry?.copyHelper.unregisterPlainHeading(_registrationKey);
      _registry = registry;
    }
    _registry?.copyHelper.registerPlainHeading(
      _registrationKey,
      widget.heading,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

MarkdownSurfaceStyle _buildProjectCardMarkdownSurface(BuildContext context) {
  return buildMarkdownSurfaceStyle(
    MarkdownThemeConfig(
      isDark: ChatSkin.isDarkOf(context),
      textScale: MarkdownThemeConfig.bodyTextScaleOf(context),
    ),
  );
}

class _ProjectCardsContent {
  const _ProjectCardsContent({required this.cards, this.introDocument});

  final List<_ProjectCardData> cards;
  final MarkupDocument? introDocument;
}

class _ProjectCardData {
  const _ProjectCardData({required this.title, required this.contentDocument});

  final String title;
  final MarkupDocument contentDocument;
}

class _ProjectCardMarkdownBody extends StatefulWidget {
  const _ProjectCardMarkdownBody({
    required this.document,
    required this.selectable,
  });

  final MarkupDocument document;
  final bool selectable;

  @override
  State<_ProjectCardMarkdownBody> createState() =>
      _ProjectCardMarkdownBodyState();
}

class _ProjectCardMarkdownBodyState extends State<_ProjectCardMarkdownBody> {
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

  Future<void> _openHref(String href) async {
    final String normalizedHref =
        href.startsWith('http://') ||
            href.startsWith('https://') ||
            href.startsWith('mailto:') ||
            href.startsWith('tel:')
        ? href
        : 'https://$href';
    final Uri uri = Uri.parse(normalizedHref);
    try {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open $href')));
    }
  }

  TapGestureRecognizer _recognizerForHref(String href) {
    return _linkRecognizersByHref.putIfAbsent(href, () {
      final TapGestureRecognizer recognizer = TapGestureRecognizer();
      recognizer.onTap = () {
        _openHref(href);
      };
      return recognizer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final MarkdownSurfaceStyle markdownSurface =
        _buildProjectCardMarkdownSurface(context);
    return Opacity(
      opacity: context.twColors.cardMarkdownOpacity,
      child: MarkupView(
        document: widget.document,
        theme: markdownSurface.theme,
        gestureRecognizerFactory: _recognizerForHref,
        textAlign: TextAlign.start,
        selectable: widget.selectable,
        chromeVisible: true,
      ),
    );
  }
}

class _ProjectCardsMarkdownLoader {
  const _ProjectCardsMarkdownLoader._();

  static _ProjectCardsContent parse(
    String markdown, {
    required String sourceAssetPath,
  }) {
    final List<String> normalizedSections = markdown
        .replaceAll('\r\n', '\n')
        .split('\n---\n')
        .map((String section) => section.trim())
        .where((String section) => section.isNotEmpty)
        .toList(growable: false);

    final List<String> cardSections = <String>[...normalizedSections];
    final List<_ProjectCardData> cards = cardSections
        .map(
          (String section) =>
              _parseCardSection(section, sourceAssetPath: sourceAssetPath),
        )
        .toList(growable: false);

    if (cards.isEmpty) {
      throw FormatException(
        'Professional story markdown did not contain any sections in $sourceAssetPath.',
      );
    }

    return _ProjectCardsContent(cards: cards, introDocument: null);
  }

  static _ProjectCardData _parseCardSection(
    String section, {
    required String sourceAssetPath,
  }) {
    final List<String> lines = section.split('\n');
    if (lines.isEmpty || !lines.first.startsWith('## ')) {
      throw FormatException(
        'Professional story section missing level-2 heading in $sourceAssetPath.',
      );
    }

    final String title = lines.first.substring(3).trim();
    final String contentMarkdown = lines.skip(1).join('\n').trim();
    if (title.isEmpty || contentMarkdown.isEmpty) {
      throw FormatException(
        'Professional story section missing title or body in $sourceAssetPath.',
      );
    }

    return _ProjectCardData(
      title: title,
      contentDocument: MessageMarkup.parse(contentMarkdown),
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
        const _SelectableCopyBreak(height: 20, lineBreaks: 2),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '# ',
                style: TwTextStyles.of(context).transparentSelectionSpacer,
              ),
              TextSpan(text: title),
            ],
          ),
          style: TwTextStyles.of(context).h1DisplayForContext(
            context: context,
            color: context.twColors.pageBodyText,
          ),
        ),
        const _SelectableCopyBreak(height: 10),
        IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final _SocialItem entry in entries) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: _SocialRow(entry: entry),
                ),
                const _SelectableCopyBreak(
                  height: 6,
                  padding: EdgeInsets.only(
                    left: 55,
                  ), // This alignment is computed from the total offset of the social row text labels (10 outer padding + 4 internal padding + 27 icon slot + 14 spacer = 55 pixels).
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectableCopyBreak extends StatelessWidget {
  const _SelectableCopyBreak({
    required this.height,
    this.lineBreaks = 1,
    this.padding = EdgeInsets.zero,
  });

  final double height;
  final int lineBreaks;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final selectionRegistrar = SelectionContainer.maybeOf(context);
    if (selectionRegistrar == null) {
      return SizedBox(height: height);
    }

    return SizedBox(
      height: height,
      child: IgnorePointer(
        child: Padding(
          padding: padding,
          child: Align(
            alignment: Alignment.topLeft,
            child: RichText(
              text: TextSpan(
                text: '\n' * lineBreaks,
                style: TwTextStyles.of(context).transparentSelectionSpacer,
              ),
              selectionRegistrar: selectionRegistrar,
              selectionColor: Colors.transparent,
            ),
          ),
        ),
      ),
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
    final Color textColor =
        TwTextStyles.of(context)
            .sectionTitleForContext(
              context: context,
              color: context.twColors.pageBodyText,
            )
            .color ??
        TwTextStyles.of(context)
            .bodyForContext(
              context: context,
              color: context.twColors.pageBodyText,
            )
            .color ??
        Theme.of(context).textTheme.bodyMedium?.color ??
        context.twColors.pageBodyText;
    final Color color = _isHovered
        ? textColor.withValues(alpha: 0.82)
        : textColor;
    final Widget row = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Semantics(
        button: true,
        label: widget.entry.label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            hoverColor: textColor.withValues(alpha: 0.07),
            mouseCursor: SystemMouseCursors.click,
            onTap: widget.entry.onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 24, 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Reserve a fixed icon slot so all labels start at the same x-position.
                  SizedBox(
                    width: 27,
                    height: 27,
                    child: Center(
                      // Use IconTheme so both Material Icon and FaIcon inherit size/color.
                      child: IconTheme(
                        data: IconThemeData(size: 27, color: color),
                        child: widget.entry.icon,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: widget.entry.label),
                        if (widget.entry.copyUrl != null)
                          TextSpan(
                            text: ' (${widget.entry.copyUrl})',
                            style: TwTextStyles.of(
                              context,
                            ).transparentSelectionSpacer,
                          ),
                      ],
                    ),
                    style: TwTextStyles.of(
                      context,
                    ).bodyForContext(context: context, color: color),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final String? tooltip = widget.entry.copyUrl;
    if (tooltip == null || tooltip.isEmpty) {
      return row;
    }
    return Tooltip(message: tooltip, child: row);
  }
}

class _SocialItem {
  const _SocialItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.copyUrl,
  });

  final Widget icon;
  final String label;
  final String? copyUrl;
  final VoidCallback onTap;
}
