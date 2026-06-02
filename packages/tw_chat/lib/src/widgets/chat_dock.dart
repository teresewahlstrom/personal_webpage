import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:tw_primitives/theme.dart';

import '../config/config.dart';
import '../models/message.dart';
import 'section.dart';

enum ChatDockDisplayState { minimized, expanded }

class ChatLauncherStyle {
  const ChatLauncherStyle({
    this.size = 58,
    this.iconSize = 25,
    this.icon = Icons.chat_bubble,
    this.foregroundColor,
    this.hoverForegroundColor,

    this.backgroundColor,
    this.borderColor,
    this.hoverBorderColor,
    this.borderWidth = 1,
    this.animationDuration = const Duration(milliseconds: 180),
    this.idleShadowBlurRadius = 8,
    this.hoverShadowBlurRadius = 12,
    this.shadowOffset = const Offset(0, 3),
    this.shadowAlpha = 0.12,
    this.boxShadow = const <BoxShadow>[],
  });

  final double size;
  final double iconSize;
  final IconData icon;
  final Color? foregroundColor;
  final Color? hoverForegroundColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? hoverBorderColor;
  final double borderWidth;
  final Duration animationDuration;
  final double idleShadowBlurRadius;
  final double hoverShadowBlurRadius;
  final Offset shadowOffset;
  final double shadowAlpha;
  final List<BoxShadow> boxShadow;
}

class ChatDock extends StatefulWidget {
  const ChatDock({
    super.key,
    required this.messages,
    required this.onSend,
    required this.onStop,
    required this.isChatKeyboardScrollTarget,
    required this.onSetChatKeyboardScrollTarget,
    required this.onSetPageKeyboardScrollTarget,
    required this.keyboardHeight,
    this.minimizedBottomOffset = 25,
    this.minimizedRightInset = 0,
    this.skinMode = ChatSkinMode.light,
    this.launcherStyle = const ChatLauncherStyle(),
  });

  final List<ChatMessage> messages;
  final void Function(String text) onSend;
  final VoidCallback onStop;
  final ValueListenable<bool> isChatKeyboardScrollTarget;
  final VoidCallback onSetChatKeyboardScrollTarget;
  final VoidCallback onSetPageKeyboardScrollTarget;
  final double keyboardHeight;
  final double minimizedBottomOffset;
  final double minimizedRightInset;
  final ChatSkinMode skinMode;
  final ChatLauncherStyle launcherStyle;

  @override
  State<ChatDock> createState() => _ChatDockState();
}

class _ChatDockState extends State<ChatDock> {
  ChatDockDisplayState _displayState = ChatDockDisplayState.minimized;

  bool get _isExpanded => _displayState == ChatDockDisplayState.expanded;

  void _expandChat() {
    Tooltip.dismissAllToolTips();
    widget.onSetChatKeyboardScrollTarget();
    setState(() => _displayState = ChatDockDisplayState.expanded);
  }

