import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/math.dart';

class ChatSkinData {
  const ChatSkinData({
    required this.colors,
    this.tokens = const ChatSkinTokens(),
    this.textStyles = const ChatSkinTextStyles(),
  });

  final ChatSkinColors colors;
  final ChatSkinTokens tokens;
  final ChatSkinTextStyles textStyles;
}

class ChatSkinColors {
  const ChatSkinColors({
    required this.transparent,
    required this.shellTopShadowStrong,
    required this.shellTopShadowSoft,
    required this.appBarTitle,
    required this.bubbleText,
    required this.shellBackgroundBaseStart,
    required this.shellBackgroundBaseEnd,
    required this.shellBackgroundStart,
    required this.shellBackgroundEnd,
    required this.shellOuterShadow,
    required this.shellOuterBorder,
    required this.shellDivider,
    required this.userBubbleFill,
    required this.userBubbleBorder,
    required this.botBubbleFill,
    required this.botBubbleBorder,
    required this.bubbleShadow,
    required this.bubbleCollapseButton,
    required this.bubbleCollapseButtonIcon,
    required this.composerHint,
    required this.composerFill,
    required this.composerBorder,
    required this.composerCursor,
    required this.composerCornerAccent,
    required this.composerSendIcon,
    required this.markupFadeMaskOpaque,
    required this.markupFadeMaskSoft,
    required this.markupBlockquoteRail,
    required this.markupLink,
    required this.markupLinkDecoration,
    required this.scrollbarThumb,
    required this.scrollbarThumbInactive,
    required this.scrollbarTrack,
  });

  final Color transparent;
  final Color shellTopShadowStrong;
  final Color shellTopShadowSoft;
  final Color appBarTitle;
  final Color bubbleText;
  final Color shellBackgroundBaseStart;
  final Color shellBackgroundBaseEnd;
  final Color shellBackgroundStart;
  final Color shellBackgroundEnd;
  final Color shellOuterShadow;
  final Color shellOuterBorder;
  final Color shellDivider;
  final Color userBubbleFill;
  final Color userBubbleBorder;
  final Color botBubbleFill;
  final Color botBubbleBorder;
  final Color bubbleShadow;
  final Color bubbleCollapseButton;
  final Color bubbleCollapseButtonIcon;
  final Color composerHint;
  final Color composerFill;
  final Color composerBorder;
  final Color composerCursor;
  final Color composerCornerAccent;
  final Color composerSendIcon;
  final Color markupFadeMaskOpaque;
  final Color markupFadeMaskSoft;
  final Color markupBlockquoteRail;
  final Color markupLink;
  final Color markupLinkDecoration;
  final Color scrollbarThumb;
  final Color scrollbarThumbInactive;
  final Color scrollbarTrack;
}

class ChatSkinTokens {
  const ChatSkinTokens();

  final double alphaTransparent = 0.0;

  final double bubbleRadius = 4.0;
  final double collapseButtonRadius = 0.0;
  final double composerRadius = 0.0;
  final double composerCornerAccentRadius = 0.0;
  final double composerSendButtonRadius = 2.0;
  final Radius scrollbarRadius = Radius.zero;
  final BorderRadius scrollbarTrackRadius = const BorderRadius.all(
    Radius.circular(3),
  );

  final double phoneVerticalHeightGutter = 4.0;
  final double verticalHeightGutter = 12.0;
  final double composerGap = 9.0;
  final EdgeInsets shellContentPadding = const EdgeInsets.fromLTRB(
    10,
    0,
    2,
    10,
  );
  final double shellOuterBorderWidth = 1.0;
  final EdgeInsets bubbleViewportPadding = const EdgeInsets.fromLTRB(
    0,
    18,
    0,
    10,
  );
  final double chatListTopShadowHeight = 45.0;
  final double chatListBottomShadowHeight = 30;

  // Top shadow gradient
  final List<double> shellTopShadowGradientStops = const <double>[0.0, 0.45, 0.82, 1.0];
  final List<int> shellTopShadowGradientAlphas = const <int>[0xFF, 0xE8, 0xC0, 0x00];

