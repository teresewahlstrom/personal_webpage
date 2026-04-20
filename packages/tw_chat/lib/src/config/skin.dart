import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/math.dart';

class ChatPalette {
  const ChatPalette._();

  // Notebook-inspired colors (from main app)
  static const transparent = Color(0x00000000);
  static const black = Color(0xFF000000);
  static const black54 = Color(0x8A000000);
  static const black50 = Color(0x80000000);
  static const black03 = Color(0x08000000);
  static const black28 = Color(0x47000000);

  static const white = Color(0xFFFFFFFF);
  static const white92 = Color(0xEBFFFFFF);
  static const white31 = Color(0x50FFFFFF);

  // Light notebook background
  static const shellBackgroundBaseStart = Color(0xFFF8F9F7);
  static const shellBackgroundBaseEnd = Color(0xFFF8F9F7);

  // Dark text on light background
  static const appBarTitle = Color(0xFF161C45);
  
  // Deep blue accent (from main app)
  static const shellOuterBorder = Color(0xFF394183);
  static const shellDivider = Color(0xFFE1E4F2);

  // Bot bubble: white with deep blue border
  static const botBubbleFill = Color(0xFFFFFFFF);
  static const botBubbleBorder = Color(0xFF394183);

  // Rust/orange accent for actions (from main app hover)
  static const bubbleCollapseButton = Color(0xFF843F02);
  static const bubbleCollapseButtonIcon = Color(0xFFFFFFFF);

  // Text colors for light theme
  static const composerHint = Color(0xFF555764);
  static const composerFill = Color(0xFFFFFEFC);
  static const composerBorder = Color(0xFFE1E4F2);
  static const cyan = Color(0xFF394183);  // Deep blue instead of cyan
  static const composerCursor = cyan;
  static const composerCornerAccent = Color(0xFF843F02);  // Rust orange
  static const composerSendIcon = Color(0xFF843F02);  // Rust orange

  // Markup styling for light theme
  static const markupBlockquoteRail = Color(0xFF394183);
  static const scrollbarThumb = Color(0xFFBEBEBE);
  static const scrollbarThumbInactive = Color(0xFFE1E4F2);
  static const scrollbarTrack = Color(0x00F8F9F7);
}

class ChatColors {
  const ChatColors._();

  // Shared
  static const transparent = ChatPalette.transparent;

  // Shell - light notebook theme
  static const shellTopShadowStrong = ChatPalette.black03;
  static const shellTopShadowSoft = ChatPalette.transparent;
  static const appBarTitle = ChatPalette.appBarTitle;
  static const bubbleText = ChatPalette.black;
  static const shellBackgroundBaseStart = ChatPalette.shellBackgroundBaseStart;
  static const shellBackgroundBaseEnd = ChatPalette.shellBackgroundBaseEnd;
  static const shellBackgroundStart = shellBackgroundBaseStart;
  static const shellBackgroundEnd = shellBackgroundBaseEnd;
  static const shellOuterShadow = ChatPalette.black03;
  static const shellOuterBorder = ChatPalette.shellOuterBorder;
  static const shellDivider = ChatPalette.shellDivider;

  // Bubble - white bubbles with colored borders
  static const userBubbleFill = ChatPalette.white;
  static const userBubbleBorder = ChatPalette.shellOuterBorder;
  static const botBubbleFill = ChatPalette.botBubbleFill;
  static const botBubbleBorder = ChatPalette.botBubbleBorder;

  static const bubbleShadow = ChatPalette.black03;
  static const bubbleCollapseButton = ChatPalette.bubbleCollapseButton;
  static const bubbleCollapseButtonIcon = ChatPalette.bubbleCollapseButtonIcon;

  // Composer - light input with colored accents
  static const composerHint = ChatPalette.composerHint;
  static const composerFill = ChatPalette.composerFill;
  static const composerBorder = ChatPalette.composerBorder;
  static const composerCursor = ChatPalette.composerCursor;
  static const composerCornerAccent = ChatPalette.composerCornerAccent;
  static const composerSendIcon = ChatPalette.composerSendIcon;

