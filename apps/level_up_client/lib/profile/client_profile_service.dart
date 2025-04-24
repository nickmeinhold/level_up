import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:level_up_shared/level_up_shared.dart';

class ClientProfileService {
  ClientProfileService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<Client> retrieveClientUser() async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot =
        await _firestore
            .collection('profiles')
            .doc(_auth.currentUser!.uid)
            .get();

    return Client.fromJsonWithId(docSnapshot.id, docSnapshot.data() ?? {});
  }
}
