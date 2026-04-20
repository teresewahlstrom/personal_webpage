import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/config.dart';
import '../models/message.dart';
import 'section.dart';

enum ChatDockDisplayState { minimized, expanded }

class TwinChatDock extends StatefulWidget {
  const TwinChatDock({
    super.key,
    required this.messages,
    required this.onSend,
    required this.onStop,
    required this.isChatKeyboardScrollTarget,
    required this.onSetChatKeyboardScrollTarget,
    required this.onSetPageKeyboardScrollTarget,
  });

  final List<ChatMessage> messages;
  final void Function(String text) onSend;
  final VoidCallback onStop;
  final ValueListenable<bool> isChatKeyboardScrollTarget;
  final VoidCallback onSetChatKeyboardScrollTarget;
  final VoidCallback onSetPageKeyboardScrollTarget;

  @override
  State<TwinChatDock> createState() => _TwinChatDockState();
}

class _TwinChatDockState extends State<TwinChatDock> {
  ChatDockDisplayState _displayState = ChatDockDisplayState.minimized;

  bool get _isExpanded => _displayState == ChatDockDisplayState.expanded;

  void _expandChat() {
    widget.onSetChatKeyboardScrollTarget();
    setState(() => _displayState = ChatDockDisplayState.expanded);
  }

  void _minimizeChat() {
    widget.onSetPageKeyboardScrollTarget();
    setState(() => _displayState = ChatDockDisplayState.minimized);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewportSize = mediaQuery.size;
    final chatMargin = ChatLayout.dockHorizontalMargin(
      viewportSize: viewportSize,
      viewPadding: mediaQuery.viewPadding,
    );
    final floatingChatWidth = ChatLayout.expandedDockWidth(
      viewportSize: viewportSize,
      viewPadding: mediaQuery.viewPadding,
      dockHorizontalMargin: chatMargin,
    );
    final availableChatHeight = ChatLayout.maxDockHeight(
      viewportSize: viewportSize,
      viewInsets: mediaQuery.viewInsets,
      viewPadding: mediaQuery.viewPadding,
    );

    return Positioned(
      right: mediaQuery.viewPadding.right + chatMargin,
      bottom: mediaQuery.viewInsets.bottom,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          TickerMode(
            enabled: _isExpanded,
            child: ExcludeFocus(
              excluding: !_isExpanded,
              child: Offstage(
                offstage: !_isExpanded,
                child: SizedBox(
                  width: floatingChatWidth,
                  child: FloatingChatWindow(
                    messages: widget.messages,
                    onSend: widget.onSend,
                    onStop: widget.onStop,
                    isChatKeyboardScrollTarget:
                        widget.isChatKeyboardScrollTarget,
                    onSetChatKeyboardScrollTarget:
                        widget.onSetChatKeyboardScrollTarget,
                    maxHeight: availableChatHeight,
                    isVisible: _isExpanded,
                    onMinimize: _minimizeChat,
                  ),
                ),
              ),
            ),
          ),
          Offstage(
            offstage: _isExpanded,
            child: MinimizedChatLauncher(
              onSetChatKeyboardScrollTarget:
                  widget.onSetChatKeyboardScrollTarget,
              onExpand: _expandChat,
            ),
          ),
        ],
      ),
    );
  }
}

class TwinChatAppBar extends StatelessWidget {
  const TwinChatAppBar({
    super.key,
    required this.onDisplayStateToggle,
    required this.displayStateToggleIcon,
    required this.displayStateToggleTooltip,
    this.shrinkWrap = false,
  });

