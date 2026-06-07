import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tw_chat/chat.dart' show ChatSkin;
import 'package:tw_primitives/markdown.dart';
import 'package:tw_primitives/theme.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_ui_config.dart';
import '../modals/project_story_modal.dart';
import '../services/subject_keywords_registry.dart';
import '../widgets/app_modal.dart';
import '../widgets/capabilities_map.dart';
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
  static const String _projectCardsAssetPath =
      'lib/subjects/Terese/professional_story.md';

  late Future<SubjectKeywordData> _subjectFuture;
  late Future<_ProjectCardsContent> _projectCardsFuture;
  bool? _lastReportedContentReady;

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



  Widget _buildSocialCard(BuildContext context) {
    final List<_SocialItem> entries = <_SocialItem>[
      _SocialItem(
        icon: const Icon(Icons.email_outlined),
        label: "terese@t1grid.com",
        copyUrl: "mailto:terese@t1grid.com",
        onTap: () => _launchUrl("mailto:terese@t1grid.com"),
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
        onTap: () => _launchUrl("https://cal.com/teresew/discuss"),
      ),
      _SocialItem(
        icon: const FaIcon(FontAwesomeIcons.linkedin),
        label: "LinkedIn",
        copyUrl: "https://www.linkedin.com/in/teresewahlstrom",
        onTap: () => _launchUrl("https://www.linkedin.com/in/teresewahlstrom"),
      ),
    ];

    return Container(
      child: Material(
        color: context.twColors.transparent,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: context.twColors.botBubbleBorder,
            width: 1.0,
          ),
          borderRadius: BorderRadius.zero,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int i = 0; i < entries.length; i++) ...<Widget>[
              _SocialRow(entry: entries[i]),
              if (i < entries.length - 1) ...<Widget>[
                Divider(
                  height: 1,
                  thickness: 1,
                  color: context.twIsDark
                      ? context.twColors.lineSubtle
                      : context.twColors.botBubbleBorder.withValues(alpha: 0.5),
                ),
                const _SelectableCopyBreak(height: 0, lineBreaks: 1),
              ],
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SubjectKeywordData>(
      future: _subjectFuture,
      builder: (BuildContext context, AsyncSnapshot<SubjectKeywordData> snapshot) {
        final bool isContentReady =
            snapshot.connectionState == ConnectionState.done;
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
                        _HeroStatement(
                          socialCard: _buildSocialCard(context),
                        ),
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


              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const _SelectableCopyBreak(height: 0, lineBreaks: 1),
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
  
                                 return CapabilitiesMap(
                                   cards: snapshot.data!.cards,
                                 );
                              },
                        ),
                        const SizedBox(height: 0),
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
  const _HeroStatement({required this.socialCard});

  final Widget socialCard;

  static const String _content =
      "Turns complexity into clarity. A rare breed of creative systems thinker, cross-domain integrator, and driver of change.\n";

  static ColorFilter _lerpToBackgroundFilter({
    required Color background,
    required double sourceWeight,
  }) {
    final double clampedSourceWeight = sourceWeight.clamp(0.0, 1.0);
    final double backgroundWeight = 1.0 - clampedSourceWeight;
    return ColorFilter.matrix(<double>[
      clampedSourceWeight, 0, 0, 0, backgroundWeight * background.red,
      0, clampedSourceWeight, 0, 0, backgroundWeight * background.green,
      0, 0, clampedSourceWeight, 0, backgroundWeight * background.blue,
      0, 0, 0, 1, 0,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle baseBody = TwTextStyles.of(context).bodyForContext(
      context: context,
      color: context.twColors.pageBodyText,
    );
    final TextStyle h1Style =
        TwTextStyles.of(context).h1From(baseBody);
    final bool isWide = MediaQuery.sizeOf(context).width >= 450;

    final Widget profilePic = ColorFiltered(
      colorFilter: _lerpToBackgroundFilter(
        background: context.twColors.pageBackground,
        sourceWeight: context.twColors.heroPortraitOpacity,
      ),
      child: ClipRRect(
        borderRadius: ShellUiConfig.heroPortraitBorderRadius,
        child: Image.asset(
          'assets/FB_IMG_1780682807710.jpg',
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SelectableCopyBreak(height: 6, lineBreaks: 2),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              profilePic,
              const SizedBox(width: 24),
              Expanded(child: socialCard),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              profilePic,
              const SizedBox(height: 16),
              socialCard,
            ],
          ),
        const SizedBox(height: 30),
        Text(
          'Terese Wahlström',
          style: h1Style,
        ),
        const SizedBox(height: 12),
        Text(
          _content,
          style: baseBody,
        ),
      ],
    );
  }
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

  final List<ProjectCardData> cards;
  final MarkupDocument? introDocument;
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
    final List<ProjectCardData> cards = cardSections
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

  static ProjectCardData _parseCardSection(
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

    return ProjectCardData(
      title: title,
      contentDocument: MessageMarkup.parse(contentMarkdown),
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

    final tokens = TwTextStyleTokens.forBrightness(
      Theme.of(context).brightness,
    );
    final baseStyle = TwTextStyles.of(context).bodyForContextless(
      color: color,
      textScale:
          MediaQuery.textScalerOf(context).scale(tokens.twBodyBaseFontSize) /
          tokens.twBodyBaseFontSize,
    );
    final h2 = TwTextStyles.of(context).h2From(baseStyle);
    final TextStyle cardTitleStyle = TwTextStyles.of(context).cardTitleFrom(h2);
    final TextStyle linkTextStyle = cardTitleStyle.copyWith(
      fontWeight: FontWeight.w300,
      fontSize: cardTitleStyle.fontSize != null
          ? cardTitleStyle.fontSize! - 3.5
          : null,
    );

    final Widget row = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Semantics(
        button: true,
        label: widget.entry.label,
        child: Material(
          color: context.twColors.transparent,
          child: InkWell(
            hoverColor: textColor.withValues(alpha: 0.07),
            mouseCursor: SystemMouseCursors.click,
            onTap: widget.entry.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
              child: Row(
                children: <Widget>[
                  // Reserve a fixed icon slot so all labels start at the same x-position.
                  SizedBox(
                    width: 25,
                    height: 25,
                    child: Center(
                      // Use IconTheme so both Material Icon and FaIcon inherit size/color.
                      child: IconTheme(
                        data: IconThemeData(size: 25, color: color),
                        child: widget.entry.icon,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text.rich(
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
                      style: linkTextStyle,
                    ),
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
