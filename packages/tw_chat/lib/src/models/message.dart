enum ChatRole { user, bot }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.isPending = false,
  });

  final String id;
  final ChatRole role;
  final String text;
  final DateTime createdAt;
  final bool isPending;

  ChatMessage copyWith({
    String? id,
    ChatRole? role,
    String? text,
    DateTime? createdAt,
    bool? isPending,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      isPending: isPending ?? this.isPending,
    );
  }
}