  final VoidCallback onDisplayStateToggle;
  final IconData displayStateToggleIcon;
  final String displayStateToggleTooltip;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final titleStyle = ChatTextStyles.appBarTitleStyle(textScale);
    final headerRadius = shrinkWrap
        ? ChatTokens.headerRadiusMinimized
        : ChatTokens.headerRadiusExpanded;
    final iconColor =
        titleStyle.color ??
        DefaultTextStyle.of(context).style.color ??
        Theme.of(context).textTheme.titleMedium?.color ??
        ChatColors.bubbleText;
    final pad = shrinkWrap
        ? ChatTokens.appBarPaddingMinimized
        : ChatTokens.appBarPaddingExpanded;
    final titleArea = Padding(
      padding: EdgeInsets.fromLTRB(
        pad.left + ChatTokens.appBarLeadingGap,
        pad.top,
        ChatTokens.appBarActionGap + ChatTokens.appBarActionWidth,
        pad.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text('Chat with Twin', style: titleStyle)],
      ),
    );
    final action = Positioned(
      top: 0,
      right: 0,
      bottom: 0,
      width: ChatTokens.appBarActionWidth,
      child: Material(
        color: ChatColors.transparent,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(headerRadius),
        ),
        child: Tooltip(
          message: displayStateToggleTooltip,
          child: InkWell(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(headerRadius),
            ),
            onTap: onDisplayStateToggle,
            child: Center(
              child: Icon(displayStateToggleIcon, color: iconColor),
            ),
          ),
        ),
      ),
    );

    if (shrinkWrap) {
      return Stack(children: [titleArea, action]);
    }

    return SizedBox(
      width: double.infinity,
      child: Stack(children: [titleArea, action]),
    );
  }
}

class MinimizedChatLauncher extends StatelessWidget {
  const MinimizedChatLauncher({
    super.key,
    required this.onSetChatKeyboardScrollTarget,
    required this.onExpand,
  });

  final VoidCallback onSetChatKeyboardScrollTarget;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ChatColors.transparent,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => onSetChatKeyboardScrollTarget(),
        child: InkWell(
          onTap: onExpand,
          borderRadius: ChatTokens.shellBorderRadiusMinimized,
          child: Container(
            decoration: _chatShellDecoration(
              borderRadius: ChatTokens.shellBorderRadiusMinimized,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF6BA3D6),
                borderRadius: ChatTokens.shellBorderRadiusMinimized,
              ),
              child: TwinChatAppBar(
                onDisplayStateToggle: onExpand,
                displayStateToggleIcon: Icons.expand_less_rounded,
                displayStateToggleTooltip: 'Expand chat',
                shrinkWrap: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FloatingChatWindow extends StatelessWidget {
  const FloatingChatWindow({
    super.key,
    required this.messages,
    required this.onSend,
    required this.onStop,
    required this.isChatKeyboardScrollTarget,
    required this.onSetChatKeyboardScrollTarget,
    required this.isVisible,
    required this.onMinimize,
    required this.maxHeight,
  });

  final List<ChatMessage> messages;
  final void Function(String text) onSend;
  final VoidCallback onStop;
  final ValueListenable<bool> isChatKeyboardScrollTarget;
  final VoidCallback onSetChatKeyboardScrollTarget;
  final bool isVisible;
  final VoidCallback onMinimize;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => onSetChatKeyboardScrollTarget(),
        child: Material(
          color: ChatColors.transparent,
          child: Container(
            decoration: _chatShellDecoration(
              borderRadius: ChatTokens.shellBorderRadiusExpanded,
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF6BA3D6),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(ChatTokens.headerRadiusExpanded),
                      topRight: Radius.circular(ChatTokens.headerRadiusExpanded),
                    ),
                  ),
                  child: TwinChatAppBar(
                    onDisplayStateToggle: onMinimize,
                    displayStateToggleIcon: Icons.expand_more_rounded,
                    displayStateToggleTooltip: 'Minimize chat',
                  ),
                ),
                const Divider(height: 1, color: ChatLayout.dividerColor),
                Flexible(
                  child: Stack(
                    children: [
                      Padding(
                        padding: ChatTokens.shellContentPadding,
                        child: ChatSection(
                          messages: messages,
                          onSend: onSend,
                          onStop: onStop,
                          isChatKeyboardScrollTarget:
                              isChatKeyboardScrollTarget,
                          onSetChatKeyboardScrollTarget:
                              onSetChatKeyboardScrollTarget,
                          isVisible: isVisible,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: ChatTokens.chatListTopShadowHeight,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: ChatTokens.shellTopShadowGradient,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

BoxDecoration _chatShellDecoration({required BorderRadius borderRadius}) {
  return BoxDecoration(
    gradient: ChatLayout.backgroundGradient,
    borderRadius: borderRadius,
    border: Border.all(
      color: ChatColors.shellOuterBorder,
      width: ChatTokens.shellOuterBorderWidth,
    ),
    boxShadow: const [ChatTokens.shellShadow],
  );
}