  // Markup - light theme
  static const markupFadeMaskOpaque = ChatPalette.white;
  static const markupFadeMaskSoft = ChatPalette.transparent;
  static const markupBlockquoteRail = ChatPalette.markupBlockquoteRail;
  static const markupLink = ChatPalette.markupBlockquoteRail;
  static const markupLinkDecoration = markupLink;

  // Scrollbar - light theme
  static const scrollbarThumb = ChatPalette.scrollbarThumb;
  static const scrollbarThumbInactive = ChatPalette.scrollbarThumbInactive;
  static const scrollbarTrack = ChatPalette.scrollbarTrack;
}

class ChatTokens {
  const ChatTokens._();

  // Shared alpha values
  static const alphaTransparent = 0.0;
  static const alphaSoftText = 0.82;
  static const alphaOpaque = 1.0;

  static const headerRadiusMinimized = 16.0;
  static const headerRadiusExpanded = headerRadiusMinimized / 2;
  static const bubbleRadius = 4.0;
  static const collapseButtonRadius = 0.0;
  static const composerRadius = 0.0;
  static const composerCornerAccentRadius = 0.0;
  static const composerSendButtonRadius = 2.0;
  static const scrollbarRadius = Radius.circular(3);
  static const scrollbarTrackRadius = BorderRadius.all(Radius.circular(3));

  static const shellBorderRadiusMinimized = BorderRadius.only(
    topLeft: Radius.circular(headerRadiusMinimized),
    topRight: Radius.circular(headerRadiusMinimized),
  );

  static const shellBorderRadiusExpanded = BorderRadius.only(
    topLeft: Radius.circular(headerRadiusExpanded),
    topRight: Radius.circular(headerRadiusExpanded),
  );

