import 'package:flutter/material.dart';
import 'package:tw_primitives/theme.dart';

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
    required this.bubbleText,
    required this.shellBackground,
    required this.shellOuterShadow,
    required this.shellOuterBorder,
    required this.shellDivider,
    required this.botBubbleFill,
    required this.botBubbleBorder,
    required this.bubbleShadow,
    required this.bubbleCollapseButton,
    required this.bubbleCollapseButtonIcon,
    required this.composerFill,
    required this.composerBorder,
    required this.composerCursor,
    required this.composerCornerAccent,
    required this.composerSendIcon,
    required this.textFieldSelection,
    required this.textFieldCaret,
    required this.toolbarColor,
    required this.bubbleFadeMaskOpaque,
    required this.bubbleFadeMaskSoft,
    required this.markupLink,
    required this.scrollbarThumb,
    required this.scrollbarThumbInactive,
    required this.scrollbarTrack,
  });

  final Color transparent;
  final Color bubbleText;
  final Color shellBackground;
  final Color shellOuterShadow;
  final Color shellOuterBorder;
  final Color shellDivider;
  final Color botBubbleFill;
  final Color botBubbleBorder;
  final Color bubbleShadow;
  final Color bubbleCollapseButton;
  final Color bubbleCollapseButtonIcon;
  final Color composerFill;
  final Color composerBorder;
  final Color composerCursor;
  final Color composerCornerAccent;
  final Color composerSendIcon;
  final Color textFieldSelection;
  final Color textFieldCaret;
  final Color toolbarColor;
  final Color bubbleFadeMaskOpaque;
  final Color bubbleFadeMaskSoft;
  final Color markupLink;
  final Color scrollbarThumb;
  final Color scrollbarThumbInactive;
  final Color scrollbarTrack;
}

class ChatSkinTokens {
  const ChatSkinTokens();

  final double alphaTransparent = 0.0;

  final double bubbleRadius = 0.0;
  final double collapseButtonRadius = 0.0;
  final double composerRadius = 0.0;
  final double composerCornerAccentRadius = 0.0;
  final double composerSendButtonRadius = 2.0;
  final Radius scrollbarRadius = const Radius.circular(100);

  final double phoneVerticalHeightGutter = 4.0;
  final double verticalHeightGutter = 12.0;
  final double composerGap = 9.0;
  final EdgeInsets shellContentPadding = const EdgeInsets.fromLTRB(9, 0, 2, 10);
  final double shellOuterBorderWidth = 1.0;
  final EdgeInsets bubbleViewportPadding = const EdgeInsets.fromLTRB(
    0,
    18,
    20.75 * 5 / 6,
    10,
  );
  final double chatListTopShadowHeight = 32.0;
  final double chatListTrailingGap = 10.0;

  // Top shadow gradient
  final List<double> shellTopShadowGradientStops = const <double>[
    0.0,
    0.45,
    0.82,
    1.0,
  ];
  final List<int> shellTopShadowGradientAlphas = const <int>[
    0xFF,
    0xED,
    0xCD,
    0x33,
  ];

  // Bottom shadow gradient
  final List<double> shellBottomShadowGradientStops = const <double>[
    0.0,
    0.24,
    0.88,
    1.0,
  ];
  final List<int> shellBottomShadowGradientAlphas = const <int>[
    0xFF,
    0xEF,
    0xD3,
    0x4D,
  ];

  final double bubbleVerticalMargin = 40.0;
  final double bubbleBorderWidth = 1.0;
  final double bubbleTextInsetLeft = 8.0;
  final double bubbleTextInsetTopBottom = 5.0;
  final double bubbleMinInsetScaleFactor = 0.78;
  final double collapseButtonDiameter = 16.0;
  final double collapseButtonIconSize = 13.0;
  final double collapseButtonRightInset = 8.0;
  final double collapseButtonBottomInset = -8.0;
  final double collapseButtonStroke = 2.4;

  final double scrollbarThickness = 7.0;
  final double composerScrollbarThickness = 5.5;
  final double scrollbarThumbCrossAxisMargin = 0.0;
  final double composerScrollbarCrossAxisMargin = 3.0;
  final double scrollbarMinThumbLength = 15.0;

  final double composerTextInsetLeft = 6.3;
  final double composerTextInsetRight = 6.3;
  final double composerInputTextInsetTopBottom = 6.3;
  final double composerInputTextInsetTop = 6.3;
  final double composerCaretWidth = 1.0;

