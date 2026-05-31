import 'package:flutter/gestures.dart'
    show TapGestureRecognizer, kPrimaryButton, kTouchSlop;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tw_chat/chat.dart' show ChatComposerLayout, ChatSkin;
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
                        const SizedBox(height: 25),
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
                                    style: TwTextStyles.of(context).bodyForContext(
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
                        const SizedBox(height: 37),
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
      "Turns complexity into clarity. A rare breed of creative systems thinker, cross-domain integrator, and driver of change.";
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SelectableCopyBreak(height: 20, lineBreaks: 2),
        Text(
          _title,
          style: TwTextStyles.of(context).sectionTitleForContext(
            context: context,
            color: context.twColors.pageBodyText,
          ),
        ),
        const _SelectableCopyBreak(height: 10),
        Text(
          _content,
          style: TwTextStyles.of(context).bodyForContext(
            context: context,
            color: context.twColors.pageBodyText,
          ),
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
          if (index > 0) const _SelectableCopyBreak(height: 14),
          _ExpandableProjectCard(
            title: widget.cards[index].title,
            contentDocument: widget.cards[index].contentDocument,
            isExpanded: _expandedStates[index],
            onTap: () {
              setState(() {
                _expandedStates[index] = !_expandedStates[index];
              });
            },
            gridLineStyle: gridLineStyle,
          ),
        ],
      ],
    );
  }
}

class _ExpandableProjectCard extends StatefulWidget {
  const _ExpandableProjectCard({
    required this.title,
    required this.contentDocument,
    required this.isExpanded,
    required this.onTap,
    required this.gridLineStyle,
  });

  final String title;
  final MarkupDocument contentDocument;
  final bool isExpanded;
  final VoidCallback onTap;
  final AppLineStyle gridLineStyle;

  @override
  State<_ExpandableProjectCard> createState() => _ExpandableProjectCardState();
}

MarkdownSurfaceStyle _buildProjectCardMarkdownSurface(BuildContext context) {
  final chatSkin = ChatSkin.dataOf(context);
  final textScale = MediaQuery.textScalerOf(context).scale(1.0);
  return buildMarkdownSurfaceStyle(
    MarkdownThemeConfig(
      baseTextColor: chatSkin.colors.bubbleText,
      linkColor: chatSkin.colors.markupLink,
      isDark: ChatSkin.isDarkOf(context),
      textScale: MarkdownThemeConfig.bodyTextScaleOf(context),
      linkPillStyle: MarkupLinkPillStyle(
        fillColor: ChatComposerLayout.fillColor(context),
        borderColor: ChatComposerLayout.borderColor(context),
        textStyle: chatSkin.textStyles.appBarTitleStyle(
          textScale,
          chatSkin.colors,
        ),
        shadows: <BoxShadow>[
          chatSkin.tokens.jumpToLatestButtonShadow(chatSkin.colors),
        ],
      ),
    ),
  );
}

