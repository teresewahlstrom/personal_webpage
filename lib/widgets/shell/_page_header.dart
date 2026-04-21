import 'package:flutter/material.dart';

import '../../config/app_ui_config.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    this.logoAssetPath = 'assets/images/logo.png',
    this.showThemeToggle = false,
    this.isDarkMode = false,
    this.onToggleTheme,
  });

  final String logoAssetPath;
  final bool showThemeToggle;
  final bool isDarkMode;
  final VoidCallback? onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: ShellUiConfig.headerMinHeight,
      ),
      padding: ShellUiConfig.headerPadding,
      decoration: BoxDecoration(
        color: ShellUiConfig.headerBackgroundFor(brightness),
        border: Border(
          bottom: BorderSide(
            color: ShellUiConfig.headerBorderFor(brightness),
            width: 2,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: ShellUiConfig.headerMaxWidth,
          ),
          child: Row(
            children: <Widget>[
              Image.asset(
                logoAssetPath,
                width: ShellUiConfig.headerLogoWidth,
                height: ShellUiConfig.headerLogoHeight,
                fit: BoxFit.contain,
              ),
              const Spacer(),
              if (showThemeToggle && onToggleTheme != null)
                _HeaderThemeButton(
                  isDarkMode: isDarkMode,
                  onTap: onToggleTheme!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderThemeButton extends StatefulWidget {
  const _HeaderThemeButton({
    required this.isDarkMode,
    required this.onTap,
  });

  final bool isDarkMode;
  final VoidCallback onTap;

  @override
  State<_HeaderThemeButton> createState() => _HeaderThemeButtonState();
}

class _HeaderThemeButtonState extends State<_HeaderThemeButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color foregroundColor = _isHovered
      ? ShellUiConfig.headerToggleHoverFor(brightness)
      : ShellUiConfig.headerToggleFor(brightness);
    final IconData icon = widget.isDarkMode
        ? Icons.light_mode_outlined
        : Icons.dark_mode_outlined;
    final String tooltip = widget.isDarkMode
      ? 'Switch app to light'
      : 'Switch app to dark';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: ShellUiConfig.headerToggleSize,
            height: ShellUiConfig.headerToggleSize,
            decoration: BoxDecoration(
              color: ShellUiConfig.headerToggleBackgroundFor(brightness),
              shape: BoxShape.circle,
              border: Border.all(color: foregroundColor, width: 1),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: foregroundColor.withValues(alpha: 0.12),
                  blurRadius: _isHovered ? 12 : 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: foregroundColor, size: 22),
          ),
        ),
      ),
    );
  }
}