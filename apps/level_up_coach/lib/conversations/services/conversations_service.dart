import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:level_up_coach/conversations/models/conversation.dart';

class ConversationsService {
  ConversationsService({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<List<Conversation>> retrieveConversations() async {
    // An async function to retrieve the profile data, called for each clientId
    Future<Conversation> retrieveConversationsData(
      Map<String, Object?> partialConversation,
    ) async {
      final clientId = partialConversation['id'] as String;
      final profileDocSnapshot =
          await _firestore.collection('profiles').doc(clientId).get();
      final profileJson = profileDocSnapshot.data() ?? {};

      AggregateQuerySnapshot snapshot =
          await _firestore
              .collection('conversations')
              .doc(clientId)
              .collection('messages')
              .where('read', isEqualTo: false)
              .count()
              .get();

      if (snapshot.count == null) {
        throw 'Getting the count of unread messages returned null';
      }
      partialConversation['unreadCount'] = snapshot.count;

      partialConversation.addAll(profileJson);
      return Conversation.fromJson(json: partialConversation);
    }

    final QuerySnapshot<Map<String, Object?>> querySnapshot =
        await _firestore.collection('conversations').get();

    Iterable<Map<String, Object?>> partialConversations = querySnapshot.docs
        .map<Map<String, Object?>>((docSnapshot) {
          final json = docSnapshot.data();
          json['id'] = docSnapshot.id;
          return json;
        });

    var futures = <Future<Conversation>>[];
    for (final partial in partialConversations) {
      futures.add(retrieveConversationsData(partial));
    }
    List<Conversation> conversations = await Future.wait(futures);

    return conversations;
  }
}
