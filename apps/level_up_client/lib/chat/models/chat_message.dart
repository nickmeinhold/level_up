class ChatMessage {
  ChatMessage({
    required this.id,
    required this.authorId,
    required this.message,
  });

  final String id;
  final String authorId;
  final String message;

  factory ChatMessage.fromJsonWithId(String id, Map<String, Object?> data) {
    return ChatMessage(
      id: id,
      authorId: data['authorId'] as String,
      message: data['message'] as String,
    );
  }
}
