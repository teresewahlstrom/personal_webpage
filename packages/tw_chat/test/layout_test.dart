import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tw_chat/src/config/config.dart';

void main() {
  double margin0({
    required Size viewportSize,
    EdgeInsets viewPadding = EdgeInsets.zero,
  }) {
    return ChatLayout.dockHorizontalMargin(
      viewportSize: viewportSize,
      viewPadding: viewPadding,
    );
  }

  double width0({
    required Size viewportSize,
    required double dockMargin,
    EdgeInsets viewPadding = EdgeInsets.zero,
  }) {
    return ChatLayout.expandedDockWidth(
      viewportSize: viewportSize,
      viewPadding: viewPadding,
      dockHorizontalMargin: dockMargin,
    );
  }

  test('fills full safe height on compact desktop viewport', () {
    final height = ChatLayout.maxDockHeight(
      viewportSize: const Size(1200, 620),
      viewInsets: EdgeInsets.zero,
      viewPadding: EdgeInsets.zero,
    );

    expect(height, 620);
  });

  test('compact mode still respects safe area and keyboard insets', () {
    final height = ChatLayout.maxDockHeight(
      viewportSize: const Size(1200, 620),
      viewInsets: const EdgeInsets.only(bottom: 20),
      viewPadding: const EdgeInsets.only(top: 24),
    );

    expect(height, 576);
  });

  test('compact mode can reserve a top inset while keyboard is open', () {
    final height = ChatLayout.maxDockHeight(
      viewportSize: const Size(620, 740),
      viewInsets: const EdgeInsets.only(bottom: 220),
      viewPadding: EdgeInsets.zero,
      minimumTopInset: 4,
    );

    expect(height, 516);
  });

  test('safe area still wins over a smaller reserved top inset', () {
    final height = ChatLayout.maxDockHeight(
      viewportSize: const Size(620, 740),
      viewInsets: const EdgeInsets.only(bottom: 220),
      viewPadding: const EdgeInsets.only(top: 24),
      minimumTopInset: 4,
    );

    expect(height, 496);
  });

  test('height transition band smooths around compact threshold', () {
    final height = ChatLayout.maxDockHeight(
      viewportSize: const Size(1200, 760),
      viewInsets: EdgeInsets.zero,
      viewPadding: EdgeInsets.zero,
    );

    expect(height, greaterThan(560));
    expect(height, lessThan(760));
  });

  test('tall desktop viewport keeps floating-height behavior', () {
    final height = ChatLayout.maxDockHeight(
      viewportSize: const Size(1200, 1000),
      viewInsets: EdgeInsets.zero,
      viewPadding: EdgeInsets.zero,
    );

    expect(height, 560);
  });

  test('compact width keeps the same fixed dock width when space allows', () {
    const viewportSize = Size(740, 1000);
    const viewPadding = EdgeInsets.only(left: 20, right: 10);
    final margin = margin0(
      viewportSize: viewportSize,
      viewPadding: viewPadding,
    );
    final width = width0(
      viewportSize: viewportSize,
      dockMargin: margin,
      viewPadding: viewPadding,
    );

    expect(margin, 4);
    expect(width, closeTo(560.0, 0.1));
  });

  test('expanded width remains fixed at the global dock width target', () {
    const viewportSize = Size(800, 1200);
    final margin = margin0(viewportSize: viewportSize);
    final width = width0(viewportSize: viewportSize, dockMargin: margin);

    expect(margin, greaterThan(0));
    expect(width, closeTo(560, 0.1));
    expect(width, lessThan(800));
  });

  test('landscape and portrait keep the same fixed dock width', () {
    const landscapeViewport = Size(800, 600);
    const portraitViewport = Size(800, 1200);
    final landscapeMargin = margin0(viewportSize: landscapeViewport);
    final portraitMargin = margin0(viewportSize: portraitViewport);
    final landscapeWidth = width0(
      viewportSize: landscapeViewport,
      dockMargin: landscapeMargin,
    );
    final portraitWidth = width0(
      viewportSize: portraitViewport,
      dockMargin: portraitMargin,
    );

    expect(landscapeMargin, lessThan(portraitMargin));
    expect(landscapeWidth, closeTo(560, 0.1));
    expect(portraitWidth, closeTo(560, 0.1));
  });

  test('desktop width keeps the same fixed dock width', () {
    const viewportSize = Size(1300, 1200);
    final margin = margin0(viewportSize: viewportSize);
    final width = width0(viewportSize: viewportSize, dockMargin: margin);

    expect(margin, greaterThan(0));
    expect(width, closeTo(560, 0.1));
    expect(width, lessThan(1300));
  });

  test('dock width shrinks only when available width is below fixed width', () {
    const viewportSize = Size(580, 900);
    final margin = margin0(viewportSize: viewportSize);
    final width = width0(viewportSize: viewportSize, dockMargin: margin);
    final available = viewportSize.width - margin * 2;

    expect(available, lessThan(560));
    expect(width, closeTo(available, 0.1));
  });

  test(
    'landscape compact-height threshold is more forgiving than portrait',
    () {
      final landscapeHeight = ChatLayout.maxDockHeight(
        viewportSize: const Size(900, 680),
        viewInsets: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      );
      final portraitHeight = ChatLayout.maxDockHeight(
        viewportSize: const Size(680, 900),
        viewInsets: const EdgeInsets.only(bottom: 220),
        viewPadding: EdgeInsets.zero,
      );

      expect(landscapeHeight, 680);
      expect(portraitHeight, lessThan(680));
    },
  );
}
