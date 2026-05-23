import 'package:flutter/gestures.dart'
    show TapGestureRecognizer, kPrimaryButton, kTouchSlop;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tw_chat/chat.dart';
import 'package:tw_keywords/tw_keywords.dart';
import 'package:tw_primitives/markdown.dart';
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
  late Future<SubjectKeywordData> _subjectFuture;
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
                    style: PageTextStyles.h2(context),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: PageTextStyles.body(context),
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
          final Brightness brightness = Theme.of(context).brightness;
          final Color keywordGraphicFill = ShellUiConfig.pageBackgroundFor(
            brightness,
          );
          final AppLineStyle keywordGraphicLine = ShellUiConfig.gridLineFor(
            brightness,
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

              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 60),
                        const _ProjectsSection(),
                        const SizedBox(height: 60),
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
          style: PageTextStyles.body(context),
          child: content,
        );
      },
    );
  }
}

class _HeroStatement extends StatelessWidget {
  const _HeroStatement();

  static const String _title = "Terese Wahlström";
  static const String _content =
            "Turns complexity into clarity. A rare breed of creative systems thinker, cross-domain integrator, and driver of change.";
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SelectableCopyBreak(height: 20),
        Text(_title, style: PageTextStyles.h2(context)),
        const _SelectableCopyBreak(height: 10),
        Text(_content, style: PageTextStyles.body(context)),
        const _SelectableCopyBreak(height: 0),
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
  static const String _title = "Professional Story";
  static const String _projectCardsAssetPath =
      'lib/subjects/Terese/project_cards.md';

  late Future<List<_ProjectCardData>> _projectCardsFuture;
  List<bool> _expandedStates = <bool>[];

  @override
  void initState() {
    super.initState();
    _projectCardsFuture = _loadProjectCards();
  }

  Future<List<_ProjectCardData>> _loadProjectCards() async {
    final String markdown = await rootBundle.loadString(_projectCardsAssetPath);
    final List<_ProjectCardData> cards = _ProjectCardsMarkdownLoader.parse(
      markdown,
      sourceAssetPath: _projectCardsAssetPath,
    );
    _expandedStates = List<bool>.filled(cards.length, false);
    return cards;
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final AppLineStyle gridLineStyle = ShellUiConfig.gridLineFor(brightness);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SelectableCopyBreak(height: 20),
        Text(_title, style: PageTextStyles.h2(context)),
        const _SelectableCopyBreak(height: 10),
        FutureBuilder<List<_ProjectCardData>>(
          future: _projectCardsFuture,
          builder:
              (
                BuildContext context,
                AsyncSnapshot<List<_ProjectCardData>> snapshot,
              ) {
                if (snapshot.hasError) {
                  return Text(
                    'Could not load project cards.',
                    style: PageTextStyles.body(context),
                  );
                }
                if (!snapshot.hasData) {
                  return const SizedBox(height: 48);
                }

                final List<_ProjectCardData> projectCards = snapshot.data!;
                final String selectionOrderKey = _expandedStates
                    .map((bool isExpanded) => isExpanded ? '1' : '0')
                    .join();
                return KeyedSubtree(
                  key: ValueKey<String>('project-cards-$selectionOrderKey'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (
                        int index = 0;
                        index < projectCards.length;
                        index++
                      ) ...<Widget>[
                        _ExpandableProjectCard(
                          title: projectCards[index].title,
                          contentDocument: projectCards[index].contentDocument,
                          isExpanded: _expandedStates[index],
                          onTap: () {
                            setState(() {
                              _expandedStates[index] = !_expandedStates[index];
                            });
                          },
                          gridLineStyle: gridLineStyle,
                        ),
                        if (index < projectCards.length - 1)
                          const _SelectableCopyBreak(height: 12),
                      ],
                    ],
                  ),
                );
              },
        ),
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
    final Brightness brightness = Theme.of(context).brightness;
    final Color cardFill = ShellUiConfig.projectCardFillFor(brightness);
    final Color baseIconColor =
        PageTextStyles.body(context).color ??
        Theme.of(context).textTheme.bodyMedium?.color ??
        PagePalette.bodyFor(brightness);
    final Color iconColor = _isHovered
        ? ShellUiConfig.linkTextHoverFor(brightness)
        : baseIconColor;
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
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: _handleHeaderPointerDown,
                  onPointerMove: _handleHeaderPointerMove,
                  onPointerUp: _handleHeaderPointerUp,
                  onPointerCancel: (_) => _clearHeaderPointerTracking(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          widget.title,
                          style: PageTextStyles.body(
                            context,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
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

  MarkupTheme _buildTheme(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final chatSkin = ChatSkin.dataForBrightness(brightness);
    return buildMarkdownTheme(
      MarkdownThemeConfig(
        baseTextColor: chatSkin.colors.bubbleText,
        linkColor: chatSkin.colors.markupLink,
        isDark: brightness == Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MarkupView(
      document: widget.document,
      theme: _buildTheme(context),
      gestureRecognizerFactory: _recognizerForHref,
      textAlign: TextAlign.start,
      selectable: widget.selectable,
      chromeVisible: true,
      blockquoteRailColor:
          PageTextStyles.body(context).color ??
          Theme.of(context).textTheme.bodyMedium?.color,
    );
  }
}

class _ProjectCardsMarkdownLoader {
  const _ProjectCardsMarkdownLoader._();

  static List<_ProjectCardData> parse(
    String markdown, {
    required String sourceAssetPath,
  }) {
    final List<String> normalizedSections = markdown
        .replaceAll('\r\n', '\n')
        .split('\n---\n')
        .map((String section) => section.trim())
        .where((String section) => section.isNotEmpty)
        .toList(growable: false);

    final List<_ProjectCardData> cards = normalizedSections
        .map(
          (String section) =>
              _parseCardSection(section, sourceAssetPath: sourceAssetPath),
        )
        .toList(growable: false);

    if (cards.isEmpty) {
      throw FormatException(
        'Project card markdown did not contain any card sections in $sourceAssetPath.',
      );
    }

    return cards;
  }

  static _ProjectCardData _parseCardSection(
    String section, {
    required String sourceAssetPath,
  }) {
    final List<String> lines = section.split('\n');
    if (lines.isEmpty || !lines.first.startsWith('## ')) {
      throw FormatException(
        'Project card section missing level-2 heading in $sourceAssetPath.',
      );
    }

    final String title = lines.first.substring(3).trim();
    final String contentMarkdown = lines.skip(1).join('\n').trim();
    if (title.isEmpty || contentMarkdown.isEmpty) {
      throw FormatException(
        'Project card section missing title or body in $sourceAssetPath.',
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
        const _SelectableCopyBreak(height: 20),
        Text(title, style: PageTextStyles.h2(context).copyWith(fontSize: 34)),
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
              style: const TextStyle(
                color: Colors.transparent,
                fontSize: 0.01,
                height: 1.0,
              ),
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
    final Brightness brightness = Theme.of(context).brightness;
    final Color headingColor =
        PageTextStyles.h2(context).color ??
        PageTextStyles.body(context).color ??
        Theme.of(context).textTheme.bodyMedium?.color ??
        PagePalette.bodyFor(brightness);
    final Color color = _isHovered
        ? headingColor.withValues(alpha: 0.82)
        : headingColor;
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
                style: PageTextStyles.socialLink(context).copyWith(
                  color: color,
                  fontSize: 17,
                  letterSpacing: 0.35,
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
