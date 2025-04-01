import 'package:level_up_coach/conversations/models/conversation.dart';

class ConversationsService {
  final List<Conversation> conversations = [
    Conversation(
      name: 'John Doe',
      clientId: '1',
      lastMessage: 'Hey, how are you doing?',
      avatarUrl: 'https://example.com/avatar1.jpg',
      time: '10:30 AM',
      isRead: false,
      unreadCount: 3,
    ),
    Conversation(
      name: 'Jane Smith',
      clientId: '2',
      lastMessage: 'Meeting at 2pm tomorrow',
      avatarUrl: 'https://example.com/avatar2.jpg',
      time: 'Yesterday',
      isRead: true,
      unreadCount: 0,
    ),
    Conversation(
      name: 'Team Flutter',
      clientId: '3',
      lastMessage: 'Alice: I fixed the bug!',
      avatarUrl: 'https://example.com/avatar3.jpg',
      time: '2 days ago',
      isRead: false,
      unreadCount: 1,
    ),
    Conversation(
      name: 'Mom',
      clientId: '4',
      lastMessage: 'Call me when you get home',
      avatarUrl: 'https://example.com/avatar4.jpg',
      time: '1 hour ago',
      isRead: true,
      unreadCount: 0,
    ),
  ];
}
