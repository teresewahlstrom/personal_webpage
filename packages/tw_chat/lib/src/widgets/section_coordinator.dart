import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderAbstractViewport, SelectedContent;
import 'package:tw_primitives/scrollbar.dart' as tw_scrollbar;
import 'package:tw_primitives/text_field.dart' show TwReadyTextController;

import '../config/config.dart';
import '../logic/message_diff.dart';
import '../models/message.dart';
import 'selection_copy_helper.dart';
import 'scroll_helper.dart';

typedef ChatMessageBubbleKeyMap = Map<String, GlobalKey<State>>;

class SectionCoordinator extends ChangeNotifier {
  SectionCoordinator({
    required this._isMounted,
    required this._onSetChatKeyboardScrollTarget,
  });

  final bool Function() _isMounted;
  VoidCallback _onSetChatKeyboardScrollTarget;
  final ScrollHelper _scrollHelper = const ScrollHelper();
  final SelectionCopyHelper _selectionCopy = SelectionCopyHelper();
  final ValueNotifier<int> _chatViewTick = ValueNotifier<int>(0);
  final ValueNotifier<int> _composerViewTick = ValueNotifier<int>(0);
  final Map<String, GlobalKey<State>> _messageBubbleKeys =
      <String, GlobalKey<State>>{};
  final Map<String, ChatMessage> _messagesById = <String, ChatMessage>{};
  final Map<String, bool> _messageTruncationOverrides = <String, bool>{};

  final TwReadyTextController controller = TwReadyTextController();
  final ScrollController chatScroll = ScrollController();
  final FocusNode inputFocusNode = FocusNode();
  final FocusNode chatFocusNode = FocusNode(debugLabel: 'chat_list');

  bool _showChatScrollbarTrack = false;
  bool _isChatPointerInteractionActive = false;
  bool _isNearBottomCache = true;
  bool _isNearBottomRefreshQueued = false;
  String? _latestCompletedBotMessageId;
  String? _unseenLatestBotMessageId;

  bool get showChatScrollbarTrack => _showChatScrollbarTrack;
  bool get isChatPointerInteractionActive => _isChatPointerInteractionActive;
  bool get hasUnseenLatestBotMessage => _unseenLatestBotMessageId != null;

  List<ChatMessage> _previousMessagesSnapshot = const <ChatMessage>[];
  String? _deferredRevealMessageId;
  bool _deferredStickToBottom = false;

  GlobalKey<tw_scrollbar.TwSelectableRegionState> get chatSelectionAreaKey =>
      _selectionCopy.chatSelectionAreaKey;
  ChatMessageBubbleKeyMap get messageBubbleKeys => _messageBubbleKeys;
  ValueListenable<int> get chatViewListenable => _chatViewTick;
  ValueListenable<int> get composerViewListenable => _composerViewTick;
  bool get isChatSelectionActive => _selectionCopy.isChatSelectionActive;

  tw_scrollbar.SelectionListenerNotifier selectionNotifierForMessage(
    String messageId,
  ) {
    return _selectionCopy.selectionNotifierForMessage(messageId);
  }

  bool get shouldPauseAutoFollow =>
      _isChatPointerInteractionActive || isChatSelectionActive;

  bool get isNearChatBottom => _isNearBottomCache;

