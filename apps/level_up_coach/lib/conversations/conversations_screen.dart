import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up_coach/auth/auth_service.dart';
import 'package:level_up_coach/conversations/conversation_list_item.dart';
import 'package:level_up_coach/conversations/models/conversation.dart';
import 'package:level_up_coach/conversations/services/conversations_service.dart';
import 'package:level_up_shared/level_up_shared.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Conversations')),
      body: FutureBuilder<List<Conversation>>(
        future: locate<ConversationsService>().retrieveConversations(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final error = snapshot.error;
            // Check for error indicating user does not have permission
            if (error is FirebaseException &&
                error.code == 'permission-denied') {
              return Center(
                child: Text(
                  'You do not yet have Coach priveleges.\n\nApply in Profile.',
                ),
              );
            }
            return Center(child: Text(snapshot.error.toString()));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Conversation> conversations = snapshot.data!;
          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return ConversationListItem(
                conversation: conversation,
                onTap: () {
                  context.pushNamed(
                    'chat',
                    pathParameters: {
                      'clientId': conversation.id,
                      'coachId': locate<AuthService>().currentUserId!,
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
