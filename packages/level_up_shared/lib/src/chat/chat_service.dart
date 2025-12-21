import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:level_up_shared/src/chat/chat_message.dart';

class ChatService {
  ChatService({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  final List<ChatMessage> _messages = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _streamSubscription;
  DocumentSnapshot? _lastSnapshot;

  final _messagesStreamController =
      StreamController<List<ChatMessage>>.broadcast();
  Stream<List<ChatMessage>> get messagesListStream =>
      _messagesStreamController.stream;

  void startListeningForLatestMessage(String conversationId) {
    _messages.clear();
    _lastSnapshot = null;

    _streamSubscription = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
          List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
              snapshot.docs;
          if (docs.isNotEmpty) {
            _lastSnapshot ??= docs.first;
            if (_messages.isEmpty || _messages.first.id != docs.first.id) {
              _messages.insert(
                0,
                ChatMessage.fromJsonWithId(docs.first.id, docs.first.data()),
              );
              _messagesStreamController.add(_messages);
            }
          } else {
            // if docs was empty we still need to emit so we can show empty UI
            _messagesStreamController.add(_messages);
          }
        });
  }

  void stopListeningForLatestMessage() {
    _streamSubscription?.cancel();
  }

  void retrievePreviousMessages(String conversationId) {
    if (_lastSnapshot == null) return;

    _streamSubscription = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .startAfterDocument(_lastSnapshot!)
        .limit(10)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                snapshot.docs;
            for (final doc in docs) {
              _messages.add(ChatMessage.fromJsonWithId(doc.id, doc.data()));
            }
            _lastSnapshot = docs.last;
            _messagesStreamController.add(_messages);
          }
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