  static const phoneVerticalHeightGutter = 4.0;
  static const verticalHeightGutter = 12.0;
  static const composerGap = 9.0;
  static const shellContentPadding = EdgeInsets.fromLTRB(10, 0, 2, 10);
  static const shellOuterBorderWidth = 1.0;
  static const bubbleViewportPadding = EdgeInsets.fromLTRB(0, 18, 0, 10);
  static const chatListTopShadowHeight = 14.0;
  static const shellTopShadowGradientStops = <double>[0.0, 0.75, 1.0];
  static const shellTopShadowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      ChatColors.shellTopShadowStrong,
      ChatColors.shellTopShadowSoft,
      ChatColors.transparent,
    ],
    stops: shellTopShadowGradientStops,
  );
  static const appBarPaddingMinimized = EdgeInsets.fromLTRB(14, 15, 8, 15);
  static const appBarPaddingExpanded = EdgeInsets.fromLTRB(7, 10, 8, 10);
  static const appBarLeadingGap = 2.0;
  static const appBarActionGap = 15.0;
  static const appBarActionWidth = 40.0;

  static const bubbleVerticalMargin = 8.0;
  static const bubbleBorderWidth = 1.0;
  static const bubbleNearEdgeInset = 0.0;
  static const bubbleFarEdgeInset = 0.0;
  static const bubbleTextInsetLeft = 8.0;
  static const bubbleTextInsetTopBottom = 5.0;
  static const bubbleMinInsetScaleFactor = 0.78;
  static const collapseButtonDiameter = 16.0;
  static const collapseButtonIconSize = 13.0;
  static const collapseButtonRightInset = 8.0;
  static const collapseButtonBottomInset = -8.0;
  static const collapseButtonStroke = 2.4;

  static const scrollbarThickness = 7.0;
  static const scrollbarThumbCrossAxisMargin = 1.0;
  static const scrollbarTrackLeftShift = 3.0;
  static const scrollbarMinThumbLength = 15.0;
  static const composerScrollbarReservedWidth = 10.0;
  static const userBubbleClearanceFactor = 3.0;
  static const userBubbleRightInset =
      scrollbarThickness * userBubbleClearanceFactor;

  static const composerTextInsetLeft = 8.0;
  static const composerTextInsetRight = 12.0;
  static const composerTextInsetTopBottom = 8.0;
  static const composerInputExtraVerticalSpace = 1.5;
  static const composerInputTextInsetTopBottom =
      composerTextInsetTopBottom + composerInputExtraVerticalSpace;
  static const composerCornerAccentStroke = 2.0;
  static const composerCornerAccentSegment = 12.0;
  static const composerSendIconSize = 25.0;
  static const jumpToLatestButtonRightInset = 14.0;
  static const jumpToLatestButtonBottomInset = 12.0;
  static const jumpToLatestButtonIconSize = 18.0;
  static const jumpToLatestButtonElevation = 8.0;
  static const jumpToLatestButtonPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  );
  static const markupUnderlineThickness = 1.75;

  static const markupTruncationMaxFadeHeight = 40.0;
  static const markupTruncationOverlayMidAlphaUser = 0.28;
  static const markupTruncationOverlayMidAlphaBot = 0.58;
  static const markupTruncationOverlayLateAlphaUser = 0.82;
  static const markupTruncationOverlayLateAlphaBot = 1.0;
  static const markupFadeMaskMidFactorUser = 0.68;
  static const markupFadeMaskMidFactorBot = 0.54;
  static const markupFadeMaskLateFactorUser = 0.9;
  static const markupFadeMaskLateFactorBot = 0.78;
  static const markupTruncationOverlayStopsUser = <double>[0.0, 0.76, 0.92, 1.0];
  static const markupTruncationOverlayStopsBot = <double>[0.0, 0.7, 0.86, 1.0];
  static const bubbleWidthCompensation = 15.0;
  static const bubbleMinMaxWidth = 180.0;
  static const typingIndicatorPadding = EdgeInsets.symmetric(
    horizontal: 4.0,
    vertical: 8.0,
  );
  static const typingIndicatorDefaultFontSize = 12.0;
  static const typingIndicatorDotGap = 6.0;
  static const typingIndicatorDotMinDiameter = 16 / 3;
  static const typingIndicatorDotMaxDiameter = 8.0;
  static const typingDotScaleBase = 0.85;
  static const typingDotScaleAmplitude = 0.30;
  static const typingDotAlphaBase = 0.40;
  static const typingDotAlphaAmplitude = 0.35;
  static const keyboardScrollAnimationDuration = Duration(milliseconds: 140);
  static const typingIndicatorAnimationDuration = Duration(milliseconds: 1400);

  static const shellShadow = BoxShadow(
    color: ChatColors.shellOuterShadow,
    blurRadius: 24,
    offset: Offset(0, 12),
  );

  static const surfaceShadow = BoxShadow(
    color: ChatColors.bubbleShadow,
    blurRadius: 10,
    offset: Offset(0, 5),
  );
}

class ChatTextStyles {
  const ChatTextStyles._();

  static const minTextScale = 1.0;
  static const defaultMaxTextScale = 1.6;
  static const composerMaxTextScale = 1.5;

  static const _appBarTitleBase = TextStyle(
    fontSize: 16,
    height: 1.12,
    fontWeight: FontWeight.w700,
    color: ChatColors.appBarTitle,
  );
  static final _bubbleTextBase = GoogleFonts.nunito(
    fontSize: 12,
    height: 1.5,
    color: ChatColors.bubbleText,
    fontWeight: FontWeight.w300,
  );
  static final _bubbleStrongBase = GoogleFonts.nunito(
    fontSize: 12,
    height: 1.5,
    color: ChatColors.bubbleText,
    fontWeight: FontWeight.w700,
  );
  static final _composerHintBase = GoogleFonts.nunito(
    fontSize: 12,
    height: 1.35,
    color: ChatColors.composerHint,
    fontWeight: FontWeight.w300,
  );