  // Bottom shadow gradient
  final List<double> shellBottomShadowGradientStops = const <double>[0.0, 0.24, 0.88, 1.0];
  final List<int> shellBottomShadowGradientAlphas = const <int>[0xFF, 0xE8, 0xC0, 0x00];
  final EdgeInsets appBarPaddingMinimized = const EdgeInsets.fromLTRB(
    14,
    15,
    8,
    15,
  );
  final EdgeInsets appBarPaddingExpanded = const EdgeInsets.fromLTRB(
    7,
    10,
    8,
    10,
  );
  final double appBarLeadingGap = 2.0;
  final double appBarActionGap = 15.0;
  final double appBarActionWidth = 40.0;

  final double bubbleVerticalMargin = 40.0;
  final double bubbleBorderWidth = 1.0;
  final double bubbleNearEdgeInset = 0.0;
  final double bubbleFarEdgeInset = 0.0;
  final double bubbleTextInsetLeft = 8.0;
  final double bubbleTextInsetTopBottom = 5.0;
  final double bubbleMinInsetScaleFactor = 0.78;
  final double collapseButtonDiameter = 16.0;
  final double collapseButtonIconSize = 13.0;
  final double collapseButtonRightInset = 8.0;
  final double collapseButtonBottomInset = -8.0;
  final double collapseButtonStroke = 2.4;

  final double scrollbarThickness = 7.0;
  final double scrollbarThumbCrossAxisMargin = 1.0;
  final double scrollbarTrackLeftShift = 3.0;
  final double scrollbarMinThumbLength = 15.0;
  final double composerScrollbarReservedWidth = 10.0;
  final double userBubbleRightInset = 21.0;

  final double composerTextInsetLeft = 9.5;
  final double composerTextInsetRight = 9.5;
  final double composerInputTextInsetTopBottom = 9.5;
  final double composerInputTextInsetTop = 9.5;
  final double composerRowTopSpacing = 10.0;
  final double composerCornerAccentStroke = 2.0;
  final double composerCornerAccentSegment = 12.0;
  final double composerSendIconSize = 25.0;
  final double jumpToLatestButtonRightInset = 14.0;
  final double jumpToLatestButtonBottomInset = 12.0;
  final double jumpToLatestButtonIconSize = 18.0;
  final double jumpToLatestButtonElevation = 8.0;
  final EdgeInsets jumpToLatestButtonPadding = const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  );
  final double markupUnderlineThickness = 1.75;
  final double markupDecorationThicknessBias = 0.15;
  final double markupBlockBaseSpacingFactor = 0.75;
  final double markupBlockQuoteExtraSpacing = 1.2;
  final double markupListTopSpacingAdjustment = -0.3;
  final double markupNestedListTopSpacingAdjustment = -0.59;
  final double markupNestedListBottomSpacingAdjustment = -0.55;
  final double markupBlockQuoteTopSpacingAdjustment = -0.1;
  final double markupListBottomSpacingAdjustment = 0.9;
  final List<double> markupHeadingBottomSpacingFactors = const <double>[
    -0.4,
    -0.4,
    -0.5,
  ];
  final List<double> markupHeadingTopSpacingFactors = const <double>[
    1.0,
    1.0,
    1.0,
  ];
  final double markupListItemBaseSpacingFactor = 0.14;
  final double markupTopLevelListItemSpacingAdjustment = 0.28;
  final double markupListMarkerGapFactor = 0.3333333333;
  final double markupTopLevelListMarkerSlotFactor = 2.0;
  final double markupNestedListMarkerSlotFactor = 1.75;

  final double markupTruncationMaxFadeHeight = 40.0;
  final double markupTruncationOverlayMidAlphaUser = 0.28;
  final double markupTruncationOverlayMidAlphaBot = 0.58;
  final double markupTruncationOverlayLateAlphaUser = 0.82;
  final double markupTruncationOverlayLateAlphaBot = 1.0;
  final double markupFadeMaskMidFactorUser = 0.68;
  final double markupFadeMaskMidFactorBot = 0.54;
  final double markupFadeMaskLateFactorUser = 0.9;
  final double markupFadeMaskLateFactorBot = 0.78;
  final List<double> markupTruncationOverlayStopsUser = const <double>[
    0.0,
    0.76,
    0.92,
    1.0,
  ];
  final List<double> markupTruncationOverlayStopsBot = const <double>[
    0.0,
    0.7,
    0.86,
    1.0,
  ];
  final double bubbleWidthCompensation = 15.0;
  final double bubbleMinMaxWidth = 180.0;
  final EdgeInsets typingIndicatorPadding = const EdgeInsets.symmetric(
    horizontal: 4.0,
    vertical: 8.0,
  );
  final double typingIndicatorDefaultFontSize = 14.0;
  final double typingIndicatorDotGap = 6.0;
  final double typingIndicatorDotMinDiameter = 16 / 3;
  final double typingIndicatorDotMaxDiameter = 8.0;
  final double typingDotScaleBase = 0.85;
  final double typingDotScaleAmplitude = 0.30;
  final double typingDotAlphaBase = 0.40;
  final double typingDotAlphaAmplitude = 0.35;
  final Duration keyboardScrollAnimationDuration = const Duration(
    milliseconds: 140,
  );
  final Duration typingIndicatorAnimationDuration = const Duration(
    milliseconds: 1400,
  );

  double markupHeadingBottomSpacingFactorForLevel(int level) {
    return _markupFactorByLevel(markupHeadingBottomSpacingFactors, level);
  }

  double markupHeadingTopSpacingFactorForLevel(int level) {
    return _markupFactorByLevel(markupHeadingTopSpacingFactors, level);
  }

  double _markupFactorByLevel(List<double> factors, int level) {
    final index = level.clamp(1, factors.length).toInt() - 1;
    return factors[index];
  }

  LinearGradient shellTopShadowGradient(ChatSkinColors colors) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: shellTopShadowGradientAlphas
