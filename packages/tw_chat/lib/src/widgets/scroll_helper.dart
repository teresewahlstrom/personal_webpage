import 'package:flutter/material.dart';

class ScrollHelper {
  const ScrollHelper();

  bool animateBy({
    required ScrollController controller,
    required double delta,
    required Duration duration,
    required Curve curve,
    required bool animate,
  }) {
    final position = controller.position;
    final nextOffset = (position.pixels + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    if (nextOffset == position.pixels) {
      return true;
    }

    if (!animate) {
      controller.jumpTo(nextOffset);
      return true;
    }

    controller.animateTo(nextOffset, duration: duration, curve: curve);
    return true;
  }

  bool isNearBottom({
    required ScrollController controller,
    required double threshold,
  }) {
    if (!controller.hasClients) {
      return true;
    }
    final position = controller.position;
    return position.maxScrollExtent - position.pixels <= threshold;
  }

  void scheduleScrollbarVisibilitySync({
    required bool Function() isMounted,
    required ScrollController controller,
    required bool Function() currentValue,
    required ValueChanged<bool> updateVisibility,
    required VoidCallback notifyListeners,
    required double visibilityOverflowThreshold,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isMounted()) {
        return;
      }
      syncScrollbarVisibility(
        controller: controller,
        currentValue: currentValue,
        updateVisibility: updateVisibility,
        notifyListeners: notifyListeners,
        visibilityOverflowThreshold: visibilityOverflowThreshold,
      );
    });
  }

  void stickToBottom({
    required bool Function() isMounted,
    required ScrollController controller,
    required int remainingPasses,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isMounted() || !controller.hasClients) {
        return;
      }
      final position = controller.position;
      final target = position.maxScrollExtent;
      if ((position.pixels - target).abs() > 0.5) {
        controller.jumpTo(target);
      }
      if (remainingPasses > 1) {
        stickToBottom(
          isMounted: isMounted,
          controller: controller,
          remainingPasses: remainingPasses - 1,
        );
      }
    });
  }

  void syncScrollbarVisibility({
    required ScrollController controller,
    required bool Function() currentValue,
    required ValueChanged<bool> updateVisibility,
    required VoidCallback notifyListeners,
    required double visibilityOverflowThreshold,
  }) {
    final hasOverflow =
        controller.hasClients &&
        controller.position.maxScrollExtent > visibilityOverflowThreshold;
    if (currentValue() == hasOverflow) {
      return;
    }
    updateVisibility(hasOverflow);
    notifyListeners();
  }
}
