import 'package:flutter/material.dart';
import 'package:level_up/auth/auth_service.dart';
import 'package:level_up/utils/locator.dart';

class ChatMessageView extends StatefulWidget {
  final String message;
  final String authorId;

  const ChatMessageView({
    super.key,
    required this.message,
    required this.authorId,
  });

  @override
  State<ChatMessageView> createState() => _ChatMessageViewState();
}

class _ChatMessageViewState extends State<ChatMessageView> {
  late bool _isMe;

  @override
  void initState() {
    super.initState();
    _isMe = widget.authorId == locate<AuthService>().currentUserId!;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      child: Row(
        mainAxisAlignment:
            _isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!_isMe)
            CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person),
            ),
          SizedBox(width: 8.0),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: _isMe ? Theme.of(context).primaryColor : Colors.grey[200],
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              widget.message,
              style: TextStyle(color: _isMe ? Colors.white : Colors.black),
            ),
          ),
          SizedBox(width: 8.0),
          if (_isMe)
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(Icons.person),
            ),
        ],
      ),
    );
  }
}
