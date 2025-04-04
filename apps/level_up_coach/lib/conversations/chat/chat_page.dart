import 'package:flutter/material.dart';
import 'package:level_up_coach/conversations/chat/chat_message_view.dart';
import 'package:level_up_coach/conversations/models/chat_message.dart';
import 'package:level_up_coach/conversations/services/conversations_service.dart';
import 'package:level_up_coach/utils/locator.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.clientId});

  final String clientId;

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
        stream: locate<ConversationsService>().getMessagesStream(
          widget.clientId,
        ),
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
                            return ChatMessageView(
                              message: message.message,
                              authorId: message.authorId,
                            );
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
                            locate<ConversationsService>().send(
                              message: _messageController.text,
                              clientId: widget.clientId,
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
}
