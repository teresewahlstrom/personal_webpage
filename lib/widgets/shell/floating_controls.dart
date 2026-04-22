import 'package:flutter/material.dart';
import 'package:tw_chat/chat.dart';

import '../../config/app_ui_config.dart';

class FloatingControlTokens {
  const FloatingControlTokens._();

  static const Duration animationDuration = Duration(milliseconds: 180);
  static const double idleShadowBlurRadius = 8;
  static const double hoverShadowBlurRadius = 12;
  static const Offset shadowOffset = Offset(0, 3);
  static const double shadowAlpha = 0.12;
}

class ThemeToggleControlButton extends StatefulWidget {
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
  State<ThemeToggleControlButton> createState() =>
      _ThemeToggleControlButtonState();
}

class _ThemeToggleControlButtonState extends State<ThemeToggleControlButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color foregroundColor = _isHovered
        ? ShellUiConfig.headerToggleHoverFor(brightness)
        : ShellUiConfig.headerToggleFor(brightness);
    final AppLineStyle outlineStyle = AppLineTheme.accentFor(
      brightness,
      hovered: _isHovered,
    );
    final IconData icon = widget.isDarkMode ? Icons.light_mode : Icons.dark_mode;
    final String tooltip = widget.isDarkMode
        ? 'Switch app to light'
        : 'Switch app to dark';
    final double buttonSize = widget.size ?? ShellUiConfig.headerToggleSize;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: FloatingControlTokens.animationDuration,
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: ShellUiConfig.headerToggleBackgroundFor(brightness),
              shape: BoxShape.circle,
              border: outlineStyle.borderAll,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: foregroundColor.withValues(
                    alpha: FloatingControlTokens.shadowAlpha,
                  ),
                  blurRadius: _isHovered
                      ? FloatingControlTokens.hoverShadowBlurRadius
                      : FloatingControlTokens.idleShadowBlurRadius,
                  offset: FloatingControlTokens.shadowOffset,
                ),
              ],
            ),
            child: Icon(icon, color: foregroundColor, size: widget.iconSize),
          ),
        ),
      ),
    );
  }
}

ChatLauncherStyle buildChatLauncherStyle(Brightness brightness) {
  return ChatLauncherStyle(
    size: ShellUiConfig.headerToggleSize * 1.5,
    iconSize: 30,
    icon: Icons.chat,
    foregroundColor: ShellUiConfig.headerToggleFor(brightness),
    hoverForegroundColor: ShellUiConfig.headerToggleHoverFor(brightness),
    backgroundColor: ShellUiConfig.headerToggleBackgroundFor(brightness),
    borderWidth: 1,
    animationDuration: FloatingControlTokens.animationDuration,
    idleShadowBlurRadius: FloatingControlTokens.idleShadowBlurRadius,
    hoverShadowBlurRadius: FloatingControlTokens.hoverShadowBlurRadius,
    shadowOffset: FloatingControlTokens.shadowOffset,
    shadowAlpha: FloatingControlTokens.shadowAlpha,
  );
}