//           .map((a) => const Color(0xFFFF00FF).withAlpha(a))
          .map((a) => colors.shellBackgroundStart.withAlpha(a))
          .toList(),
      stops: shellTopShadowGradientStops,
    );
  }

  LinearGradient shellBottomShadowGradient(ChatSkinColors colors) {
    return LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: shellBottomShadowGradientAlphas
          .map((a) => colors.shellBackgroundStart.withAlpha(a))
          .toList(),
      stops: shellBottomShadowGradientStops,
    );
  }

  BoxShadow shellShadow(ChatSkinColors colors) {
    return BoxShadow(
      color: colors.shellOuterShadow,
      blurRadius: 24,
      offset: const Offset(0, 12),
    );
  }

  BoxShadow surfaceShadow(ChatSkinColors colors) {
    return BoxShadow(
      color: colors.bubbleShadow,
      blurRadius: 10,
      offset: const Offset(0, 5),
    );
  }
}

class ChatSkinTextStyles {
  const ChatSkinTextStyles();

  final double minTextScale = 1.0;
  final double defaultMaxTextScale = 1.6;
  final double composerMaxTextScale = 1.5;

  TextStyle appBarTitleStyle(double textScale, ChatSkinColors colors) {
    const base = TextStyle(
      fontSize: 16,
      height: 1.12,
      fontWeight: FontWeight.w700,
    );
    final scale = _resolvedTextScale(
      textScale,
      maxTextScale: defaultMaxTextScale,
    );
    return base.copyWith(
      color: colors.appBarTitle,
      fontSize: _scaledFontSize(base.fontSize!, scale, 0.7),
      height: _scaledLineHeight(base.height!, scale, 0.18),
    );
  }

  TextStyle bubbleTextStyle(double textScale, ChatSkinColors colors) {
    final scale = _resolvedTextScale(
      textScale,
      maxTextScale: defaultMaxTextScale,
    );
    final base = GoogleFonts.nunito(
      fontSize: 16,
      height: 1.5,
      color: colors.bubbleText,
      fontWeight: FontWeight.w300,
    );
    return base.copyWith(
      fontSize: _scaledFontSize(base.fontSize!, scale, 0.8),
      height: _scaledLineHeight(base.height!, scale, 0.5),
    );
  }

