import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:level_up_coach/conversations/models/chat_message.dart';
import 'package:level_up_coach/conversations/models/conversation.dart';

class ConversationsService {
  ConversationsService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _firestore = firestore,
       _auth = auth;

  final FirebaseAuth _auth;
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

  Future<void> send({required String message, required String clientId}) async {
    await _firestore.collection('conversations').doc(clientId).set({
      'lastMessage': message,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    DocumentReference<Map<String, dynamic>> _ = await _firestore
        .collection('conversations')
        .doc(clientId)
        .collection('messages')
        .add({
          'authorId': _auth.currentUser!.uid,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
          'read': true,
        });
  }

  Stream<List<ChatMessage>> getMessagesStream(String clientId) {
    return _firestore
        .collection('conversations')
        .doc(clientId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .map<List<ChatMessage>>((QuerySnapshot<Map<String, dynamic>> snapshot) {
          List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
              snapshot.docs;
          return docs.map<ChatMessage>((snapshot) {
            QueryDocumentSnapshot<Map<String, dynamic>> doc = snapshot;
            return ChatMessage.fromJsonWithId(doc.id, doc.data());
          }).toList();
        });
  }
}
