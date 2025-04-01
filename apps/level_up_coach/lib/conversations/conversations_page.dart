import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up_coach/conversations/conversation_list_item.dart';
import 'package:level_up_coach/conversations/services/conversations_service.dart';
import 'package:level_up_coach/utils/locator.dart';

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversations'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: locate<ConversationsService>().conversations.length,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          final conversation =
              locate<ConversationsService>().conversations[index];
          return ConversationListItem(
            conversation: conversation,
            onTap: () {
              context.pushNamed(
                'chat',
                pathParameters: {'clientId': conversation.clientId},
              );
            },
          );
        },
      ),
    );
  }
}
