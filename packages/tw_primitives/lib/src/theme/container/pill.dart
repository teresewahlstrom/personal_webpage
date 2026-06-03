import 'package:flutter/material.dart';
import '../../theme/text_styles/router.dart';
import '../../theme/colors/router.dart';

// Local canonical pill tokens (kept here so the pill widget owns its
// presentation defaults). These mirror the values used by the markdown
// tokens but live next to the widget for easier discovery.
const EdgeInsets kTwLinkPillDefaultPadding = EdgeInsets.symmetric(
  horizontal: 6,
  vertical: 2,
);
const double kTwLinkPillDefaultBorderWidth = 1.0;
const double kTwLinkPillFillLerpTLight = 0.70;
const double kTwLinkPillFillLerpTDark = 0.65;

class TwLinkPillStyle {
  const TwLinkPillStyle({
    required this.fillColor,
    required this.borderColor,
    required this.textStyle,
    this.borderWidth = 1.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    this.shadows = const <BoxShadow>[],
  });

  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final List<BoxShadow> shadows;
  final TextStyle textStyle;

  TwLinkPillStyle copyWith({
    Color? fillColor,
    Color? borderColor,
    double? borderWidth,
    EdgeInsetsGeometry? padding,
    List<BoxShadow>? shadows,
    TextStyle? textStyle,
  }) {
    return TwLinkPillStyle(
      fillColor: fillColor ?? this.fillColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      padding: padding ?? this.padding,
      shadows: shadows ?? this.shadows,
      textStyle: textStyle ?? this.textStyle,
    );
  }
}

// Compute the canonical default `TwLinkPillStyle` for the given brightness
// and text scale. This is the single source of truth used by both the
// `TwLinkPill` widget and the markdown theme builder to ensure consistent
// visuals across callers.
TwLinkPillStyle computeDefaultTwLinkPillStyle({
  required Brightness brightness,
  double textScale = 1.0,
}) {
  final bool isDark = brightness == Brightness.dark;
  final TwColors colors = TwColors.forBrightness(
    isDark ? Brightness.dark : Brightness.light,
  );

  final double lerpT = isDark
      ? kTwLinkPillFillLerpTDark
      : kTwLinkPillFillLerpTLight;
  final Color fill =
      Color.lerp(colors.shellBackground, colors.shellDivider, lerpT) ??
      colors.composerFill;
  final Color border = colors.composerBorder;

  final List<BoxShadow> shadows = <BoxShadow>[
    BoxShadow(
      color: colors.bubbleShadow.withValues(
        alpha: colors.bubbleShadow.a * 0.25,
      ),
      blurRadius: 8,
      spreadRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  // Derive pill text style similarly to the markdown builder.
  final Brightness twBrightness = brightness;
  final TextStyle base = TwTextStyles.forBrightness(
    twBrightness,
  ).bodyForContextless(color: colors.pageBodyText, textScale: textScale);
  final TextStyle small = TwTextStyles.forBrightness(
    twBrightness,
  ).smallFrom(base);
  final TextStyle textStyle = TwTextStyles.forBrightness(
    twBrightness,
  ).adaptBase(small, color: colors.bubbleText);

  return TwLinkPillStyle(
    fillColor: fill,
    borderColor: border,
    borderWidth: kTwLinkPillDefaultBorderWidth,
    padding: kTwLinkPillDefaultPadding,
    textStyle: textStyle,
    shadows: shadows,
  );
}

/// A shared, canonical link-pill widget used by markdown and chat.
///
/// Uses `MarkupViewStyle` tokens as the source of truth for padding,
/// border width, lerp values and shadows. Consumers can provide a
/// custom [TwLinkPillStyle] to override appearance.
class TwLinkPill extends StatelessWidget {
  const TwLinkPill({
    Key? key,
    required this.label,
    this.onTap,
    this.leading,
    this.brightness,
    this.textScale,
    this.style,
    this.tooltip,
    this.tooltipVisible = true,
    this.semanticsLabel,
    this.clickable,
  }) : _externalKey = key,
       super(key: null);

  final Key? _externalKey;

  final String label;
  final VoidCallback? onTap;
  final Widget? leading;

  // Optional inputs to influence internal style derivation. Prefer leaving
  // these null so the pill derives canonical colors and text from
  // `TwColors` and `TwTextStyles` according to brightness/scale.
  final Brightness? brightness;
  final double? textScale;

  // Internal override (kept for internal callers that have a MarkupLinkPillStyle).
  final TwLinkPillStyle? style;
  final String? tooltip;
  final bool tooltipVisible;
  final String? semanticsLabel;
  final bool? clickable;

  TwLinkPillStyle _resolveDefault(BuildContext context) {
    final Brightness resolvedBrightness =
        brightness ?? Theme.of(context).brightness;
    final double resolvedScale = textScale ?? 1.0;
    return computeDefaultTwLinkPillStyle(
      brightness: resolvedBrightness,
      textScale: resolvedScale,
    );
  }

  @override
  Widget build(BuildContext context) {
    final TwLinkPillStyle base = style ?? _resolveDefault(context);
    final TwLinkPillStyle resolved = base;

    // Use zero padding for icon-only pills so they can become perfectly
    // circular when wrapped in a fixed-size parent (e.g., SizedBox.square).
    final EdgeInsetsGeometry effectivePadding = label.isEmpty
        ? EdgeInsets.zero
        : resolved.padding;

    final ShapeDecoration decoration = ShapeDecoration(
      color: resolved.fillColor,
      shape: StadiumBorder(
        side: BorderSide(
          color: resolved.borderColor,
          width: resolved.borderWidth,
        ),
      ),
    );

    final bool isClickable = clickable ?? (onTap != null);

    Widget innerContent = Padding(
      padding: effectivePadding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null)
            IconTheme(
              data: IconThemeData(
                color: resolved.textStyle.color,
                size: resolved.textStyle.fontSize,
              ),
              child: leading!,
            ),
          if (leading != null && label.isNotEmpty) const SizedBox(width: 8),
          if (label.isNotEmpty)
            Text(
              label,
              style: resolved.textStyle.copyWith(
                decoration:
                    resolved.textStyle.decoration ?? TextDecoration.none,
              ),
              strutStyle: const StrutStyle(
                forceStrutHeight: true,
                height: 1.0,
              ),
            ),
        ],
      ),
    );

    Widget content;
    if (isClickable) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(9999),
          child: innerContent,
        ),
      );
    } else {
      content = innerContent;
    }

    // Draw the pill decoration at the top-level so tests and callers can
    // inspect a DecoratedBox when the key is placed on the pill widget.
    // For icon-only pills (no label) ensure the content is centered so
    // a surrounding fixed-size parent produces a perfectly circular pill
    // with the icon centered inside it.
    if (label.isEmpty) {
      content = Center(child: content);
    }
    content = DecoratedBox(
      key: _externalKey,
      decoration: decoration,
      child: content,
    );

    // Optionally provide semantics label for accessibility.
    if (semanticsLabel != null && semanticsLabel!.isNotEmpty) {
      content = Semantics(button: isClickable, label: semanticsLabel, child: content);
    }

    // Optionally show a tooltip (wrapped outside semantics to avoid
    // altering semantics label precedence).
    if (tooltip != null && tooltipVisible) {
      content = Tooltip(message: tooltip!, child: content);
    }

    // Ensure link-pill shows a click cursor for hover affordance.
    return MouseRegion(
      cursor: isClickable ? SystemMouseCursors.click : MouseCursor.defer,
      child: content,
    );
  }
}
