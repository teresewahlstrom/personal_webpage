import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../config/config.dart';
import '../models/message.dart';
import 'section.dart';

enum ChatDockDisplayState { minimized, expanded }

class ChatLauncherStyle {
  const ChatLauncherStyle({
    this.size = 58,
    this.iconSize = 25,
    this.icon = Icons.chat_bubble,
    this.foregroundColor = const Color(0xFF394183),
    this.hoverForegroundColor = const Color(0xFF843F02),
    this.backgroundColor = Colors.white,
    this.borderWidth = 1,
    this.animationDuration = const Duration(milliseconds: 180),
    this.idleShadowBlurRadius = 8,
    this.hoverShadowBlurRadius = 12,
    this.shadowOffset = const Offset(0, 3),
    this.shadowAlpha = 0.12,
  });

  final double size;
  final double iconSize;
  final IconData icon;
  final Color foregroundColor;
  final Color hoverForegroundColor;
  final Color backgroundColor;
  final double borderWidth;
  final Duration animationDuration;
  final double idleShadowBlurRadius;
  final double hoverShadowBlurRadius;
  final Offset shadowOffset;
  final double shadowAlpha;
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
    widget.onSetChatKeyboardScrollTarget();
    setState(() => _displayState = ChatDockDisplayState.expanded);
  }

  void _minimizeChat() {
    widget.onSetPageKeyboardScrollTarget();
    setState(() => _displayState = ChatDockDisplayState.minimized);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = ChatSkin.tokens;
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

    final baseRightInset = mediaQuery.viewPadding.right + chatMargin;
    final minimizedRightInset =
        mediaQuery.viewPadding.right +
        (chatMargin > widget.minimizedRightInset
            ? chatMargin
            : widget.minimizedRightInset);

    return ChatSkinScope(
      mode: widget.skinMode,
      child: Positioned(
        right: _isExpanded ? baseRightInset : minimizedRightInset,
        bottom:
            mediaQuery.viewInsets.bottom +
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

class ChatAppBar extends StatelessWidget {
  const ChatAppBar({
    super.key,
    required this.onDisplayStateToggle,
    required this.displayStateToggleIcon,
    required this.displayStateToggleTooltip,
    required this.tokens,
    this.shrinkWrap = false,
  });

  final VoidCallback onDisplayStateToggle;
  final IconData displayStateToggleIcon;
  final String displayStateToggleTooltip;
  final ChatSkinTokens tokens;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final skin = ChatSkin.dataOf(context);
    final colors = skin.colors;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final titleStyle = skin.textStyles.appBarTitleStyle(textScale, colors);
    final headerRadius = shrinkWrap
        ? tokens.headerRadiusMinimized
        : tokens.headerRadiusExpanded;
    final iconColor =
        titleStyle.color ??
        DefaultTextStyle.of(context).style.color ??
        Theme.of(context).textTheme.titleMedium?.color ??
        colors.bubbleText;
    final pad = shrinkWrap
        ? tokens.appBarPaddingMinimized
        : tokens.appBarPaddingExpanded;
    final titleArea = Padding(
      padding: EdgeInsets.fromLTRB(
        pad.left + tokens.appBarLeadingGap,
        pad.top,
        tokens.appBarActionGap + tokens.appBarActionWidth,
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
      width: tokens.appBarActionWidth,
      child: Material(
        color: colors.transparent,
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
    final foregroundColor = _isHovered
        ? launcherStyle.hoverForegroundColor
        : launcherStyle.foregroundColor;

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
            child: Tooltip(
              message: 'Open chat',
              child: AnimatedContainer(
                duration: launcherStyle.animationDuration,
                width: launcherStyle.size,
                height: launcherStyle.size,
                decoration: BoxDecoration(
                  color: launcherStyle.backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: foregroundColor,
                    width: launcherStyle.borderWidth,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: foregroundColor.withValues(
                        alpha: launcherStyle.shadowAlpha,
                      ),
                      blurRadius: _isHovered
                          ? launcherStyle.hoverShadowBlurRadius
                          : launcherStyle.idleShadowBlurRadius,
                      offset: launcherStyle.shadowOffset,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    launcherStyle.icon,
                    size: launcherStyle.iconSize,
                    color: foregroundColor,
                  ),
                ),
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
    required this.tokens,
  });

  final List<ChatMessage> messages;
  final void Function(String text) onSend;
  final VoidCallback onStop;
  final ValueListenable<bool> isChatKeyboardScrollTarget;
  final VoidCallback onSetChatKeyboardScrollTarget;
  final bool isVisible;
  final VoidCallback onMinimize;
  final double maxHeight;
  final ChatSkinTokens tokens;

  bool _shouldRoutePointerToChatKeyboardTarget(PointerDownEvent event) {
    return event.kind == PointerDeviceKind.mouse &&
        event.buttons == kPrimaryMouseButton;
  }

  @override
  Widget build(BuildContext context) {
    final colors = ChatSkin.dataOf(context).colors;
    final isDark = ChatSkin.isDarkOf(context);
    final gridLineColor =
      (isDark ? colors.shellDivider : colors.shellOuterBorder)
        .withValues(alpha: isDark ? 0.24 : 0.10);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          if (_shouldRoutePointerToChatKeyboardTarget(event)) {
            onSetChatKeyboardScrollTarget();
          }
        },
        child: Material(
          color: colors.transparent,
          child: Container(
            decoration: _chatShellDecoration(
              context: context,
              borderRadius: tokens.shellBorderRadiusExpanded,
            ),
            child: Column(
              children: [
                ChatAppBar(
                  onDisplayStateToggle: onMinimize,
                  displayStateToggleIcon: Icons.expand_more_rounded,
                  displayStateToggleTooltip: 'Minimize chat',
                  tokens: tokens,
                ),
                Divider(height: 1, color: ChatLayout.dividerColor(context)),
                Flexible(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ClipRect(
                            child: _GlobalAnchoredGridPaper(
                              color: gridLineColor,
                              unitSize: 4,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: tokens.shellContentPadding,
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
                        height: tokens.chatListTopShadowHeight,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: tokens.shellTopShadowGradient(colors),
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

BoxDecoration _chatShellDecoration({
  required BuildContext context,
  required BorderRadius borderRadius,
}) {
  final colors = ChatSkin.dataOf(context).colors;
  final tokens = ChatSkin.tokens;
  return BoxDecoration(
    gradient: ChatLayout.backgroundGradient(context),
    borderRadius: borderRadius,
    border: Border.all(
      color: colors.shellOuterBorder,
      width: tokens.shellOuterBorderWidth,
    ),
    boxShadow: [tokens.shellShadow(colors)],
  );
}

class _GlobalAnchoredGridPaper extends StatelessWidget {
  const _GlobalAnchoredGridPaper({required this.color, required this.unitSize});

  final Color color;
  final double unitSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final renderBox = context.findRenderObject() as RenderBox?;
        final globalOrigin =
            renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
        final xShift = globalOrigin.dx % unitSize;
        final yShift = globalOrigin.dy % unitSize;

        return Transform.translate(
          offset: Offset(-xShift, -yShift),
          child: SizedBox(
            width: constraints.maxWidth + unitSize,
            height: constraints.maxHeight + unitSize,
            child: GridPaper(
              color: color,
              interval: unitSize,
              divisions: 1,
              subdivisions: 1,
            ),
          ),
        );
      },
    );
  }
}
