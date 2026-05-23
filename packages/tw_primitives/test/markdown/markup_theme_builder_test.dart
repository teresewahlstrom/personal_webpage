import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_primitives/markdown.dart';
import 'package:tw_primitives/src/markdown/markup_rendering.dart'
    show MarkupInlineRendering;

void main() {
  test('buildMarkdownTheme: H2 heading style uses configured scale', () {
    const baseColor = Colors.black;
    const linkColor = Colors.blue;

    final theme = buildMarkdownTheme(
      const MarkdownThemeConfig(
        baseTextColor: baseColor,
        linkColor: linkColor,
        isDark: false,
      ),
    );

    final headingStyle = theme.headingStyleResolver(2);

    expect(
      headingStyle.fontSize,
      closeTo((theme.baseStyle.fontSize ?? 14.0) * 1.36, 0.001),
    );
  });

  test('buildMarkdownTheme: strikethrough thickness is applied by mode', () {
    const baseColor = Colors.black;
    const linkColor = Colors.blue;

    final lightTheme = buildMarkdownTheme(
      const MarkdownThemeConfig(
        baseTextColor: baseColor,
        linkColor: linkColor,
        isDark: false,
      ),
    );
    final darkTheme = buildMarkdownTheme(
      const MarkdownThemeConfig(
        baseTextColor: baseColor,
        linkColor: linkColor,
        isDark: true,
      ),
    );

    const expectedLightThickness = 2.8;
    const expectedDarkThickness = 5.9;

    expect(
      lightTheme.strikethroughStyle.decorationThickness,
      closeTo(expectedLightThickness, 0.001),
    );
    expect(
      darkTheme.strikethroughStyle.decorationThickness,
      closeTo(expectedDarkThickness, 0.001),
    );
    expect(
      _renderedStrikeThickness(lightTheme.strikethroughStyle),
      closeTo(expectedLightThickness * 0.5, 0.001),
    );
    expect(
      _renderedStrikeThickness(darkTheme.strikethroughStyle),
      closeTo(expectedDarkThickness * 0.5, 0.001),
    );
  });
}

double? _renderedStrikeThickness(TextStyle strikeStyle) {
  final theme = MarkupTheme(
    baseStyle: const TextStyle(fontSize: 12),
    strongStyle: const TextStyle(fontWeight: FontWeight.bold),
    emphasisStyle: const TextStyle(fontStyle: FontStyle.italic),
    strikethroughStyle: strikeStyle,
    underlineStyle: const TextStyle(decoration: TextDecoration.underline),
    linkStyle: const TextStyle(color: Colors.blue),
    blockquoteStyle: const TextStyle(fontStyle: FontStyle.italic),
    headingStyleResolver: (int level) => const TextStyle(fontSize: 12),
  );

  final span = const MarkupInline(
    text: 'gone',
    isStrikethrough: true,
  ).toTextSpan(theme: theme, gestureRecognizerFactory: (_) => null);

  return span.style?.decorationThickness;
}