  TextStyle composerHintStyle(double textScale, ChatSkinColors colors) {
    final scale = _resolvedTextScale(
      textScale,
      maxTextScale: composerMaxTextScale,
    );
    final base = GoogleFonts.nunito(
      fontSize: 16,
      height: 1.35,
      color: colors.composerHint,
      fontWeight: FontWeight.w300,
    );
    return base.copyWith(
      fontSize: _scaledFontSize(base.fontSize!, scale, 0.8),
      height: _scaledLineHeight(base.height!, scale, 0.35),
    );
  }

  TextStyle markdownStrongStyle(TextStyle baseStyle, ChatSkinColors colors) {
    final baseColor = baseStyle.color ?? colors.bubbleText;
    final hsl = HSLColor.fromColor(baseColor);
    final lifted = hsl.withLightness((hsl.lightness * 1.10).clamp(0.0, 1.0));
    final baseLetterSpacing = baseStyle.letterSpacing ?? 0.0;
    final bubbleFamily = GoogleFonts.nunito().fontFamily;
    final bool matchesBubbleFamily = baseStyle.fontFamily == bubbleFamily;
    final strongBase = matchesBubbleFamily
        ? GoogleFonts.nunito(
            fontSize: baseStyle.fontSize,
            height: baseStyle.height,
            color: baseColor,
            fontWeight: FontWeight.w700,
          )
        : baseStyle;

    return strongBase.copyWith(
      fontWeight: FontWeight.w900,
      color: lifted.toColor(),
      letterSpacing: baseLetterSpacing + 0.45,
    );
  }

  TextStyle markdownEmphasisStyle(TextStyle baseStyle) {
    return baseStyle.copyWith(fontStyle: FontStyle.italic);
  }

  double markdownDecorationThickness(ChatSkinTokens tokens) {
    return tokens.markupUnderlineThickness +
        tokens.markupDecorationThicknessBias;
  }

  TextStyle markdownStrikethroughStyle(
    TextStyle baseStyle,
    ChatSkinTokens tokens,
  ) {
    return baseStyle.copyWith(
      decoration: TextDecoration.lineThrough,
      decorationColor: baseStyle.color,
      decorationThickness: markdownDecorationThickness(tokens),
    );
  }

  TextStyle markdownUnderlineStyle(TextStyle baseStyle, ChatSkinTokens tokens) {
    return baseStyle.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: baseStyle.color,
      decorationThickness: markdownDecorationThickness(tokens),
    );
  }

  TextStyle markdownBlockquoteStyle(
    TextStyle baseStyle,
    ChatSkinColors colors,
  ) {
    return baseStyle.copyWith(
      color: colors.markupBlockquoteRail,
      fontStyle: FontStyle.italic,
    );
  }

  TextStyle markdownHeadingStyle(
    TextStyle baseStyle,
    int level,
    ChatSkinColors colors,
  ) {
    const scales = <double>[1.55, 1.36, 1.22];
    const weights = <FontWeight>[
      FontWeight.w600,
      FontWeight.w700,
      FontWeight.w900,
    ];

    final clampedLevel = level.clamp(1, 3);
    final index = clampedLevel - 1;
    final strongStyle = markdownStrongStyle(baseStyle, colors);
    final fontSize = baseStyle.fontSize == null
        ? null
        : baseStyle.fontSize! * scales[index];

    return strongStyle.copyWith(
      fontSize: fontSize,
      fontWeight: weights[index],
      height: 1.2,
    );
  }

  double _scaledFontSize(double base, double scale, double intensity) {
    return ChatMath.scaleFromOne(base, scale, intensity);
  }

  double _scaledLineHeight(double base, double scale, double intensity) {
    return ChatMath.scaleFromOne(base, scale, intensity);
  }

  double _resolvedTextScale(
    double textScale, {
    double maxTextScale = double.infinity,
  }) {
    if (!textScale.isFinite || textScale <= 0) {
      return minTextScale;
    }
    return textScale.clamp(minTextScale, maxTextScale).toDouble();
  }
}
