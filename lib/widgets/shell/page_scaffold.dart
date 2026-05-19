import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tw_chat/chat.dart' show ChatSkin, ChatSkinMode;
import 'package:tw_primitives/scrollbar.dart' show TwScrollArea;

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

class _PageScaffoldState extends State<PageScaffold> {
  final ScrollController _pageScrollController = ScrollController();
  final GlobalKey<SelectableRegionState> _pageSelectionAreaKey =
      GlobalKey<SelectableRegionState>();
  final FocusNode _pageSelectionFocusNode = FocusNode(
    debugLabel: 'page-selectable-region',
  );

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    _pageScrollController.dispose();
    _pageSelectionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Brightness brightness = theme.brightness;
    final TargetPlatform platform = theme.platform;
    final chatSkin = ChatSkin.dataForMode(widget.initialChatSkinMode);
    final chatTokens = chatSkin.tokens;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Widget? footer = widget.showFooter && !widget.isPageLoading
        ? const PageFooter(
            brandName: 'T1 grid',
            privacyLabel: 'Privacy & Cookies Note.',
          )
        : null;
    final double floatingTopInset = mediaQuery.viewPadding.top + 10.0;
    return GridBackground(
      backgroundColor: ShellUiConfig.pageBackgroundFor(brightness),
      gridLineStyle: ShellUiConfig.gridLineFor(brightness),
      child: Stack(
          children: <Widget>[
            SafeArea(
              bottom: true,
              top: false,
              left: false,
              right: false,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        AbsorbPointer(
                          absorbing: widget.isPageLoading,
                          child: PrimaryScrollController(
                            controller: _pageScrollController,
                            child: SelectableRegion(
                              key: _pageSelectionAreaKey,
                              focusNode: _pageSelectionFocusNode,
                              selectionControls: platform == TargetPlatform.iOS ||
                                  platform == TargetPlatform.macOS
                                  ? cupertinoTextSelectionControls
                                  : materialTextSelectionControls,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return TwScrollArea.scrollView(
                                    controller: _pageScrollController,
                                    thumbColor:
                                      ShellUiConfig.pageScrollbarThumbFor(brightness),
                                    thumbInactiveColor:
                                      ShellUiConfig.pageScrollbarThumbInactiveFor(brightness),
                                    trackColor:
                                      ShellUiConfig.pageScrollbarTrackFor(brightness),
                                    thickness:
                                      ShellUiConfig.pageScrollbarThickness,
                                    minThumbLength:
                                        chatTokens.scrollbarMinThumbLength,
                                    crossAxisMargin:
                                        ShellUiConfig.pageScrollbarCrossAxisMargin,
                                    radius: chatTokens.scrollbarRadius,
                                    thumbVisibility: true,
                                    interactive: true,
                                    trackVisibility: false,
                                    physics: ScrollConfiguration.of(
                                      context,
                                    ).getScrollPhysics(context),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight,
                                      ),
                                      child: ArrowKeyScrollWrapper(
                                        controller: _pageScrollController,
                                        onTap: () {
                                          _pageSelectionAreaKey.currentState
                                              ?.clearSelection();
                                        },
                                        child: Column(
                                          mainAxisAlignment: footer != null
                                              ? MainAxisAlignment.spaceBetween
                                              : MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: <Widget>[
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                const PageHeader(),
                                                widget.child,
                                              ],
                                            ),
                                            ...[footer].whereType<Widget>(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
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
            ),
            if (widget.showThemeToggle && widget.onToggleTheme != null)
              Positioned(
                right: mediaQuery.viewPadding.right + 10.0,
                top: floatingTopInset,
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
