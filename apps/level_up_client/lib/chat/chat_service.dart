import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:level_up_chat/chat_message.dart';

class ChatService {
  ChatService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> send(String message) async {
    await _firestore
        .collection('conversations')
        .doc(_auth.currentUser!.uid)
        .set({
          'lastMessage': message,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

    DocumentReference<Map<String, dynamic>> _ = await _firestore
        .collection('conversations')
        .doc(_auth.currentUser!.uid)
        .collection('messages')
        .add({
          'authorId': _auth.currentUser!.uid,
          'message': message,
          'type': 'text',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
  }

  Stream<List<ChatMessage>> get messagesStream {
    return _firestore
        .collection('conversations')
        .doc(_auth.currentUser!.uid)
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
