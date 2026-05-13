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

  /// Width factors by breakpoint band for expanded dock sizing.
  static const phonePanelWidthFactor = 0.94;
  static const tabletPanelWidthFactor = 0.60;
  static const desktopPanelWidthFactor = 0.38;

  /// Min/max panel width clamps by breakpoint band.
  static const phonePanelMinWidth = 240.0;
  static const phonePanelMaxWidth = 440.0;
  static const tabletPanelMinWidth = 360.0;
  static const tabletPanelMaxWidth = 520.0;
  static const desktopPanelMinWidth = 380.0;
  static const desktopPanelMaxWidth = 560.0;

  /// Height factors by breakpoint band for dock max-height resolution.
  static const phoneHeightFactor = 0.82;
  static const tabletHeightFactor = 0.78;
  static const desktopHeightFactor = 0.74;

  /// Height threshold where compact mode starts in portrait orientation.
  static const compactHeightFillViewportThresholdPortrait = 640.0;

  /// Height threshold where compact mode starts in landscape orientation.
  static const compactHeightFillViewportThresholdLandscape = 720.0;

  /// Transition range used to avoid hard snap when resizing around compact mode.
  static const compactHeightTransitionBand = 120.0;

  /// Additional vertical budget in landscape to offset reduced line counts.
  static const landscapeHeightBoost = 0.10;

  /// Min/max dock height clamps per orientation.
  static const minWindowHeightPortrait = 280.0;
  static const maxWindowHeightPortrait = 720.0;
  static const minWindowHeightLandscape = 240.0;
  static const maxWindowHeightLandscape = 560.0;

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
    final panelFactor = _panelWidthFactor(viewportWidth);
    final targetWidth = viewportWidth * panelFactor;
    final minWidth = _panelMinWidth(viewportWidth);
    final maxWidth = _panelMaxWidth(viewportWidth);
    final clampedTarget = targetWidth.clamp(minWidth, maxWidth);
    if (availableWidth < minWidth) {
      return availableWidth;
    }
    return clampedTarget.clamp(minWidth, availableWidth);
  }

  static double maxDockHeight({
    required Size viewportSize,
    required EdgeInsets viewInsets,
    required EdgeInsets viewPadding,
  }) {
    final bool isLandscape = viewportSize.width > viewportSize.height;
    final safeViewportHeight =
        viewportSize.height - viewInsets.bottom - viewPadding.top;
    final clampedSafeViewportHeight = safeViewportHeight.clamp(
      0.0,
      double.infinity,
    );
    final heightThreshold = _compactHeightThreshold(isLandscape: isLandscape);
    final transitionProgress = _transitionProgress(
      value: clampedSafeViewportHeight,
      compactThreshold: heightThreshold,
      transitionBand: compactHeightTransitionBand,
    );
    final tokens = ChatSkin.tokens;
    final baseVerticalGutter = viewportSize.width <= phoneBreakpoint
        ? tokens.phoneVerticalHeightGutter
        : tokens.verticalHeightGutter;
    final verticalGutter = _lerp(0.0, baseVerticalGutter, transitionProgress);
    final clampedSafeUsableHeight = (clampedSafeViewportHeight - verticalGutter)
        .clamp(0.0, double.infinity);

    if (viewportSize.width <= phoneBreakpoint) {
      return clampedSafeUsableHeight;
    }

    final safeViewportWidth = _safeViewportWidth(
      viewportWidth: viewportSize.width,
      viewPadding: viewPadding,
    );
    final widthBasedFactor = _heightFactor(safeViewportWidth);
    final targetFactor =
        (widthBasedFactor + (isLandscape ? landscapeHeightBoost : 0.0)).clamp(
          0.55,
          0.95,
        );
    final targetHeight = clampedSafeUsableHeight * targetFactor;
    final minHeight = isLandscape
        ? minWindowHeightLandscape
        : minWindowHeightPortrait;
    final maxHeight = isLandscape
        ? maxWindowHeightLandscape
        : maxWindowHeightPortrait;
    final floatingHeight = targetHeight.clamp(minHeight, maxHeight);
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

  static double _compactHeightThreshold({required bool isLandscape}) {
    return isLandscape
        ? compactHeightFillViewportThresholdLandscape
        : compactHeightFillViewportThresholdPortrait;
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

  static double _panelWidthFactor(double viewportWidth) {
    if (viewportWidth <= phoneBreakpoint) {
      return phonePanelWidthFactor;
    }
    if (viewportWidth <= desktopBreakpoint) {
      return tabletPanelWidthFactor;
    }
    return desktopPanelWidthFactor;
  }

  static double _panelMinWidth(double viewportWidth) {
    if (viewportWidth <= phoneBreakpoint) {
      return phonePanelMinWidth;
    }
    if (viewportWidth <= desktopBreakpoint) {
      return tabletPanelMinWidth;
    }
    return desktopPanelMinWidth;
  }

  static double _panelMaxWidth(double viewportWidth) {
    if (viewportWidth <= phoneBreakpoint) {
      return phonePanelMaxWidth;
    }
    if (viewportWidth <= desktopBreakpoint) {
      return tabletPanelMaxWidth;
    }
    return desktopPanelMaxWidth;
  }

  static double _heightFactor(double viewportWidth) {
    if (viewportWidth <= phoneBreakpoint) {
      return phoneHeightFactor;
    }
    if (viewportWidth <= desktopBreakpoint) {
      return tabletHeightFactor;
    }
    return desktopHeightFactor;
  }
}
