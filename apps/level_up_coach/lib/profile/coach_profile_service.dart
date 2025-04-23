import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:level_up_coach/profile/models/client.dart';

class CoachProfileService {
  CoachProfileService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<bool> isCoach() async {
    // Check if user is already a coach
    if (_auth.currentUser == null) throw 'User was null';
    final coachDoc =
        await _firestore
            .collection('coachIds')
            .doc(_auth.currentUser!.uid)
            .get();
    return coachDoc.exists;
  }

  Future<bool> hasPendingCoachApplication() async {
    // Check for pending application
    if (_auth.currentUser == null) throw 'User was null';
    final applicationDoc =
        await _firestore
            .collection('coachApplications')
            .doc(_auth.currentUser!.uid)
            .get();

    return applicationDoc.exists;
  }

  Future<void> applyToBeCoach() async {
    if (_auth.currentUser == null) throw 'User was null';
    await _firestore
        .collection('coachApplications')
        .doc(_auth.currentUser!.uid)
        .set({
          'applicationDate': FieldValue.serverTimestamp(),
          'status': 'pending',
        });
  }

  Future<void> update({String? name}) async {
    if (_auth.currentUser == null) {
      throw Exception(
        'The user must be signed in and onboarded before the name is updated.',
      );
    }

    if (name != null) {
      await _firestore.doc('profiles/${_auth.currentUser!.uid}').set({
        'name': name,
      }, SetOptions(merge: true));
    }
  }

  Future<Client> retrieveClient() async {
    if (_auth.currentUser == null) {
      throw Exception(
        'The user must be signed in and onboarded before retrieving a Client.',
      );
    }

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.doc('profiles/${_auth.currentUser!.uid}').get();

    return Client.fromJsonWithId(id: snapshot.id, json: snapshot.data() ?? {});
  }
}
