class Conversation {
  final String name;
  final String clientId;
  final String lastMessage;
  final String avatarUrl;
  final String time;
  final bool isRead;
  final int unreadCount;

  Conversation({
    required this.name,
    required this.clientId,
    required this.lastMessage,
    required this.avatarUrl,
    required this.time,
    required this.isRead,
    required this.unreadCount,
  });
}
