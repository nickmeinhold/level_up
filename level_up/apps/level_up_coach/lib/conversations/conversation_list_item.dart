import 'package:flutter/material.dart';
import 'package:level_up_coach/conversations/models/conversation.dart';
import 'package:level_up_shared/level_up_shared.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationListItem extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const ConversationListItem({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: conversation.unreadCount > 0 ? Colors.white : Colors.blue[50],
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.black,
                  child: Image.network(
                    locate<ProfileService>().getProfilePicUrlForUser(
                      size: PicSize.small,
                      userId: conversation.id,
                    ),
                    fit: BoxFit.cover,
                    width: 56,
                    height: 56,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person, size: 20, color: Colors.grey);
                    },
                  ),
                ),

                if (conversation.unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                      constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                      child: Text(
                        conversation.unreadCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                conversation.unreadCount > 0
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        timeago.format(conversation.timestamp.toDate()),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight:
                              conversation.unreadCount > 0
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    conversation.lastMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          conversation.unreadCount > 0
                              ? Colors.grey[600]
                              : Colors.blue[800],
                      fontWeight:
                          conversation.unreadCount > 0
                              ? FontWeight.normal
                              : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (conversation.unreadCount > 0) SizedBox(width: 8),
            if (conversation.unreadCount > 0)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