class _ExpandableProjectCardState extends State<_ExpandableProjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  bool _isHovered = false;
  int? _headerPointer;
  Offset? _headerPointerDownPosition;
  bool _headerTapEligible = false;

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

  void _clearHeaderPointerTracking() {
    _headerPointer = null;
    _headerPointerDownPosition = null;
    _headerTapEligible = false;
  }

  void _handleCardTap() {
    PageScaffold.clearPageSelection(context);
    widget.onTap();
  }

  void _handleHeaderPointerDown(PointerDownEvent event) {
    if (event.buttons != kPrimaryButton) {
      _clearHeaderPointerTracking();
      return;
    }
    _headerPointer = event.pointer;
    _headerPointerDownPosition = event.position;
    _headerTapEligible = true;
  }

  void _handleHeaderPointerMove(PointerMoveEvent event) {
    if (!_headerTapEligible ||
        event.pointer != _headerPointer ||
        _headerPointerDownPosition == null) {
      return;
    }
    if ((event.position - _headerPointerDownPosition!).distance > kTouchSlop) {
      _headerTapEligible = false;
    }
  }

  void _handleHeaderPointerUp(PointerUpEvent event) {
    final bool shouldToggle =
        _headerTapEligible && event.pointer == _headerPointer;
    _clearHeaderPointerTracking();
    if (shouldToggle) {
      _handleCardTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color cardFill = Color.lerp(
      context.twColors.pageBackground,
      context.twColors.lineSubtle,
      context.twColors.projectCardFillAlpha,
    )!;
    final MarkdownSurfaceStyle markdownSurface =
        _buildProjectCardMarkdownSurface(context);
    final TextStyle h2 = markdownSurface.theme.headingStyleResolver(2);
    final TextStyle cardTitleStyle = TwTextStyles.of(context).cardTitleFrom(h2);
    final Color baseIconColor =
        TwTextStyles.of(context).bodyForContext(
          context: context,
          color: context.twColors.pageBodyText,
        ).color ??
        Theme.of(context).textTheme.bodyMedium?.color ??
        context.twColors.pageBodyText;
    final Color iconColor = _isHovered ? context.twColors.linkTextHover : baseIconColor;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cardFill,
          border: widget.gridLineStyle.borderAll,
          borderRadius: BorderRadius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _SelectableCopyBreak(height: 0),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: _handleHeaderPointerDown,
                  onPointerMove: _handleHeaderPointerMove,
                  onPointerUp: _handleHeaderPointerUp,
                  onPointerCancel: (_) => _clearHeaderPointerTracking(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(widget.title, style: cardTitleStyle),
                      ),
                      RotationTransition(
                        turns: Tween<double>(
                          begin: 0,
                          end: 0.5,
                        ).animate(_heightAnimation),
                        child: Icon(Icons.expand_more, color: iconColor),
                      ),
                    ],
                  ),
                ),
              ),
              SizeTransition(
                sizeFactor: _heightAnimation,
                child: AnimatedBuilder(
                  animation: _heightAnimation,
                  builder: (BuildContext context, Widget? child) {
                    if (_heightAnimation.status == AnimationStatus.dismissed) {
                      return SelectionContainer.disabled(child: child!);
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const _SelectableCopyBreak(height: 12),
                        _ProjectCardMarkdownBody(
                          document: widget.contentDocument,
                          selectable: _heightAnimation.value >= 1.0,
                        ),
                      ],
                    );
                  },
                  child: const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
    return MarkupView(
      document: widget.document,
      theme: markdownSurface.theme,
      gestureRecognizerFactory: _recognizerForHref,
      textAlign: TextAlign.start,
      selectable: widget.selectable,
      chromeVisible: true,
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
        Text(
          title,
          style: TwTextStyles.of(context).sectionTitleForContext(
            context: context,
            color: context.twColors.pageBodyText,
          ),
        ),
        const _SelectableCopyBreak(height: 10),
        for (final _SocialItem entry in entries) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: _SocialRow(entry: entry),
          ),
          const _SelectableCopyBreak(height: 6),
        ],
      ],
    );
  }
}

class _SelectableCopyBreak extends StatelessWidget {
  const _SelectableCopyBreak({required this.height, this.lineBreaks = 1});

  final double height;
  final int lineBreaks;
  @override
  Widget build(BuildContext context) {
    final selectionRegistrar = SelectionContainer.maybeOf(context);
    if (selectionRegistrar == null) {
      return SizedBox(height: height);
    }

    return SizedBox(
      height: height,
      child: IgnorePointer(
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
        TwTextStyles.of(context).sectionTitleForContext(
          context: context,
          color: context.twColors.pageBodyText,
        ).color ??
        TwTextStyles.of(context).bodyForContext(
          context: context,
          color: context.twColors.pageBodyText,
        ).color ??
        Theme.of(context).textTheme.bodyMedium?.color ??
        context.twColors.pageBodyText;
    final Color color = _isHovered
        ? textColor.withValues(alpha: 0.82)
        : textColor;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.entry.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
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
              Text(
                widget.entry.label,
                style: TwTextStyles.of(context).bodyForContext(
                  context: context,
                  color: context.twColors.pageBodyText,
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
