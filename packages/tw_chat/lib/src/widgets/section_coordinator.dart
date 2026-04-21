import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../config/config.dart';
import '../logic/message_diff.dart';
import '../models/message.dart';
import 'selection_copy_helper.dart';
import 'scroll_helper.dart';

typedef ChatMessageBubbleKeyMap = Map<String, GlobalKey<State>>;

class SectionCoordinator extends ChangeNotifier {
  SectionCoordinator({
    required bool Function() isMounted,
    required VoidCallback onSetChatKeyboardScrollTarget,
  }) : _isMounted = isMounted,
       _onSetChatKeyboardScrollTarget = onSetChatKeyboardScrollTarget;

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

  final TextEditingController controller = TextEditingController();
  final ScrollController chatScroll = ScrollController();
  final ScrollController inputScroll = ScrollController();
  final FocusNode inputFocusNode = FocusNode();
  final FocusNode chatFocusNode = FocusNode(debugLabel: 'chat_list');

  bool showChatScrollbarTrack = false;
  bool showInputScrollbarTrack = false;
  bool isChatPointerInteractionActive = false;
  int newMessageCount = 0;
  bool _isNearBottomCache = true;

  List<ChatMessage> _previousMessagesSnapshot = const <ChatMessage>[];
  String? _deferredRevealMessageId;
  bool _deferredStickToBottom = false;

  GlobalKey<SelectionAreaState> get chatSelectionAreaKey =>
      _selectionCopy.chatSelectionAreaKey;
  ChatMessageBubbleKeyMap get messageBubbleKeys => _messageBubbleKeys;
  ValueListenable<int> get chatViewListenable => _chatViewTick;
  ValueListenable<int> get composerViewListenable => _composerViewTick;
  bool get isChatSelectionActive => _selectionCopy.isChatSelectionActive;

  SelectionListenerNotifier selectionNotifierForMessage(String messageId) {
    return _selectionCopy.selectionNotifierForMessage(messageId);
  }

  bool get shouldPauseAutoFollow =>
      isChatPointerInteractionActive || isChatSelectionActive;

  bool get isNearChatBottom => _isNearBottomCache;

