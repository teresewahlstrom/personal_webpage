import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'reply_client.dart';

class HttpReplyClient extends ReplyClient {
  HttpReplyClient({
    required Uri baseUri,
    http.Client? httpClient,
    Duration timeout = const Duration(seconds: 30),
  }) : _chatUri = baseUri.resolve('/api/chat'),
       _httpClient = httpClient ?? http.Client(),
       _timeout = timeout;

  final Uri _chatUri;
  final http.Client _httpClient;
  final Duration _timeout;

  @override
  Future<String> fetchReply({
    required String sessionId,
    required String message,
  }) async {
    try {
      final response = await _httpClient
          .post(
            _chatUri,
            headers: const <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode(<String, Object?>{
              'sessionId': sessionId,
              'message': message,
            }),
          )
          .timeout(_timeout);

      final dynamic decodedBody = response.body.isEmpty
          ? null
          : jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorMessage = decodedBody is Map<String, dynamic>
            ? decodedBody['error'] as String?
            : null;
        throw ReplyException(
          errorMessage ?? 'The chat service returned ${response.statusCode}.',
        );
      }

      if (decodedBody is! Map<String, dynamic>) {
        throw const ReplyException('The chat service returned invalid JSON.');
      }

      final reply = decodedBody['reply'];
      if (reply is! String || reply.trim().isEmpty) {
        throw const ReplyException('The chat service returned an empty reply.');
      }

      return reply.trim();
    } on TimeoutException {
      throw const ReplyException('The chat service timed out.');
    } on FormatException {
      throw const ReplyException('The chat service returned invalid JSON.');
    } on http.ClientException catch (error) {
      throw ReplyException('The chat service is unavailable: ${error.message}');
    }
  }

  @override
  void dispose() {
    _httpClient.close();
  }
}