  void _minimizeChat() {
    Tooltip.dismissAllToolTips();
    widget.onSetPageKeyboardScrollTarget();
    setState(() => _displayState = ChatDockDisplayState.minimized);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = ChatSkin.tokens;
    final mediaQuery = MediaQuery.of(context);
    final layoutMetrics = ChatLayout.resolveMetrics(
      viewportSize: mediaQuery.size,
      viewPadding: mediaQuery.viewPadding,
      keyboardHeight: widget.keyboardHeight,
      minimizedRightInset: widget.minimizedRightInset,
    );

    return ChatSkinScope(
      mode: widget.skinMode,
      child: Positioned(
        right: _isExpanded
            ? layoutMetrics.expandedRightInset
            : layoutMetrics.minimizedRightInset,
        bottom:
            layoutMetrics.keyboardHeight +
            (_isExpanded ? 0 : widget.minimizedBottomOffset),
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
                    width: layoutMetrics.expandedDockWidth,
                    child: FloatingChatWindow(
                      messages: widget.messages,
                      onSend: widget.onSend,
                      onStop: widget.onStop,
                      isChatKeyboardScrollTarget:
                          widget.isChatKeyboardScrollTarget,
                      onSetChatKeyboardScrollTarget:
                          widget.onSetChatKeyboardScrollTarget,
                      width: layoutMetrics.expandedDockWidth,
                      maxHeight: layoutMetrics.maxDockHeight,
                      isVisible: _isExpanded,
                      onMinimize: _minimizeChat,
                      tokens: tokens,
                    ),
                  ),
                ),
              ),
            ),
            Offstage(
              offstage: _isExpanded,
              child: MinimizedChatLauncher(
                launcherStyle: widget.launcherStyle,
                onSetChatKeyboardScrollTarget:
                    widget.onSetChatKeyboardScrollTarget,
                onExpand: _expandChat,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MinimizedChatLauncher extends StatefulWidget {
  const MinimizedChatLauncher({
    super.key,
    required this.launcherStyle,
    required this.onSetChatKeyboardScrollTarget,
    required this.onExpand,
  });

  final ChatLauncherStyle launcherStyle;
  final VoidCallback onSetChatKeyboardScrollTarget;
  final VoidCallback onExpand;

  bool _shouldRoutePointerToChatKeyboardTarget(PointerDownEvent event) {
    return event.kind == PointerDeviceKind.mouse &&
        event.buttons == kPrimaryMouseButton;
  }

  @override
  State<MinimizedChatLauncher> createState() => _MinimizedChatLauncherState();
}

class _MinimizedChatLauncherState extends State<MinimizedChatLauncher> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = ChatSkin.dataOf(context).colors;
    final launcherStyle = widget.launcherStyle;
    final Color effectiveForeground = _isHovered
        ? (launcherStyle.hoverForegroundColor ??
              launcherStyle.foregroundColor ??
              colors.markupLink)
        : (launcherStyle.foregroundColor ?? colors.bubbleText);

    return Material(
      color: colors.transparent,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            if (widget._shouldRoutePointerToChatKeyboardTarget(event)) {
              widget.onSetChatKeyboardScrollTarget();
            }
          },
          child: InkWell(
            onTap: widget.onExpand,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: launcherStyle.size,
              height: launcherStyle.size,
              child: TwLinkPill(
                label: '',
                leading: Icon(
                  launcherStyle.icon,
                  size: launcherStyle.iconSize,
                  color: effectiveForeground,
                ),
                tooltip: 'Open chat',
                semanticsLabel: 'Open chat',
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
    required this.width,
    required this.maxHeight,
    required this.tokens,
  });

  final List<ChatMessage> messages;
  final void Function(String text) onSend;
  final VoidCallback onStop;
  final ValueListenable<bool> isChatKeyboardScrollTarget;
  final VoidCallback onSetChatKeyboardScrollTarget;
  final bool isVisible;
  final VoidCallback onMinimize;
  final double width;
  final double maxHeight;
  final ChatSkinTokens tokens;

  bool _shouldRoutePointerToChatKeyboardTarget(PointerDownEvent event) {
    return event.kind == PointerDeviceKind.mouse &&
        event.buttons == kPrimaryMouseButton;
  }

  @override
  Widget build(BuildContext context) {
    final colors = ChatSkin.dataOf(context).colors;
    return SizedBox(
      height: maxHeight,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          if (_shouldRoutePointerToChatKeyboardTarget(event)) {
            onSetChatKeyboardScrollTarget();
          }
        },
        child: Material(
          color: colors.transparent,
          child: TwPanelContainer(
            title: const TwPanelTitle(label: 'Chat with Twin'),
            onClose: onMinimize,
            closeIcon: Icons.expand_more_rounded,
            closeTooltip: 'Minimize chat',
            isCloseTooltipVisible: isVisible,
            overlapHeader: true,
            body: ChatSection(
              messages: messages,
              onSend: onSend,
              onStop: onStop,
              isChatKeyboardScrollTarget: isChatKeyboardScrollTarget,
              onSetChatKeyboardScrollTarget: onSetChatKeyboardScrollTarget,
              isVisible: isVisible,
              panelWidth: width,
              panelHeight: maxHeight,
            ),
          ),
        ),
      ),
    );
  }
}
