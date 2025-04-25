import 'package:flutter/material.dart';
import 'package:level_up_shared/src/chat/chat_message.dart';
import 'package:level_up_shared/src/chat/chat_service.dart';
import 'package:level_up_shared/src/chat/text_message_view.dart';
import 'package:level_up_shared/src/chat/video_message_view.dart';
import 'package:level_up_shared/src/utils/locator.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    this.isCoach = false,
    required this.currentUserId,
    required this.conversationId,
  });

  final bool isCoach;
  final String currentUserId;
  final String conversationId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    locate<ChatService>().startListeningForLatestMessage(widget.conversationId);
  }

  @override
  void dispose() {
    locate<ChatService>().stopListeningForLatestMessage();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: StreamBuilder<List<ChatMessage>>(
        stream: locate<ChatService>().messagesListStream,
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
                            if (index == messages.length - 1) {}
                            ChatMessage message = messages[index];
                            // if a coach sees the message, mark as read
                            if (widget.isCoach) {
                              locate<ChatService>().setMessageToRead(
                                widget.conversationId,
                                message,
                              );
                            }
                            if (index == messages.length - 1) {
                              locate<ChatService>().retrievePreviousMessages(
                                widget.conversationId,
                              );
                            }
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
                            locate<ChatService>().send(
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
}
