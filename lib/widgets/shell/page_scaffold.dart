import 'package:flutter/material.dart';
import 'package:tw_chat/chat.dart' show ChatSkinMode;

import '../../config/app_ui_config.dart';
import '../arrow_key_scroll_wrapper.dart';
import '_chat_overlay.dart';
import 'floating_control_inset.dart';
import '_grid_background.dart';
import '_page_footer.dart';
import '_page_header.dart';

/// A reusable widget that combines a grid background with content.
///
/// Use this widget to display content over a grid background pattern.
/// The grid and content are properly layered with IgnorePointer on the grid
/// to allow interaction with content beneath.
class PageScaffold extends StatefulWidget {
  const PageScaffold({
    super.key,
    required this.child,
    this.overlays = const <Widget>[],
    this.showHeader = true,
    this.showThemeToggle = true,
    this.isDarkMode = false,
    this.onToggleTheme,
    this.showTwinChat = true,
    this.showFooter = true,
    this.footerBrandName = 'T1 grid',
    this.footerPrivacyLabel = 'Privacy & Cookies Note.',
    this.twinBackendUrl = AppRuntimeConfig.twinBackendUrl,
    this.gridColor,
    this.gridLineStyle,
    this.initialChatSkinMode = ChatSkinMode.light,
  });

  /// The main content to display on top of the grid background.
  final Widget child;

  /// Optional floating layers rendered above page content (for docks/overlays).
  final List<Widget> overlays;

  /// Enables the built-in header.
  final bool showHeader;

  /// Enables the app theme toggle in the header.
  final bool showThemeToggle;

  /// Whether the app is currently in dark mode.
  final bool isDarkMode;

  /// Callback used by the header toggle to switch app theme.
  final VoidCallback? onToggleTheme;

  /// Enables the built-in twin chat dock overlay.
  final bool showTwinChat;

  /// Enables the built-in footer.
  final bool showFooter;

  /// Footer brand label shown in copyright line.
  final String footerBrandName;

  /// Footer link label.
  final String footerPrivacyLabel;

  /// Backend URL used by the built-in twin chat dock.
  final String twinBackendUrl;

  /// Background color of the grid.
  final Color? gridColor;

  /// Style of the grid lines.
  final AppLineStyle? gridLineStyle;

  /// Initial skin mode used by the twin chat widget.
  final ChatSkinMode initialChatSkinMode;

  @override
  State<PageScaffold> createState() => _PageScaffoldState();
}

class _PageScaffoldState extends State<PageScaffold>
    with SingleTickerProviderStateMixin {
  final ScrollController _pageScrollController = ScrollController();
  final GlobalKey<SelectableRegionState> _pageSelectionAreaKey =
      GlobalKey<SelectableRegionState>();
  final FocusNode _pageSelectionFocusNode = FocusNode(
    debugLabel: 'page-selectable-region',
  );
  late final AnimationController _themeFadeController;
  late final Animation<double> _themeFadeOpacity;

  @override
  void initState() {
    super.initState();
    _themeFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..value = 1;
    _themeFadeOpacity = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1,
          end: 0.88,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 45,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0.88,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 55,
      ),
    ]).animate(_themeFadeController);
  }

  @override
  void didUpdateWidget(covariant PageScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      _themeFadeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    _pageSelectionFocusNode.dispose();
    _themeFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double floatingInset = FloatingControlInset.forViewportWidth(
      mediaQuery.size.width,
    );
    return GridBackground(
      backgroundColor:
          widget.gridColor ?? ShellUiConfig.pageBackgroundFor(brightness),
      gridLineStyle:
        widget.gridLineStyle ?? ShellUiConfig.gridLineFor(brightness),
      child: FadeTransition(
        opacity: _themeFadeOpacity,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                if (widget.showHeader)
                  PageHeader(
                    showThemeToggle: false,
                    isDarkMode: widget.isDarkMode,
                    onToggleTheme: widget.onToggleTheme,
                  ),
                Expanded(
                  child: ArrowKeyScrollWrapper(
                    controller: _pageScrollController,
                    onPointerDown: () {
                      _pageSelectionAreaKey.currentState?.clearSelection();
                    },
                    child: SingleChildScrollView(
                      controller: _pageScrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SelectableRegion(
                            key: _pageSelectionAreaKey,
                            focusNode: _pageSelectionFocusNode,
                            selectionControls: materialTextSelectionControls,
                            child: widget.child,
                          ),
                          if (widget.showFooter)
                            PageFooter(
                              brandName: widget.footerBrandName,
                              privacyLabel: widget.footerPrivacyLabel,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ...widget.overlays,
            if (widget.showThemeToggle && widget.onToggleTheme != null)
              Positioned(
                right: mediaQuery.viewPadding.right + floatingInset,
                top: mediaQuery.viewPadding.top + floatingInset,
                child: _FloatingThemeToggle(
                  isDarkMode: widget.isDarkMode,
                  onTap: widget.onToggleTheme!,
                ),
              ),
            if (widget.showTwinChat && AppRuntimeConfig.showChatInUi)
              TwinChatOverlay(
                twinBackendUrl: widget.twinBackendUrl,
                chatSkinMode: widget.initialChatSkinMode,
              ),
          ],
        ),
      ),
    );
  }
}

class _FloatingThemeToggle extends StatefulWidget {
  const _FloatingThemeToggle({required this.isDarkMode, required this.onTap});

  final bool isDarkMode;
  final VoidCallback onTap;

  @override
  State<_FloatingThemeToggle> createState() => _FloatingThemeToggleState();
}

class _FloatingThemeToggleState extends State<_FloatingThemeToggle> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color foregroundColor = _isHovered
        ? ShellUiConfig.headerToggleHoverFor(brightness)
        : ShellUiConfig.headerToggleFor(brightness);
    final AppLineStyle outlineStyle = AppLineTheme.accent1For(
      brightness,
      hovered: _isHovered,
    );
    final IconData icon = widget.isDarkMode
        ? Icons.light_mode
        : Icons.dark_mode;
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
              border: outlineStyle.borderAll,
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