  /// The radius of the selection drag handles in the composer text field.
  ///
  /// For Android, this controls the teardrop handle radius.
  /// For iOS, this controls the ball radius on the upstream/downstream handles.
  /// The default is 6.0 logical pixels (smaller than super_editor's default of 10/8).
  final double composerHandleRadius = 6.0;
  final double composerRowTopSpacing = 10.0;
  final double composerCornerAccentStroke = 2.0;
  final double composerCornerAccentSegment = 12.0;
  final double composerSendIconSize = 25.0;
  // 2/3 of the original 5.0 — keeps the button closer to the composer edge.
  final double jumpToLatestButtonBottomInset =
      twChatJumpToLatestButtonBottomInset;
  final double jumpToLatestButtonFixedSize = twChatJumpToLatestButtonFixedSize;
  final double jumpToLatestButtonIconRatio = twChatJumpToLatestButtonIconRatio;

  final double bubbleTruncationMaxFadeHeight = 40.0;
  final double bubbleTruncationOverlayMidAlphaUser = 0.28;
  final double bubbleTruncationOverlayMidAlphaBot = 0.58;
  final double bubbleTruncationOverlayLateAlphaUser = 0.82;
  final double bubbleTruncationOverlayLateAlphaBot = 1.0;
  final double bubbleFadeMaskMidFactorUser = 0.68;
  final double bubbleFadeMaskMidFactorBot = 0.54;
  final double bubbleFadeMaskLateFactorUser = 0.9;
  final double bubbleFadeMaskLateFactorBot = 0.78;
  final List<double> bubbleTruncationOverlayStopsUser = const <double>[
    0.0,
    0.76,
    0.92,
    1.0,
  ];
  final List<double> bubbleTruncationOverlayStopsBot = const <double>[
    0.0,
    0.7,
    0.86,
    1.0,
  ];
  final double bubbleWidthCompensation = 15.0;
  final double bubbleMinWidthClamp = 180.0;
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

  LinearGradient shellTopShadowGradient(ChatSkinColors colors) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: shellTopShadowGradientAlphas
          .map((a) => colors.shellBackground.withAlpha(a))
          .toList(),
      stops: shellTopShadowGradientStops,
    );
  }

  BoxDecoration shellTopShadowDecoration(ChatSkinColors colors) {
    return BoxDecoration(
      color: colors.shellBackground,
      gradient: shellTopShadowGradient(colors),
    );
  }

  LinearGradient shellBottomShadowGradient(ChatSkinColors colors) {
    return LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: shellBottomShadowGradientAlphas
          .map((a) => colors.shellBackground.withAlpha(a))
          .toList(),
      stops: shellBottomShadowGradientStops,
    );
  }

  double shellBottomShadowHeight(double composerHeight) {
    return shellContentPadding.bottom +
        composerHeight +
        (composerGap + composerRowTopSpacing) * 0.8;
  }

  BoxShadow shellShadow(ChatSkinColors colors) {
    final baseShadow = colors.shellOuterShadow;
    final boostedBase = baseShadow.withValues(
      alpha: (baseShadow.a * 1.35).clamp(0.16, 0.62),
    );
    final accentTint = colors.composerSendIcon.withValues(
      alpha: boostedBase.a * 0.32,
    );
    final shadowColor = Color.alphaBlend(accentTint, boostedBase);
    return BoxShadow(
      color: shadowColor,
      blurRadius: 26,
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

  BoxShadow jumpToLatestButtonShadow(ChatSkinColors colors) {
    return BoxShadow(
      color: colors.bubbleShadow.withValues(
        alpha: colors.bubbleShadow.a * 0.25,
      ),
      blurRadius: 8,
      spreadRadius: 2,
      offset: const Offset(0, 1),
    );
  }
}

class ChatSkinTextStyles {
  const ChatSkinTextStyles();

  final double minTextScale = 1.0;
  final double defaultMaxTextScale = 1.6;
  final double composerMaxTextScale = 1.5;

  TextStyle appBarTitleStyle(double textScale, ChatSkinColors colors) {
    final base = TwTextStyles.forBrightness(
      Brightness.light,
    ).bodyForContextless(color: colors.bubbleText, textScale: 1.0);
    final baseAdjusted = TwTextStyles.forBrightness(
      Brightness.light,
    ).smallFrom(base);
    final scale = _resolvedTextScale(
      textScale,
      maxTextScale: defaultMaxTextScale,
    );
    // Apply color and scaled size/height using adaptBase for the final adjustments.
    return TwTextStyles.forBrightness(Brightness.light).adaptBase(
      baseAdjusted,
      color: colors.bubbleText,
      fontSize: _scaledFontSize(baseAdjusted.fontSize!, scale, 0.7),
      height: _scaledLineHeight(baseAdjusted.height!, scale, 0.18),
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
