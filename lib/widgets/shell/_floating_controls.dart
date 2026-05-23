import 'package:flutter/material.dart';
import 'package:tw_chat/chat.dart' show ChatLauncherStyle, ChatSkin, ChatSkinMode;

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

FloatingControlVisualStyle floatingControlVisualStyleFor(
  Brightness brightness,
) {
  final ChatSkinMode skinMode = brightness == Brightness.dark
      ? ChatSkinMode.dark
      : ChatSkinMode.light;
  final skin = ChatSkin.dataForMode(skinMode);
  return FloatingControlVisualStyle(
    fillColor: ShellUiConfig.projectCardFillFor(brightness),
    outlineStyle: ShellUiConfig.gridLineFor(brightness),
    iconColor: PagePalette.bodyFor(brightness),
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
    final Brightness brightness = Theme.of(context).brightness;
    final FloatingControlVisualStyle visualStyle =
        floatingControlVisualStyleFor(brightness);
    final IconData icon = isDarkMode
        ? Icons.light_mode
        : Icons.dark_mode;
    final String tooltip = isDarkMode
        ? 'Switch app to light'
        : 'Switch app to dark';
    final double buttonSize = size ?? ShellUiConfig.headerToggleSize;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: FloatingControlTokens.animationDuration,
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: visualStyle.fillColor,
              shape: BoxShape.circle,
              border: visualStyle.outlineStyle.borderAll,
              boxShadow: <BoxShadow>[visualStyle.glow],
            ),
            child: Icon(
              icon,
              color: visualStyle.iconColor,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

ChatLauncherStyle buildChatLauncherStyle(Brightness brightness) {
  final FloatingControlVisualStyle visualStyle =
      floatingControlVisualStyleFor(brightness);
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