  void initialize({required List<ChatMessage> messages}) {
    _syncMessageBubbleKeys(messages);
    _previousMessagesSnapshot = List<ChatMessage>.unmodifiable(messages);
    chatScroll.addListener(_handleChatScroll);
    inputFocusNode.addListener(_handleInputFocusChange);
    controller.addListener(_scheduleInputScrollbarVisibilitySync);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isMounted()) {
        return;
      }
      inputFocusNode.requestFocus();
      _scrollHelper.syncScrollbarVisibility(
        controller: chatScroll,
        currentValue: () => showChatScrollbarTrack,
        updateVisibility: (value) => showChatScrollbarTrack = value,
        notifyListeners: _notifyChatView,
        visibilityOverflowThreshold: ChatScrollbar.visibilityOverflowThreshold,
      );
      _scrollHelper.syncScrollbarVisibility(
        controller: inputScroll,
        currentValue: () => showInputScrollbarTrack,
        updateVisibility: (value) => showInputScrollbarTrack = value,
        notifyListeners: _notifyComposerView,
        visibilityOverflowThreshold: ChatScrollbar.visibilityOverflowThreshold,
      );
      if (messages.isNotEmpty) {
        _stickChatToBottom();
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
    final shouldAutoFollow =
        wasNearBottom && !shouldPauseAutoFollow && messageDiff.hasNewContent;
    _previousMessagesSnapshot = List<ChatMessage>.unmodifiable(messages);

    _scheduleChatScrollbarVisibilitySync();
    if (shouldAutoFollow) {
      _clearNewMessagesIndicator(notify: false);
      if (!isVisible) {
        if (messageDiff.resolvedPendingBotId != null) {
          _deferredRevealMessageId = messageDiff.resolvedPendingBotId;
          _deferredStickToBottom = false;
        } else {
          _deferredRevealMessageId = null;
          _deferredStickToBottom = true;
        }
        return;
      }
      if (messageDiff.resolvedPendingBotId != null) {
        _revealMessageTopIfPossible(messageDiff.resolvedPendingBotId!);
      } else {
        _stickChatToBottom();
      }
      return;
    }

    if (!becameVisible && (!wasNearBottom || shouldPauseAutoFollow)) {
      _deferredRevealMessageId = null;
      _deferredStickToBottom = false;
    }

    if (messageDiff.visibleIncomingMessages > 0 &&
        (!wasNearBottom || shouldPauseAutoFollow)) {
      _incrementNewMessagesIndicator(
        messageDiff.visibleIncomingMessages,
        notify: false,
      );
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
  }

  void handleChatPointerInteractionStart() {
    if (isChatPointerInteractionActive) {
      return;
    }
    isChatPointerInteractionActive = true;
  }

  void handleChatPointerInteractionEnd() {
    if (!isChatPointerInteractionActive) {
      return;
    }
    isChatPointerInteractionActive = false;
  }

  void handleChatSelectionChanged(SelectedContent? selectedContent) {
    _selectionCopy.handleChatSelectionChanged(selectedContent);
  }

  String resolveSelectionCopyText(List<ChatMessage> messages) {
    return _selectionCopy.resolveSelectionCopyText(messages);
  }

  void jumpToLatest() {
    focusChatKeyboardTarget();
    _clearNewMessagesIndicator();
    _stickChatToBottom();
  }

  void submitMessage({required void Function(String text) onSend}) {
    if (controller.text.trim().isEmpty) {
      return;
    }
    _deferredRevealMessageId = null;
    _deferredStickToBottom = false;
    onSend(controller.text);
    controller.clear();
    inputFocusNode.requestFocus();
    _scheduleInputScrollbarVisibilitySync();
    _clearNewMessagesIndicator();
    _stickChatToBottom();
  }

  void stopPendingReply({required VoidCallback onStop}) {
    onStop();
    inputFocusNode.requestFocus();
    _scheduleInputScrollbarVisibilitySync();
  }

  void transferFocusToInput() {
    _onSetChatKeyboardScrollTarget();
    inputFocusNode.requestFocus();
    _scheduleInputScrollbarVisibilitySync();
  }

  void insertCharacterIntoInput(String character) {
    final currentValue = controller.value;
    final currentText = currentValue.text;
    final selection = currentValue.selection;
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

    controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: caretOffset),
      composing: TextRange.empty,
    );
  }

  bool animateChatScrollBy(double delta, {required bool animate}) {
    final tokens = ChatSkin.data.tokens;
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
    controller.removeListener(_scheduleInputScrollbarVisibilitySync);
    controller.dispose();
    chatScroll.dispose();
    inputScroll.dispose();
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
    _refreshNearBottomCache();
    if (newMessageCount > 0 && _isNearBottomCache) {
      _clearNewMessagesIndicator();
    }
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
  }

  void _scheduleChatScrollbarVisibilitySync() {
    _scheduleScrollbarVisibilitySync(
      controller: chatScroll,
      currentValue: () => showChatScrollbarTrack,
      updateVisibility: (value) => showChatScrollbarTrack = value,
      onTrackVisibilityChanged: _notifyChatView,
    );
  }

  void _scheduleInputScrollbarVisibilitySync() {
    _scheduleScrollbarVisibilitySync(
      controller: inputScroll,
      currentValue: () => showInputScrollbarTrack,
      updateVisibility: (value) => showInputScrollbarTrack = value,
      onTrackVisibilityChanged: _notifyComposerView,
    );
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
    if (_isNearBottomCache == nextValue) {
      return;
    }
    _isNearBottomCache = nextValue;
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

  void _clearNewMessagesIndicator({bool notify = true}) {
    if (newMessageCount == 0) {
      return;
    }
    newMessageCount = 0;
    if (notify) {
      _notifyChatView();
    }
  }

  void _incrementNewMessagesIndicator(int increment, {bool notify = true}) {
    if (increment <= 0) {
      return;
    }
    newMessageCount += increment;
    if (notify) {
      _notifyChatView();
    }
  }

  bool _defaultMessageTruncation(ChatMessage message) {
    return message.role == ChatRole.user;
  }

  void _notifyChatView() {
    _chatViewTick.value++;
  }

  void _notifyComposerView() {
    _composerViewTick.value++;
  }
}
