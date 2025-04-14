import 'package:flutter/material.dart';

class TextMessageView extends StatelessWidget {
  const TextMessageView({
    super.key,
    required this.message,
    required this.authorId,
    required this.currentUserId,
  });

  final String message;
  final String authorId;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final isMe = authorId == currentUserId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person),
            ),
          SizedBox(width: 8.0),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: isMe ? Theme.of(context).primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: isMe ? Radius.circular(16) : Radius.circular(4),
                  bottomRight: isMe ? Radius.circular(4) : Radius.circular(16),
                ),
              ),
              child: Text(
                message,
                style: TextStyle(color: isMe ? Colors.white : Colors.black),
              ),
            ),
          ),
          SizedBox(width: 8.0),
          if (isMe)
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(Icons.person),
            ),
        ],
      ),
    );
  }
}
