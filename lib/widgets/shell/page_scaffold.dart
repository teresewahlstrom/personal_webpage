import 'package:flutter/material.dart';
import 'package:tw_chat/chat.dart'
    show
        ChatKeyboardScrollTargetController,
        ChatLayout,
        ChatOverlay,
        ChatSkin,
        ChatSkinMode;
import 'package:flutter/rendering.dart' show SelectedContent;
import 'package:tw_primitives/theme.dart' show TwColorsBuildContextExtension;
import 'package:tw_primitives/scrollbar.dart'
    show TwSelectableScrollArea, TwSelectableRegionState;
import 'package:tw_primitives/markdown.dart' show MarkupSelectionCopyHelper;

import '../../config/app_ui_config.dart';
import '../selection_copy_interceptor.dart';
import '_grid_background.dart';
import '_page_footer.dart';
import 'page_header.dart';
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

  static void clearPageSelection(BuildContext context) {
    final _PageScaffoldState? state = context
        .findAncestorStateOfType<_PageScaffoldState>();
    state?._clearPageSelection();
  }

  @override
  State<PageScaffold> createState() => _PageScaffoldState();
}

class _PageScaffoldState extends State<PageScaffold> {
  final ScrollController _pageScrollController = ScrollController();
  late final ChatKeyboardScrollTargetController
  _chatKeyboardScrollTargetController;
  final GlobalKey<TwSelectableRegionState> _pageSelectionAreaKey =
      GlobalKey<TwSelectableRegionState>();
  final FocusNode _pageInteractionFocusNode = FocusNode(
    debugLabel: 'page-scroll-interaction',
  );

  final GlobalKey<SelectionCopyInterceptorState> _copyInterceptorKey =
      GlobalKey<SelectionCopyInterceptorState>();

  @override
  void initState() {
    super.initState();
    _chatKeyboardScrollTargetController = ChatKeyboardScrollTargetController();
  }

  void _clearPageSelection() {
    _pageSelectionAreaKey.currentState?.clearSelection();
  }

  @visibleForTesting
  MarkupSelectionCopyHelper get pageCopyHelper =>
      _copyInterceptorKey.currentState!.copyHelper;

  @visibleForTesting
  GlobalKey<TwSelectableRegionState> get pageSelectionAreaKey => _pageSelectionAreaKey;

  @visibleForTesting
  SelectedContent? get lastSelectedContent =>
      _copyInterceptorKey.currentState!.lastSelectedContent;

  @override
  void dispose() {
    _pageScrollController.dispose();
    _chatKeyboardScrollTargetController.dispose();
    _pageInteractionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatSkin = ChatSkin.dataForMode(widget.initialChatSkinMode);
    final chatTokens = chatSkin.tokens;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Widget? footer = widget.showFooter && !widget.isPageLoading
        ? const PageFooter(
            brandName: 'T1 grid',
            privacyLabel: 'Privacy & Cookies Note.',
          )
        : null;
    final double floatingInset = FloatingControlInset.forViewportWidth(
      mediaQuery.size.width,
    );
    return GridBackground(
      backgroundColor: context.twColors.pageBackground,
      backgroundColorBottom: context.twColors.pageBackgroundBottom,
      gridLineStyle: AppLineStyle(
        color: context.twColors.gridLine,
        width: AppLineTheme.subtleWidth,
      ),
      grainColor: context.twColors.grainColor,
      child: SelectionCopyInterceptor(
        key: _copyInterceptorKey,
        shouldInterceptCopy: () {
          final isChatFocused = _chatKeyboardScrollTargetController.isChatTargetListenable.value;
          return !isChatFocused;
        },
        builder: (BuildContext context, ValueChanged<SelectedContent?> onSelectionChanged) {
          return Stack(
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
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return TwSelectableScrollArea.scrollView(
                                  controller: _pageScrollController,
                                  selectionKey: _pageSelectionAreaKey,
                                  interactionFocusNode: _pageInteractionFocusNode,
                                  onSelectionChanged: onSelectionChanged,
                                  isKeyboardScrollBlocked:
                                      _chatKeyboardScrollTargetController
                                          .isChatTargetListenable,
                                  onPointerDown: () {
                                    _chatKeyboardScrollTargetController
                                        .setChatTarget(false);
                                  },
                                  thumbColor: context.twColors.pageScrollbarThumb,
                                  thumbInactiveColor:
                                      context.twColors.pageScrollbarThumbInactive,
                                  thickness: ShellUiConfig.pageScrollbarThickness,
                                  minThumbLength:
                                      chatTokens.scrollbarMinThumbLength,
                                  crossAxisMargin:
                                      ShellUiConfig.pageScrollbarCrossAxisMargin,
                                  radius: chatTokens.scrollbarRadius,
                                  thumbVisibility: true,
                                  interactive: true,
                                  contentPhysics: const ClampingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics(),
                                  ),
                                  scrollbarDragPhysics:
                                      const ClampingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics(),
                                  ),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight,
                                    ),
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
                                );
                              },
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
                Builder(
                  builder: (context) {
                    final double keyboardHeight = mediaQuery.viewInsets.bottom;
                    final double minimizedBottomOffset = floatingInset;
                    final double launcherSize = ShellUiConfig.headerToggleSize * 1.5;
                    final double themeToggleSize = ShellUiConfig.headerToggleSize;
                    const double themeToggleGap = 12.0;

                    final bool hasChat = AppRuntimeConfig.showChatInUi;
                    final chatMargin = ChatLayout.dockHorizontalMargin(
                      viewportSize: mediaQuery.size,
                      viewPadding: mediaQuery.viewPadding,
                    );
                    final double minimizedRightInset = mediaQuery.viewPadding.right +
                        (chatMargin > floatingInset ? chatMargin : floatingInset);

                    final double rightOffset = minimizedRightInset +
                        (hasChat ? (launcherSize - themeToggleSize) / 2 : 0.0);
                    final double bottomOffset = keyboardHeight +
                        minimizedBottomOffset +
                        (hasChat ? (launcherSize + themeToggleGap) : 0.0);

                    return Positioned(
                      right: rightOffset,
                      bottom: bottomOffset,
                      child: ThemeToggleControlButton(
                        isDarkMode: widget.isDarkMode,
                        onTap: widget.onToggleTheme!,
                      ),
                    );
                  },
                ),
              if (AppRuntimeConfig.showChatInUi)
                ChatOverlay(
                  backendUrl: AppRuntimeConfig.twinBackendUrl,
                  useBackend: AppRuntimeConfig.useChatBackend,
                  backendDisabledReply: AppRuntimeConfig.backendDisabledReply,
                  keyboardScrollTargetController:
                      _chatKeyboardScrollTargetController,
                  chatSkinMode: widget.initialChatSkinMode,
                  onChatInteractionClaimed: _clearPageSelection,
                  minimizedBottomOffset: floatingInset,
                  minimizedRightInset: floatingInset,
                  launcherStyle: buildChatLauncherStyle(context),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PageLoadingIndicator extends StatelessWidget {
  const _PageLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    final Color accent = context.twColors.pageLoader;
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