  static TextStyle appBarTitleStyle(double textScale) {
    final scale = _resolvedTextScale(textScale);
    return _appBarTitleBase.copyWith(
      fontSize: _scaledFontSize(_appBarTitleBase.fontSize!, scale, 0.7),
      height: _scaledLineHeight(_appBarTitleBase.height!, scale, 0.18),
    );
  }

  static TextStyle bubbleTextStyle(double textScale) {
    final scale = _resolvedTextScale(textScale);
    return _bubbleTextBase.copyWith(
      fontSize: _scaledFontSize(_bubbleTextBase.fontSize!, scale, 0.8),
      height: _scaledLineHeight(_bubbleTextBase.height!, scale, 0.5),
    );
  }

  static TextStyle composerHintStyle(double textScale) {
    final scale = _resolvedTextScale(textScale);
    return _composerHintBase.copyWith(
      fontSize: _scaledFontSize(_composerHintBase.fontSize!, scale, 0.8),
      height: _scaledLineHeight(_composerHintBase.height!, scale, 0.35),
    );
  }

  static TextStyle markdownStrongStyle(TextStyle baseStyle) {
    final baseColor = baseStyle.color ?? ChatColors.bubbleText;
    final hsl = HSLColor.fromColor(baseColor);
    final lifted = hsl.withLightness((hsl.lightness * 1.10).clamp(0.0, 1.0));
    final baseLetterSpacing = baseStyle.letterSpacing ?? 0.0;
    final bool matchesBubbleFamily =
        baseStyle.fontFamily == _bubbleTextBase.fontFamily;
    final strongBase = matchesBubbleFamily
        ? _bubbleStrongBase.copyWith(
            fontSize: baseStyle.fontSize,
            height: baseStyle.height,
          )
        : baseStyle;

    return strongBase.copyWith(
      fontWeight: FontWeight.w900,
      color: lifted.toColor(),
      letterSpacing: baseLetterSpacing + 0.45,
    );
  }

  static TextStyle markdownEmphasisStyle(TextStyle baseStyle) {
    return baseStyle.copyWith(fontStyle: FontStyle.italic);
  }

  static TextStyle markdownStrikethroughStyle(TextStyle baseStyle) {
    return baseStyle.copyWith(
      decoration: TextDecoration.lineThrough,
      decorationColor: baseStyle.color,
    );
  }

  static TextStyle markdownUnderlineStyle(TextStyle baseStyle) {
    return baseStyle.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: baseStyle.color,
      decorationThickness: ChatTokens.markupUnderlineThickness,
    );
  }

  static TextStyle markdownBlockquoteStyle(TextStyle baseStyle) {
    return baseStyle.copyWith(
      color: ChatColors.markupBlockquoteRail,
      fontStyle: FontStyle.italic,
    );
  }

  static TextStyle markdownHeadingStyle(TextStyle baseStyle, int level) {
    const scales = <double>[1.55, 1.36, 1.22, 1.12, 1.06, 1.0];
    const weights = <FontWeight>[
      FontWeight.w600,
      FontWeight.w700,
      FontWeight.w700,
      FontWeight.w700,
      FontWeight.w700,
      FontWeight.w700,
      FontWeight.w700,
    ];

    final clampedLevel = level.clamp(1, 6);
    final index = clampedLevel - 1;
    final strongStyle = markdownStrongStyle(baseStyle);
    final fontSize = baseStyle.fontSize == null
        ? null
        : baseStyle.fontSize! * scales[index];

    return strongStyle.copyWith(
      fontSize: fontSize,
      fontWeight: weights[index],
      height: clampedLevel <= 2 ? 1.2 : 1.3,
    );
  }

  static double _scaledFontSize(double base, double scale, double intensity) {
    return ChatMath.scaleFromOne(base, scale, intensity);
  }

  static double _scaledLineHeight(double base, double scale, double intensity) {
    return ChatMath.scaleFromOne(base, scale, intensity);
  }

  static double _resolvedTextScale(double textScale) {
    if (!textScale.isFinite || textScale <= 0) {
      return minTextScale;
    }
    return textScale;
  }
}
