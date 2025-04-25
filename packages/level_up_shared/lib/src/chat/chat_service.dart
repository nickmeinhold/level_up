import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:level_up_shared/src/chat/chat_message.dart';

class ChatService {
  ChatService({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Stream<List<ChatMessage>> getMessagesStream({
    required String conversationId,
  }) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
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

  Future<void> send({
    required String message,
    required String conversationId,
    required String authorId,
  }) async {
    await _firestore.collection('conversations').doc(conversationId).set({
      'lastMessage': message,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    DocumentReference<Map<String, dynamic>> _ = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add({
          'authorId': authorId,
          'message': message,
          'type': 'text',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
  }

  Future<void> setMessageToRead(String conversationId, ChatMessage message) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(message.id)
        .set({'read': true}, SetOptions(merge: true));
  }
}
