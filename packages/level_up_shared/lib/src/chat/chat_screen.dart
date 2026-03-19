import 'package:flutter/material.dart';
import 'package:level_up_shared/src/chat/chat_message.dart';
import 'package:level_up_shared/src/chat/chat_service.dart';
import 'package:level_up_shared/src/chat/text_message_view.dart';
import 'package:level_up_shared/src/chat/video_message_view.dart';
import 'package:level_up_shared/src/utils/locator.dart';

/// A 'not signed in' state is indicated by passing an empty string for the
/// currentUserId.
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    bool isCoach = false,
    required String currentUserId,
    required String conversationId,
  }) : _conversationId = conversationId,
       _currentUserId = currentUserId,
       _isCoach = isCoach;

  final bool _isCoach;
  final String _currentUserId;
  final String _conversationId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final Set<String> _markedAsReadIds = {};
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    if (widget._currentUserId == '') {
      _isSignedIn = false;
    } else {
      _isSignedIn = true;
      locate<ChatService>().startListeningForLatestMessage(
        widget._conversationId,
      );
    }
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
      body:
          _isSignedIn
              ? StreamBuilder<List<ChatMessage>>(
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
                                  child: Text(
                                    'No messages yet. Start a conversation!',
                                  ),
                                )
                                : ListView.builder(
                                  reverse: true,
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    if (index == messages.length - 1) {}
                                    ChatMessage message = messages[index];
                                    // If a coach sees the message, mark as read
                                    // (only once per message to avoid excessive
                                    // Firestore writes on every rebuild).
                                    if (widget._isCoach &&
                                        !message.read &&
                                        !_markedAsReadIds.contains(message.id)) {
                                      _markedAsReadIds.add(message.id);
                                      locate<ChatService>().setMessageToRead(
                                        widget._conversationId,
                                        message,
                                      );
                                    }
                                    if (index == messages.length - 1) {
                                      locate<ChatService>()
                                          .retrievePreviousMessages(
                                            widget._conversationId,
                                          );
                                    }
                                    switch (message) {
                                      case TextChatMessage():
                                        return TextMessageView(
                                          message: message.message,
                                          currentUserId: widget._currentUserId,
                                          authorId: message.authorId,
                                        );
                                      case VideoChatMessage():
                                        return VideoMessageView(
                                          videoUrl: message.videoUrl,
                                          currentUserId: widget._currentUserId,
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 8.0,
                        ),
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
                                      conversationId: widget._conversationId,
                                      authorId: widget._currentUserId,
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
              )
              : Center(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text(
                    'Please go to Profile and Sign In to chat with our coaches',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black26,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
    );
  }
}
