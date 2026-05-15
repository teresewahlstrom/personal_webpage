import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../utils/math.dart';
import 'skin.dart';

class ChatLayout {
  const ChatLayout._();

  /// Width breakpoints for responsive dock sizing.
  static const phoneBreakpoint = 640.0;
  static const desktopBreakpoint = 1120.0;
  static const ultrawideBreakpoint = 1680.0;

  /// Width threshold where compact mode starts in portrait orientation.
  static const compactWidthFillViewportThresholdPortrait = 760.0;

  /// Width threshold where compact mode starts in landscape orientation.
  static const compactWidthFillViewportThresholdLandscape = 860.0;

  /// Transition range used to avoid hard snap when resizing around compact mode.
  static const compactWidthTransitionBand = 120.0;

  /// Minimum width baseline used for margin interpolation on small screens.
  static const minReferenceWidth = 320.0;

  /// Preferred dock width whenever the viewport has enough room.
  static const stableExpandedDockWidth = 560.0;

  /// Height factor for floating dock max-height resolution.
  static const phoneHeightFactor = 0.82;
  static const floatingHeightFactor = 0.78;

  /// Height threshold where compact mode starts.
  static const compactHeightFillViewportThreshold = 640.0;

  /// Transition range used to avoid hard snap when resizing around compact mode.
  static const compactHeightTransitionBand = 120.0;

  /// Min/max dock height clamps for floating layouts.
  static const minWindowHeight = 280.0;
  static const maxWindowHeight = 560.0;

  /// Distance from bottom that still counts as "at tail" for auto-follow.
  static const nearBottomThreshold = 24.0;

  /// Number of post-frame passes used to force final bottom settle.
  static const forcedBottomPasses = 3;
  static Color shellFill(BuildContext context) {
    return ChatSkin.dataOf(context).colors.shellBackgroundStart;
  }

  static Color dividerColor(BuildContext context) =>
      ChatSkin.dataOf(context).colors.shellDivider;

  static double dockHorizontalMargin({
    required Size viewportSize,
    required EdgeInsets viewPadding,
  }) {
    final safeWidth = _safeViewportWidth(
      viewportWidth: viewportSize.width,
      viewPadding: viewPadding,
    );
    final widthThreshold = _compactWidthThreshold(
      viewportWidth: viewportSize.width,
      viewportHeight: viewportSize.height,
    );
    final transitionProgress = _transitionProgress(
      value: safeWidth,
      compactThreshold: widthThreshold,
      transitionBand: compactWidthTransitionBand,
    );
    final baseMargin = _baseDockHorizontalMargin(safeWidth);
    return _lerp(4.0, baseMargin, transitionProgress);
  }

  static double _baseDockHorizontalMargin(double viewportWidth) {
    if (viewportWidth <= phoneBreakpoint) {
      return ChatMath.lerpClamped(
        viewportWidth,
        minReferenceWidth,
        phoneBreakpoint,
        8,
        14,
      );
    }
    if (viewportWidth <= desktopBreakpoint) {
      return ChatMath.lerpClamped(
        viewportWidth,
        phoneBreakpoint,
        desktopBreakpoint,
        14,
        24,
      );
    }
    return ChatMath.lerpClamped(
      viewportWidth,
      desktopBreakpoint,
      ultrawideBreakpoint,
      24,
      36,
    );
  }

  static double expandedDockWidth({
    required Size viewportSize,
    required EdgeInsets viewPadding,
    required double dockHorizontalMargin,
  }) {
    final safeWidth = _safeViewportWidth(
      viewportWidth: viewportSize.width,
      viewPadding: viewPadding,
    );
    final availableWidth = (safeWidth - dockHorizontalMargin * 2).clamp(
      0.0,
      double.infinity,
    );
    return _floatingExpandedDockWidth(
      viewportWidth: safeWidth,
      availableWidth: availableWidth,
    );
  }

  static double _floatingExpandedDockWidth({
    required double viewportWidth,
    required double availableWidth,
  }) {
    return stableExpandedDockWidth.clamp(0.0, availableWidth);
  }

  static double maxDockHeight({
    required Size viewportSize,
    required double keyboardHeight,
    required EdgeInsets viewPadding,
    double minimumTopInset = 0,
  }) {
    final safeViewportHeight =
        viewportSize.height - keyboardHeight - viewPadding.top;
    final clampedSafeViewportHeight = safeViewportHeight.clamp(
      0.0,
      double.infinity,
    );
    final transitionProgress = _transitionProgress(
      value: clampedSafeViewportHeight,
      compactThreshold: compactHeightFillViewportThreshold,
      transitionBand: compactHeightTransitionBand,
    );
    final tokens = ChatSkin.tokens;
    final baseVerticalGutter = viewportSize.width <= phoneBreakpoint
        ? tokens.phoneVerticalHeightGutter
        : tokens.verticalHeightGutter;
    final minimumVerticalGutter = (minimumTopInset - viewPadding.top).clamp(
      0.0,
      double.infinity,
    );
    final verticalGutter = _lerp(
      minimumVerticalGutter,
      baseVerticalGutter,
      transitionProgress,
    );
    final clampedSafeUsableHeight = (clampedSafeViewportHeight - verticalGutter)
        .clamp(0.0, double.infinity);

    if (viewportSize.width <= phoneBreakpoint) {
      return clampedSafeUsableHeight;
    }

    final targetFactor = floatingHeightFactor.clamp(0.55, 0.95);
    final targetHeight = clampedSafeUsableHeight * targetFactor;
    final floatingHeight = targetHeight.clamp(minWindowHeight, maxWindowHeight);
    return _lerp(clampedSafeUsableHeight, floatingHeight, transitionProgress);
  }

  static double _safeViewportWidth({
    required double viewportWidth,
    required EdgeInsets viewPadding,
  }) {
    return (viewportWidth - viewPadding.left - viewPadding.right).clamp(
      0.0,
      double.infinity,
    );
  }

  static double _compactWidthThreshold({
    required double viewportWidth,
    required double viewportHeight,
  }) {
    final isLandscape = viewportWidth > viewportHeight;
    return isLandscape
        ? compactWidthFillViewportThresholdLandscape
        : compactWidthFillViewportThresholdPortrait;
  }

  static double _transitionProgress({
    required double value,
    required double compactThreshold,
    required double transitionBand,
  }) {
    if (transitionBand <= 0) {
      return value <= compactThreshold ? 0.0 : 1.0;
    }
    return ((value - compactThreshold) / transitionBand).clamp(0.0, 1.0);
  }

  static double _lerp(double a, double b, double t) {
    return lerpDouble(a, b, t) ?? b;
  }
}
