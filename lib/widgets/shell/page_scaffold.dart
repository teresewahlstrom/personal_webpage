import 'package:flutter/material.dart';
import 'package:tw_chat/chat.dart' show ChatSkinMode;

import '../../config/app_ui_config.dart';
import '../arrow_key_scroll_wrapper.dart';
import '_chat_overlay.dart';
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
    this.showTwinChat = true,
    this.showFooter = true,
    this.footerBrandName = 'T1 grid',
    this.footerPrivacyLabel = 'Privacy & Cookies Note.',
    this.twinBackendUrl = AppRuntimeConfig.twinBackendUrl,
    this.gridColor = ShellUiConfig.pageBackgroundColor,
    this.gridLineColor = ShellUiConfig.gridLineColor,
    this.initialChatSkinMode = ChatSkinMode.light,
  });

  /// The main content to display on top of the grid background.
  final Widget child;

  /// Optional floating layers rendered above page content (for docks/overlays).
  final List<Widget> overlays;

  /// Enables the built-in header.
  final bool showHeader;

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
  final Color gridColor;

  /// Color of the grid lines.
  final Color gridLineColor;

  /// Initial skin mode used by the twin chat widget.
  final ChatSkinMode initialChatSkinMode;

  @override
  State<PageScaffold> createState() => _PageScaffoldState();
}

class _PageScaffoldState extends State<PageScaffold> {
  late ChatSkinMode _chatSkinMode;
  final ScrollController _pageScrollController = ScrollController();
  final GlobalKey<SelectableRegionState> _pageSelectionAreaKey =
      GlobalKey<SelectableRegionState>();
  final FocusNode _pageSelectionFocusNode = FocusNode(
    debugLabel: 'page-selectable-region',
  );

  bool get _isChatDarkMode => _chatSkinMode == ChatSkinMode.dark;

  bool get _showChatThemeToggle =>
      widget.showTwinChat && AppRuntimeConfig.showChatInUi;

  @override
  void initState() {
    super.initState();
    _chatSkinMode = widget.initialChatSkinMode;
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    _pageSelectionFocusNode.dispose();
    super.dispose();
  }

  void _toggleChatTheme() {
    setState(() {
      _chatSkinMode = _isChatDarkMode ? ChatSkinMode.light : ChatSkinMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridBackground(
      backgroundColor: widget.gridColor,
      gridLineColor: widget.gridLineColor,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              if (widget.showHeader)
                PageHeader(
                  showThemeToggle: _showChatThemeToggle,
                  isDarkMode: _isChatDarkMode,
                  onToggleTheme: _showChatThemeToggle ? _toggleChatTheme : null,
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
          if (widget.showTwinChat && AppRuntimeConfig.showChatInUi)
            TwinChatOverlay(
              twinBackendUrl: widget.twinBackendUrl,
              chatSkinMode: _chatSkinMode,
            ),
        ],
      ),
    );
  }
}
