import 'package:flutter/material.dart';
import 'package:tw_primitives/markdown.dart';
import 'package:tw_primitives/theme.dart';
import '../config/app_ui_config.dart';
import '../modals/project_story_modal.dart';
import '../models/project_card_data.dart';
import 'app_modal.dart';
import 'shell/page_scaffold.dart';

class CapabilitiesGrid extends StatelessWidget {
  const CapabilitiesGrid({super.key, required this.cards});

  final List<ProjectCardData> cards;

  @override
  Widget build(BuildContext context) {
    final List<ProjectCardData> orderedCards = cards.toList(growable: false)
      ..sort(
        (ProjectCardData a, ProjectCardData b) => a.order.compareTo(b.order),
      );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;

        // Always 3 cards per row
        final int crossAxisCount = 3;
        final bool isSmallScreen = width < 640;

        final double spacing = isSmallScreen ? 6.0 : 10.0;

        // Chunk cards into rows of size crossAxisCount.
        final List<List<ProjectCardData>> rows = [];
        for (int i = 0; i < orderedCards.length; i += crossAxisCount) {
          rows.add(
            orderedCards.sublist(
              i,
              (i + crossAxisCount).clamp(0, orderedCards.length),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int r = 0; r < rows.length; r++) ...[
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int c = 0; c < rows[r].length; c++) ...[
                      Expanded(
                        child: _PlainCopyHeadingRegistration(
                          heading: rows[r][c].title,
                          child: _CapabilityCard(
                            data: rows[r][c],
                            isSmallScreen: isSmallScreen,
                            onTap: () {
                              final ProjectCardData cardData = rows[r][c];
                              PageScaffold.clearPageSelection(context);
                              showAppModal(
                                context: context,
                                header: _CapabilityModalHeader(
                                  categoryTitle: cardData.title,
                                ),
                                builder:
                                    (BuildContext context, VoidCallback close) {
                                      return ProjectStoryModalContent(
                                        contentDocument:
                                            cardData.contentDocument,
                                        overlapHeaderTopInset: ModalUiConfig
                                            .capabilityHeaderHeight,
                                      );
                                    },
                              );
                            },
                          ),
                        ),
                      ),
                      if (c < rows[r].length - 1) SizedBox(width: spacing),
                    ],
                    // Pad out incomplete rows with empty space
                    if (rows[r].length < crossAxisCount)
                      for (
                        int pad = 0;
                        pad < (crossAxisCount - rows[r].length);
                        pad++
                      ) ...[
                        SizedBox(width: spacing),
                        const Expanded(child: SizedBox()),
                      ],
                  ],
                ),
              ),
              if (r < rows.length - 1) SizedBox(height: spacing),
            ],
          ],
        );
      },
    );
  }
}

class _CapabilityCard extends StatelessWidget {
  const _CapabilityCard({
    required this.data,
    required this.onTap,
    required this.isSmallScreen,
  });

  final ProjectCardData data;
  final VoidCallback onTap;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.twIsDark;
    final String themeFolder = isDark ? 'dark' : 'light';
    final String imagePath = data.imagePath.replaceAll('{theme}', themeFolder);

    final Color textColor = context.twColors.capabilityCardText;
    final Color descColor = context.twColors.capabilityCardDesc;
    final Color categoryColor = context.twColors.capabilityCardCategory;
    final Color dividerColor = context.twColors.capabilityCardDivider;
    final bool isSmall = isSmallScreen;
    final double titleSize = isSmall ? 13.5 : 17.0;
    final double descSize = isSmall ? 11.5 : 13.0;
    final double categorySize = isSmall ? 9.0 : 10.5;
    final double imageHeight = isSmall ? 64.0 : 92.0;
    final double imageToTitleGap = isSmall ? 6.0 : 10.0;
    final double titleToDescGap = isSmall ? 6.0 : 8.0;
    final double descToDividerGap = isSmall ? 10.0 : 16.0;
    final double dividerToCategoryGap = isSmall ? 8.0 : 12.0;

    return TwFeatureCardSurface(
      isCompact: isSmallScreen,
      onTap: onTap,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: SizedBox(
                height: imageHeight,
                child: AnimatedScale(
                  scale: state.imageScale,
                  duration: state.animationDuration,
                  curve: state.animationCurve,
                  child: Image.asset(imagePath, fit: BoxFit.contain),
                ),
              ),
            ),
            SizedBox(height: imageToTitleGap),
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: titleSize,
                fontWeight: FontWeight.w500,
                color: textColor,
                height: 1.25,
              ),
            ),
            SizedBox(height: titleToDescGap),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: descSize,
                    fontWeight: FontWeight.w400,
                    color: descColor,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            SizedBox(height: descToDividerGap),
            Divider(height: 1, thickness: 1, color: dividerColor),
            SizedBox(height: dividerToCategoryGap),
            Text(
              data.category,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: categorySize,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: categoryColor,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CapabilityModalHeader extends StatelessWidget {
  const _CapabilityModalHeader({required this.categoryTitle});

  final String categoryTitle;

  @override
  Widget build(BuildContext context) {
    final MarkdownSurfaceStyle markdownSurface = buildMarkdownSurfaceStyle(
      MarkdownThemeConfig(
        isDark: context.twIsDark,
        textScale: MarkdownThemeConfig.bodyTextScaleOf(context),
      ),
    );
    final TextStyle eyebrowStyle = _tereseAsStyle(
      markdownSurface.theme.headingStyleResolver(2),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('TERESE AS:', style: eyebrowStyle),
        Text(
          categoryTitle,
          style: markdownSurface.theme.headingStyleResolver(1),
        ),
      ],
    );
  }

  TextStyle _tereseAsStyle(TextStyle baseStyle) {
    return baseStyle.copyWith(
      fontSize: baseStyle.fontSize == null ? null : baseStyle.fontSize! - 2.0,
      letterSpacing: (baseStyle.letterSpacing ?? 0.0) + 0.8,
      wordSpacing: (baseStyle.wordSpacing ?? 0.0) + 2.0,
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
