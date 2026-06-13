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
      keyboardHeight: 0,
      viewPadding: EdgeInsets.zero,
    );

    expect(height, 620);
  });

  test('compact mode still respects safe area and keyboard insets', () {
    final height = ChatLayout.maxDockHeight(
      viewportSize: const Size(1200, 620),
      keyboardHeight: 20,
      viewPadding: const EdgeInsets.only(top: 24),
    );

    expect(height, 576);
  });

  test('compact mode can reserve a top inset while keyboard is open', () {
    final height = ChatLayout.maxDockHeight(
      viewportSize: const Size(620, 740),
      keyboardHeight: 220,
      viewPadding: EdgeInsets.zero,
      minimumTopInset: 4,
    );

    expect(height, 516);
  });

  test('safe area still wins over a smaller reserved top inset', () {
    final height = ChatLayout.maxDockHeight(
      viewportSize: const Size(620, 740),
      keyboardHeight: 220,
      viewPadding: const EdgeInsets.only(top: 24),
      minimumTopInset: 4,
    );

    expect(height, 496);
  });

  test('height resolves to floating size after compact transition band', () {
    final height = ChatLayout.maxDockHeight(
      viewportSize: const Size(1200, 760),
      keyboardHeight: 0,
      viewPadding: EdgeInsets.zero,
    );

    expect(height, lessThan(760));
    expect(height, greaterThan(ChatLayout.minWindowHeight));
  });

  test('tall desktop viewport keeps floating-height behavior', () {
    final mediumHeight = ChatLayout.maxDockHeight(
      viewportSize: const Size(1200, 760),
      keyboardHeight: 0,
      viewPadding: EdgeInsets.zero,
    );
    final tallHeight = ChatLayout.maxDockHeight(
      viewportSize: const Size(1200, 1000),
      keyboardHeight: 0,
      viewPadding: EdgeInsets.zero,
    );

    expect(tallHeight, greaterThan(mediumHeight));
    expect(tallHeight, lessThan(1000));
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

  test('floating dock height is stable across non-compact widths', () {
    final mediumWidthHeight = ChatLayout.maxDockHeight(
      viewportSize: const Size(700, 900),
      keyboardHeight: 0,
      viewPadding: EdgeInsets.zero,
    );
    final wideWidthHeight = ChatLayout.maxDockHeight(
      viewportSize: const Size(850, 900),
      keyboardHeight: 0,
      viewPadding: EdgeInsets.zero,
    );

    expect(mediumWidthHeight, closeTo(wideWidthHeight, 0.1));
  });

  test('floating dock height ignores landscape and portrait width changes', () {
    final landscapeWidthHeight = ChatLayout.maxDockHeight(
      viewportSize: const Size(1100, 900),
      keyboardHeight: 0,
      viewPadding: EdgeInsets.zero,
    );
    final portraitWidthHeight = ChatLayout.maxDockHeight(
      viewportSize: const Size(700, 900),
      keyboardHeight: 0,
      viewPadding: EdgeInsets.zero,
    );

    expect(landscapeWidthHeight, closeTo(portraitWidthHeight, 0.1));
  });

  test('dock width shrinks only when available width is below fixed width', () {
    const viewportSize = Size(552, 900);
    final margin = margin0(viewportSize: viewportSize);
    final width = width0(viewportSize: viewportSize, dockMargin: margin);
    final available = viewportSize.width - margin * 2;

    expect(available, lessThan(560));
    expect(width, closeTo(available, 0.1));
  });

  test('phone-width layout fills available safe height', () {
    final height = ChatLayout.maxDockHeight(
      viewportSize: const Size(620, 760),
      keyboardHeight: 0,
      viewPadding: EdgeInsets.zero,
    );

    expect(height, lessThanOrEqualTo(760));
    expect(height, greaterThan(700));
  });

  test('layout metrics centralize dock width height and right insets', () {
    final metrics = ChatLayout.resolveMetrics(
      viewportSize: const Size(1200, 1000),
      viewPadding: const EdgeInsets.only(right: 10),
      keyboardHeight: 24,
      minimizedRightInset: 80,
    );

    expect(metrics.expandedDockWidth, closeTo(560, 0.1));
    expect(metrics.maxDockHeight, lessThan(1000));
    expect(metrics.maxDockHeight, greaterThan(ChatLayout.minWindowHeight));
    expect(metrics.expandedRightInset, greaterThan(10));
    expect(metrics.minimizedRightInset, 90);
    expect(metrics.keyboardHeight, 24);
  });
}
