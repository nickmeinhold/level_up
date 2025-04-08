import 'package:flutter/material.dart';
import 'package:level_up_shared/chat_message.dart';
import 'package:level_up_shared/text_message_view.dart';
import 'package:level_up_shared/video_message_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.currentUserId,
    required this.conversationId,
  });

  final String currentUserId;
  final String conversationId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: StreamBuilder<List<ChatMessage>>(
        stream: _getMessagesStream(conversationId: widget.conversationId),
        builder: (context, snapshot) {
          if (snapshot.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(snapshot.error.toString())),
              );
            });
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          List<ChatMessage> messages = snapshot.data ?? [];
          return Column(
            children: [
              // Messages list
              Expanded(
                child:
                    messages.isEmpty
                        ? Center(
                          child: Text('No messages yet. Start a conversation!'),
                        )
                        : ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            ChatMessage message = messages[index];
                            switch (message) {
                              case TextChatMessage():
                                return TextMessageView(
                                  message: message.message,
                                  currentUserId: widget.currentUserId,
                                  authorId: message.authorId,
                                );
                              case VideoChatMessage():
                                return VideoMessageView(
                                  videoUrl: message.videoUrl,
                                  currentUserId: widget.currentUserId,
                                  authorId: message.authorId,
                                );
                            }
                          },
                        ),
              ),
              // Input area
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(80),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, -1),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    // Message input field
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: EdgeInsets.all(12.0),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    // Send button
                    FloatingActionButton(
                      onPressed: () {
                        if (_messageController.text.trim().isNotEmpty) {
                          setState(() {
                            _send(
                              message: _messageController.text,
                              conversationId: widget.conversationId,
                              authorId: widget.currentUserId,
                            );
                            _messageController.clear();
                          });
                        }
                      },
                      mini: true,
                      child: Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _send({
    required String message,
    required String conversationId,
    required String authorId,
  }) async {
    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .set({
          'lastMessage': message,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

    DocumentReference<Map<String, dynamic>> _ = await FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add({
          'authorId': authorId,
          'message': message,
          'type': 'text',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
  }

  Stream<List<ChatMessage>> _getMessagesStream({
    required String conversationId,
  }) {
    return FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .map<List<ChatMessage>>((QuerySnapshot<Map<String, dynamic>> snapshot) {
          List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
              snapshot.docs;
          return docs.map<ChatMessage>((snapshot) {
            QueryDocumentSnapshot<Map<String, dynamic>> doc = snapshot;
            return ChatMessage.fromJsonWithId(doc.id, doc.data());
          }).toList();
        });
  }
}
