import 'package:flutter/material.dart';
import 'package:tw_chat/chat.dart' show ChatLauncherStyle, ChatSkin;
import 'package:tw_primitives/theme.dart';

import '../../config/app_ui_config.dart';

class FloatingControlTokens {
  const FloatingControlTokens._();

  static const Duration animationDuration = Duration(milliseconds: 180);
  static const double idleShadowBlurRadius = 8;
  static const double hoverShadowBlurRadius = 12;
  static const Offset shadowOffset = Offset(0, 3);
  static const double shadowAlpha = 0.12;
}

class FloatingControlInset {
  const FloatingControlInset._();

  static double forViewportWidth(double viewportWidth) {
    if (viewportWidth <= 420) {
      return 10;
    }
    if (viewportWidth <= 640) {
      return 12;
    }
    if (viewportWidth <= 960) {
      return 16;
    }
    return 25;
  }
}

final class FloatingControlVisualStyle {
  const FloatingControlVisualStyle({
    required this.fillColor,
    required this.outlineStyle,
    required this.iconColor,
    required this.glow,
  });

  final Color fillColor;
  final AppLineStyle outlineStyle;
  final Color iconColor;
  final BoxShadow glow;
}

FloatingControlVisualStyle floatingControlVisualStyleFor(BuildContext context) {
  final skin = ChatSkin.dataOf(context);
  final tw = context.twColors;
  return FloatingControlVisualStyle(
    fillColor: Color.lerp(
      tw.pageBackground,
      tw.gridLine,
      tw.cardFillAlpha,
    )!,
    outlineStyle: AppLineStyle(color: tw.gridLine, width: AppLineTheme.subtleWidth),
    iconColor: tw.pageBodyText,
    glow: skin.tokens.shellShadow(skin.colors),
  );
}

class ThemeToggleControlButton extends StatelessWidget {
  const ThemeToggleControlButton({
    super.key,
    required this.isDarkMode,
    required this.onTap,
    this.size,
    this.iconSize = 22,
  });

  final bool isDarkMode;
  final VoidCallback onTap;
  final double? size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final FloatingControlVisualStyle visualStyle =
      floatingControlVisualStyleFor(context);
    final IconData icon = isDarkMode
        ? Icons.light_mode
        : Icons.dark_mode;
    final String tooltip = isDarkMode
        ? 'Switch app to light'
        : 'Switch app to dark';
    final double buttonSize = size ?? ShellUiConfig.headerToggleSize;

    // Use TwLinkPill to keep floating controls visually consistent with
    // markdown/chat pills. Compose a MarkupLinkPillStyle from visual tokens.

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: TwLinkPill(
            label: '',
            leading: Icon(icon, color: visualStyle.iconColor, size: iconSize),
            tooltip: tooltip,
            semanticsLabel: tooltip,
          ),
        ),
      ),
    );
  }
}

ChatLauncherStyle buildChatLauncherStyle(BuildContext context) {
  final FloatingControlVisualStyle visualStyle =
      floatingControlVisualStyleFor(context);
  return ChatLauncherStyle(
    size: ShellUiConfig.headerToggleSize * 1.5,
    iconSize: 30,
    icon: Icons.chat,
    foregroundColor: visualStyle.iconColor,
    hoverForegroundColor: visualStyle.iconColor,
    backgroundColor: visualStyle.fillColor,
    borderColor: visualStyle.outlineStyle.color,
    hoverBorderColor: visualStyle.outlineStyle.color,
    borderWidth: visualStyle.outlineStyle.width,
    animationDuration: FloatingControlTokens.animationDuration,
    idleShadowBlurRadius: FloatingControlTokens.idleShadowBlurRadius,
    hoverShadowBlurRadius: FloatingControlTokens.hoverShadowBlurRadius,
    shadowOffset: FloatingControlTokens.shadowOffset,
    shadowAlpha: FloatingControlTokens.shadowAlpha,
    boxShadow: <BoxShadow>[visualStyle.glow],
  );
}
