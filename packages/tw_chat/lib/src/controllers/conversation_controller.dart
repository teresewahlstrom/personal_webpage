import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config/runtime.dart';
import '../models/message.dart';
import 'reply_client.dart';

class ConversationController extends ChangeNotifier {
  ConversationController({
    required this.introText,
    required ReplyClient replyClient,
    bool ownsReplyClient = false,
    String? sessionId,
    this.runtimeConfig = ChatRuntimeConfig.defaults,
  }) {
    _replyClient = replyClient;
    _ownsReplyClient = ownsReplyClient;
    _sessionId = sessionId ?? _createSessionId();
    _messages = <ChatMessage>[
      _createMessage(role: ChatRole.bot, text: introText),
    ];
  }

  final String introText;
  final ChatRuntimeConfig runtimeConfig;
  late final ReplyClient _replyClient;
  late final bool _ownsReplyClient;
  late final String _sessionId;
  Object? _lastReplyFailure;
  StackTrace? _lastReplyFailureStackTrace;
  bool _lastReplyFailureWasClientError = false;

  static const String _fallbackReplyText =
      'I cannot respond right now. Please try again.';

  final Map<String, Object> _pendingReplyTokens = <String, Object>{};
  late List<ChatMessage> _messages;
  int _nextMessageSequence = 0;

  List<ChatMessage> get messages => List<ChatMessage>.unmodifiable(_messages);

  bool get hasPendingReply => _pendingReplyTokens.isNotEmpty;
  Object? get lastReplyFailure => _lastReplyFailure;
  StackTrace? get lastReplyFailureStackTrace => _lastReplyFailureStackTrace;
  bool get hasLastReplyFailure => _lastReplyFailure != null;
  bool get lastReplyFailureWasClientError => _lastReplyFailureWasClientError;

  void sendMessage(String text) {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty || hasPendingReply) {
      return;
    }

    final pendingReplyMessage = _createMessage(
      role: ChatRole.bot,
      text: '...',
      isPending: true,
    );
    _messages = <ChatMessage>[
      ..._messages,
      _createMessage(role: ChatRole.user, text: trimmedText),
      pendingReplyMessage,
    ];
    notifyListeners();

    final token = Object();
    _pendingReplyTokens[pendingReplyMessage.id] = token;
    final pendingReplyStartedAt = DateTime.now();
    unawaited(
      _resolvePendingReply(
        pendingMessageId: pendingReplyMessage.id,
        originalMessage: trimmedText,
        token: token,
        pendingReplyStartedAt: pendingReplyStartedAt,
      ),
    );
  }

  void stopPendingReply() {
    if (_pendingReplyTokens.isEmpty) {
      return;
    }

    _pendingReplyTokens.clear();

    _messages = _messages
        .where((message) => !message.isPending)
        .toList(growable: false);
    notifyListeners();
  }

  Future<void> _resolvePendingReply({
    required String pendingMessageId,
    required String originalMessage,
    required Object token,
    required DateTime pendingReplyStartedAt,
  }) async {
    late final String replyText;
    try {
      replyText = await _replyClient.fetchReply(
        sessionId: _sessionId,
        message: originalMessage,
      );
      _clearLastReplyFailure();
    } on ReplyException catch (error, stackTrace) {
      _recordReplyFailure(
        error: error,
        stackTrace: stackTrace,
        clientError: true,
      );
      replyText = _fallbackReplyText;
    } catch (error, stackTrace) {
      _recordReplyFailure(
        error: error,
        stackTrace: stackTrace,
        clientError: false,
      );
      replyText = _fallbackReplyText;
    }
    await _waitForMinimumPendingReplyDuration(pendingReplyStartedAt);
    _completePendingReply(
      pendingMessageId: pendingMessageId,
      token: token,
      replyText: replyText,
    );
  }

  Future<void> _waitForMinimumPendingReplyDuration(DateTime startedAt) async {
    final minimumDuration = runtimeConfig.minimumPendingReplyDuration;
    if (minimumDuration <= Duration.zero) {
      return;
    }

    final elapsed = DateTime.now().difference(startedAt);
    final remaining = minimumDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
  }

  void _recordReplyFailure({
    required Object error,
    required StackTrace stackTrace,
    required bool clientError,
  }) {
    _lastReplyFailure = error;
    _lastReplyFailureStackTrace = stackTrace;
    _lastReplyFailureWasClientError = clientError;
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'tw_chat',
        context: ErrorDescription('while resolving a pending chat reply'),
      ),
    );
  }

  void _clearLastReplyFailure() {
    _lastReplyFailure = null;
    _lastReplyFailureStackTrace = null;
    _lastReplyFailureWasClientError = false;
  }

  void _completePendingReply({
    required String pendingMessageId,
    required Object token,
    required String replyText,
  }) {
    if (_pendingReplyTokens[pendingMessageId] != token) {
      return;
    }
    _pendingReplyTokens.remove(pendingMessageId);

    final hasPendingMessage = _messages.any(
      (message) => message.id == pendingMessageId && message.isPending,
    );
    if (!hasPendingMessage) {
      return;
    }

    _messages = _messages
        .map((message) {
          if (message.id != pendingMessageId || !message.isPending) {
            return message;
          }
          return message.copyWith(text: replyText, isPending: false);
        })
        .toList(growable: false);
    notifyListeners();
  }

  ChatMessage _createMessage({
    required ChatRole role,
    required String text,
    bool isPending = false,
  }) {
    return ChatMessage(
      id: _nextMessageId(),
      role: role,
      text: text,
      createdAt: DateTime.now(),
      isPending: isPending,
    );
  }

  String _nextMessageId() {
    final nextId = 'message_$_nextMessageSequence';
    _nextMessageSequence += 1;
    return nextId;
  }

  String _createSessionId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    return 'session_$timestamp';
  }

  @override
  void dispose() {
    _pendingReplyTokens.clear();
    if (_ownsReplyClient) {
      _replyClient.dispose();
    }
    super.dispose();
  }
}
