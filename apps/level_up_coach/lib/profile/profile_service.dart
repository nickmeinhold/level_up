import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  ProfileService({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _auth = firebaseAuth,
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

  Future<bool> hasPendingApplication() async {
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
}