  void initialize({required List<ChatMessage> messages}) {
    _syncMessageBubbleKeys(messages);
    _previousMessagesSnapshot = List<ChatMessage>.unmodifiable(messages);
    chatScroll.addListener(_handleChatScroll);
    inputFocusNode.addListener(_handleInputFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isMounted()) {
        return;
      }
      inputFocusNode.requestFocus();
      _scrollHelper.syncScrollbarVisibility(
        controller: chatScroll,
        currentValue: () => _showChatScrollbarTrack,
        updateVisibility: (value) => _showChatScrollbarTrack = value,
        notifyListeners: _notifyChatView,
        visibilityOverflowThreshold: ChatScrollbar.visibilityOverflowThreshold,
      );
      if (messages.isNotEmpty) {
        _jumpToLatestMessageTop();
      }
      _refreshNearBottomCache(notify: false);
    });
  }

  void updateCallbacks({required VoidCallback onSetChatKeyboardScrollTarget}) {
    _onSetChatKeyboardScrollTarget = onSetChatKeyboardScrollTarget;
  }

  void handleWidgetUpdate({
    required List<ChatMessage> messages,
    required bool becameVisible,
    required bool isVisible,
  }) {
    if (!isVisible) {
      _isChatPointerInteractionActive = false;
      _selectionCopy.clearSelection();
    }

    if (becameVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isMounted()) {
          _runDeferredVisibilityActionIfNeeded(isVisible: isVisible);
        }
      });
    }

    final wasNearBottom = _isNearChatBottom();
    _syncMessageBubbleKeys(messages);
    final messageDiff = ChatMessageDiff.summarize(
      previousMessages: _previousMessagesSnapshot,
      currentMessages: messages,
    );
    final latestVisibleBotId = messageDiff.latestVisibleBotId;
    final shouldAutoFollow =
        wasNearBottom && !shouldPauseAutoFollow && messageDiff.hasNewContent;
    _previousMessagesSnapshot = List<ChatMessage>.unmodifiable(messages);

    _scheduleChatScrollbarVisibilitySync();
    if (shouldAutoFollow) {
      if (!isVisible) {
        if (latestVisibleBotId != null) {
          _deferredRevealMessageId = latestVisibleBotId;
          _deferredStickToBottom = false;
        } else {
          _deferredRevealMessageId = null;
          _deferredStickToBottom = true;
        }
        return;
      }
      _clearUnseenLatestBotMessage();
      if (latestVisibleBotId != null) {
        _revealMessageTopIfPossible(latestVisibleBotId);
      } else {
        _stickChatToBottom();
      }
      return;
    }

    if (latestVisibleBotId != null && !wasNearBottom) {
      _setUnseenLatestBotMessage(latestVisibleBotId);
    }

    if (!becameVisible && (!wasNearBottom || shouldPauseAutoFollow)) {
      _deferredRevealMessageId = null;
      _deferredStickToBottom = false;
    }
  }

  bool isMessageTruncated(String messageId) {
    final message = _messagesById[messageId];
    if (message == null) {
      return false;
    }
    return _messageTruncationOverrides[messageId] ??
        _defaultMessageTruncation(message);
  }

  void toggleMessageTruncation(String messageId) {
    if (!_messagesById.containsKey(messageId)) {
      return;
    }
    _messageTruncationOverrides[messageId] = !isMessageTruncated(messageId);
    _notifyChatView();
    _scheduleChatScrollbarVisibilitySync();
    _scheduleNearBottomRefresh();
  }

  void handleChatPointerInteractionStart() {
    if (_isChatPointerInteractionActive) {
      return;
    }
    _isChatPointerInteractionActive = true;
  }

  void handleChatPointerInteractionEnd() {
    if (!_isChatPointerInteractionActive) {
      return;
    }
    _isChatPointerInteractionActive = false;
  }

  void handleChatSelectionChanged(SelectedContent? selectedContent) {
    if (_selectionCopy.handleChatSelectionChanged(selectedContent)) {
      _notifyChatView();
    }
  }

  void clearChatSelection() {
    if (_selectionCopy.clearSelection()) {
      _notifyChatView();
    }
  }

  String resolveSelectionCopyText(List<ChatMessage> messages) {
    return _selectionCopy.resolveSelectionCopyText(
      messages,
      fullCopyMessageIds: _truncatedSelectedMessageIds(messages),
    );
  }

  void jumpToLatest() {
    focusChatKeyboardTarget();
    if (_clearUnseenLatestBotMessage()) {
      _notifyChatView();
    }
    _jumpToLatestMessageTop();
  }

  void jumpToBottom() {
    focusChatKeyboardTarget();
    _clearUnseenLatestBotMessage();
    _stickChatToBottom();
  }

  void submitMessage({required void Function(String text) onSend}) {
    if (controller.isBlank) {
      return;
    }
    _deferredRevealMessageId = null;
    _deferredStickToBottom = false;
    onSend(controller.text);
    controller.clear();
    inputFocusNode.requestFocus();
    _stickChatToBottom();
  }

  void stopPendingReply({required VoidCallback onStop}) {
    onStop();
    inputFocusNode.requestFocus();
  }

  void transferFocusToInput() {
    _onSetChatKeyboardScrollTarget();
    inputFocusNode.requestFocus();
  }

  void insertCharacterIntoInput(String character) {
    final currentText = controller.text;
    final selection = controller.selection;
    final hasValidSelection =
        selection.isValid &&
        selection.start >= 0 &&
        selection.end >= 0 &&
        selection.start <= currentText.length &&
        selection.end <= currentText.length;

    final start = hasValidSelection ? selection.start : currentText.length;
    final end = hasValidSelection ? selection.end : currentText.length;
    final normalizedStart = start <= end ? start : end;
    final normalizedEnd = start <= end ? end : start;
    final nextText = currentText.replaceRange(
      normalizedStart,
      normalizedEnd,
      character,
    );
    final caretOffset = normalizedStart + character.length;

    controller.text = nextText;
    controller.selection = TextSelection.collapsed(offset: caretOffset);
  }

  void claimChatInteraction() {
    _onSetChatKeyboardScrollTarget();
  }

  bool animateChatScrollBy(double delta, {required bool animate}) {
    final tokens = ChatSkin.tokens;
    return _scrollHelper.animateBy(
      controller: chatScroll,
      delta: delta,
      duration: tokens.keyboardScrollAnimationDuration,
      curve: Curves.easeOut,
      animate: animate,
    );
  }

  void focusChatKeyboardTarget() {
    _onSetChatKeyboardScrollTarget();
    chatFocusNode.requestFocus();
  }

  @override
  void dispose() {
    chatScroll.removeListener(_handleChatScroll);
    inputFocusNode.removeListener(_handleInputFocusChange);
    controller.dispose();
    chatScroll.dispose();
    inputFocusNode.dispose();
    chatFocusNode.dispose();
    _selectionCopy.dispose();
    _chatViewTick.dispose();
    _composerViewTick.dispose();
    super.dispose();
  }

  void _handleInputFocusChange() {
    if (inputFocusNode.hasFocus) {
      _onSetChatKeyboardScrollTarget();
    }
  }

  void _handleChatScroll() {
    _scheduleNearBottomRefresh();
  }

  void _runDeferredVisibilityActionIfNeeded({required bool isVisible}) {
    if (!isVisible) {
      return;
    }
    if (_deferredRevealMessageId != null) {
      final revealMessageId = _deferredRevealMessageId!;
      _deferredRevealMessageId = null;
      _deferredStickToBottom = false;
      _revealMessageTopIfPossible(revealMessageId);
      return;
    }
    if (_deferredStickToBottom) {
      _deferredStickToBottom = false;
      _stickChatToBottom();
    }
  }

  void _syncMessageBubbleKeys(List<ChatMessage> messages) {
    _messagesById
      ..clear()
      ..addEntries(messages.map((message) => MapEntry(message.id, message)));
    _latestCompletedBotMessageId = _latestCompletedBotMessageIdFor(messages);

    final activeMessageIds = _messagesById.keys.toSet();
    for (final message in messages) {
      _messageBubbleKeys.putIfAbsent(message.id, GlobalKey.new);
    }

    _messageTruncationOverrides.removeWhere(
      (messageId, _) => !activeMessageIds.contains(messageId),
    );
    _messageBubbleKeys.removeWhere(
      (messageId, _) => !activeMessageIds.contains(messageId),
    );

    _selectionCopy.syncActiveMessageIds(activeMessageIds);
    if (_deferredRevealMessageId != null &&
        !activeMessageIds.contains(_deferredRevealMessageId)) {
      _deferredRevealMessageId = null;
    }
    if (_unseenLatestBotMessageId != null &&
        !activeMessageIds.contains(_unseenLatestBotMessageId)) {
      _unseenLatestBotMessageId = null;
    }
  }

  void _scheduleChatScrollbarVisibilitySync() {
    _scheduleScrollbarVisibilitySync(
      controller: chatScroll,
      currentValue: () => _showChatScrollbarTrack,
      updateVisibility: (value) => _showChatScrollbarTrack = value,
      onTrackVisibilityChanged: _notifyChatView,
    );
  }

  void _scheduleNearBottomRefresh() {
    if (_isNearBottomRefreshQueued) {
      return;
    }
    _isNearBottomRefreshQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isNearBottomRefreshQueued = false;
      if (!_isMounted()) {
        return;
      }
      _refreshNearBottomCache();
    });
  }

  void _scheduleScrollbarVisibilitySync({
    required ScrollController controller,
    required bool Function() currentValue,
    required ValueChanged<bool> updateVisibility,
    required VoidCallback onTrackVisibilityChanged,
  }) {
    _scrollHelper.scheduleScrollbarVisibilitySync(
      isMounted: _isMounted,
      controller: controller,
      currentValue: currentValue,
      updateVisibility: updateVisibility,
      notifyListeners: onTrackVisibilityChanged,
      visibilityOverflowThreshold: ChatScrollbar.visibilityOverflowThreshold,
    );
  }

  bool _isNearChatBottom() {
    return _scrollHelper.isNearBottom(
      controller: chatScroll,
      threshold: ChatLayout.nearBottomThreshold,
    );
  }

  void _refreshNearBottomCache({bool notify = true}) {
    final bool nextValue = _isNearChatBottom();
    final bool nearBottomChanged = _isNearBottomCache != nextValue;
    _isNearBottomCache = nextValue;
    final bool unreadChanged = nextValue && _clearUnseenLatestBotMessage();
    if (!nearBottomChanged && !unreadChanged) {
      return;
    }
    if (notify) {
      _notifyChatView();
    }
  }

  void _stickChatToBottom([
    int remainingPasses = ChatLayout.forcedBottomPasses,
  ]) {
    _scrollHelper.stickToBottom(
      isMounted: _isMounted,
      controller: chatScroll,
      remainingPasses: remainingPasses,
    );
  }

  void _revealMessageTopIfPossible(
    String messageId, [
    int remainingPasses = ChatLayout.forcedBottomPasses,
  ]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isMounted() || !chatScroll.hasClients) {
        return;
      }

      final bubbleKey = _messageBubbleKeys[messageId];
      if (bubbleKey == null) {
        return;
      }

      final bubbleContext = bubbleKey.currentContext;
      if (bubbleContext == null) {
        if (remainingPasses > 1) {
          _revealMessageTopIfPossible(messageId, remainingPasses - 1);
        }
        return;
      }

      final renderObject = bubbleContext.findRenderObject();
      final viewport = renderObject == null
          ? null
          : RenderAbstractViewport.maybeOf(renderObject);
      if (renderObject == null || viewport == null) {
        _stickChatToBottom();
        return;
      }

      final desiredOffset = viewport
          .getOffsetToReveal(renderObject, 0.0, axis: Axis.vertical)
          .offset;
      final position = chatScroll.position;

      final targetOffset = desiredOffset.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if ((position.pixels - targetOffset).abs() > 0.5) {
        chatScroll.jumpTo(targetOffset);
      }

      if (remainingPasses > 1) {
        _revealMessageTopIfPossible(messageId, remainingPasses - 1);
      }
    });
  }

  String? _latestCompletedBotMessageIdFor(List<ChatMessage> messages) {
    for (final message in messages.reversed) {
      if (message.role == ChatRole.bot && !message.isPending) {
        return message.id;
      }
    }
    return null;
  }

  void _jumpToLatestMessageTop() {
    final latestCompletedBotMessageId = _latestCompletedBotMessageId;
    if (latestCompletedBotMessageId != null) {
      _revealMessageTopIfPossible(latestCompletedBotMessageId);
      return;
    }
    _stickChatToBottom();
  }

  bool _setUnseenLatestBotMessage(String messageId) {
    if (_unseenLatestBotMessageId == messageId) {
      return false;
    }
    _unseenLatestBotMessageId = messageId;
    return true;
  }

  bool _clearUnseenLatestBotMessage() {
    if (_unseenLatestBotMessageId == null) {
      return false;
    }
    _unseenLatestBotMessageId = null;
    return true;
  }

  bool _defaultMessageTruncation(ChatMessage message) {
    return message.role == ChatRole.user;
  }

  Set<String> _truncatedSelectedMessageIds(List<ChatMessage> messages) {
    final selectedIds = <String>{};
    for (final message in messages) {
      if (!isMessageTruncated(message.id)) {
        continue;
      }
      if (!_selectionCopy.hasSelectionForMessage(message.id)) {
        continue;
      }
      selectedIds.add(message.id);
    }
    return selectedIds;
  }

  void _notifyChatView() {
    _chatViewTick.value++;
  }
}
