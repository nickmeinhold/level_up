import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final String name;
  final String lastMessage;
  final String? avatarUrl;
  final Timestamp timestamp;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.avatarUrl,
    required this.timestamp,
    required this.unreadCount,
  });

  factory Conversation.fromJson({required Map<String, dynamic> json}) {
    return Conversation(
      id: json['id'] as String,
      name: json['name'] as String,
      lastMessage: json['lastMessage'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      timestamp: json['timestamp'] as Timestamp,
      unreadCount: json['unreadCount'] as int,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'lastMessage': lastMessage,
      'avatarUrl': avatarUrl,
      'timestamp': timestamp,
      'unreadCount': unreadCount,
    };
  }
}
