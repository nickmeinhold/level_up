sealed class ChatMessage {
  ChatMessage({required this.id, required this.authorId, required this.read});

  final String id;
  final String authorId;
  final bool read;

  factory ChatMessage.fromJsonWithId(String id, Map<String, Object?> data) {
    if (data['type'] == 'text') {
      return TextChatMessage(
        id: id,
        authorId: data['authorId'] as String,
        read: data['read'] as bool,
        message: data['message'] as String,
      );
    }
    return VideoChatMessage(
      id: id,
      authorId: data['authorId'] as String,
      read: data['read'] as bool,
      videoUrl: data['videoUrl'] as String,
    );
  }
}

class TextChatMessage extends ChatMessage {
  TextChatMessage({
    required super.id,
    required super.authorId,
    required super.read,
    required this.message,
  });

  final String message;
}

class VideoChatMessage extends ChatMessage {
  VideoChatMessage({
    required super.id,
    required super.authorId,
    required super.read,
    required this.videoUrl,
  });

  final String videoUrl;
}
