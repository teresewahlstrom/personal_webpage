import 'package:flutter/material.dart';
import 'package:tw_chat/chat.dart' show ChatSkinMode;

import '../../config/app_ui_config.dart';
import '../arrow_key_scroll_wrapper.dart';
import '_chat_overlay.dart';
import '_grid_background.dart';
import '_page_footer.dart';
import '_page_header.dart';
import '_floating_controls.dart';

/// A reusable widget that combines a grid background with content.
///
/// Use this widget to display content over a grid background pattern.
/// The grid and content are properly layered with IgnorePointer on the grid
/// to allow interaction with content beneath.
class PageScaffold extends StatefulWidget {
  const PageScaffold({
    super.key,
    required this.child,
    this.showThemeToggle = true,
    this.isDarkMode = false,
    this.onToggleTheme,
    this.isPageLoading = false,
    this.showFooter = true,
    this.initialChatSkinMode = ChatSkinMode.light,
  });

  /// The main content to display on top of the grid background.
  final Widget child;

  /// Enables the floating app theme toggle.
  final bool showThemeToggle;

  /// Whether the app is currently in dark mode.
  final bool isDarkMode;

  /// Callback used by the floating toggle to switch app theme.
  final VoidCallback? onToggleTheme;

  /// Whether the page body is still loading and should show a centered loader.
  final bool isPageLoading;

  /// Enables the built-in footer.
  final bool showFooter;

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
      backgroundColor: ShellUiConfig.pageBackgroundFor(brightness),
      gridLineStyle: ShellUiConfig.gridLineFor(brightness),
      child: FadeTransition(
        opacity: _themeFadeOpacity,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                const PageHeader(),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      AbsorbPointer(
                        absorbing: widget.isPageLoading,
                        child: PrimaryScrollController(
                          controller: _pageScrollController,
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(
                              context,
                            ).copyWith(scrollbars: false),
                            child: Scrollbar(
                              controller: _pageScrollController,
                              interactive: true,
                              child: SingleChildScrollView(
                                controller: _pageScrollController,
                                child: ArrowKeyScrollWrapper(
                                  controller: _pageScrollController,
                                  onTap: () {
                                    _pageSelectionAreaKey.currentState
                                        ?.clearSelection();
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      SelectableRegion(
                                        key: _pageSelectionAreaKey,
                                        focusNode: _pageSelectionFocusNode,
                                        selectionControls: Theme.of(context).platform == TargetPlatform.iOS ||
                                            Theme.of(context).platform == TargetPlatform.macOS
                                            ? cupertinoTextSelectionControls
                                            : materialTextSelectionControls,
                                        child: widget.child,
                                      ),
                                      if (widget.showFooter && !widget.isPageLoading)
                                        const PageFooter(
                                          brandName: 'T1 grid',
                                          privacyLabel: 'Privacy & Cookies Note.',
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (widget.isPageLoading)
                        const Center(child: _PageLoadingIndicator()),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.showThemeToggle && widget.onToggleTheme != null)
              Positioned(
                right: mediaQuery.viewPadding.right + floatingInset,
                top: mediaQuery.viewPadding.top + floatingInset,
                child: ThemeToggleControlButton(
                  isDarkMode: widget.isDarkMode,
                  onTap: widget.onToggleTheme!,
                ),
              ),
            if (AppRuntimeConfig.showChatInUi)
              ChatOverlay(
                twinBackendUrl: AppRuntimeConfig.twinBackendUrl,
                chatSkinMode: widget.initialChatSkinMode,
              ),
          ],
        ),
      ),
    );
  }
}

class _PageLoadingIndicator extends StatelessWidget {
  const _PageLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color accent = PagePalette.accentFor(brightness);
    return SizedBox(
      width: 34,
      height: 34,
      child: CircularProgressIndicator(
        strokeWidth: 3.4,
        valueColor: AlwaysStoppedAnimation<Color>(accent),
      ),
    );
  }
}
