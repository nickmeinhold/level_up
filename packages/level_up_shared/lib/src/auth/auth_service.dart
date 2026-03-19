import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore {
    // Initialize GoogleSignIn singleton (not needed on web - uses Firebase popup)
    if (!kIsWeb) {
      GoogleSignIn.instance.initialize();
    }
    // When a User object is emitted by the FirebaseAuth's onAuthStateChanges
    // stream we create a subscription to the firestore, which is cancelled on
    // sign out to avoid listening to the firestore while signed out.
    _authStateSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        if (profileStreamSubscription != null) {
          profileStreamSubscription!.cancel();
        }

        profileStreamSubscription = _firestore
            .doc('profiles/${user.uid}')
            .snapshots()
            .map<Map<String, Object?>?>((ref) {
              return ref.data();
            })
            .listen((profile) {
              if (profile != null) {
                _userSubject.add(profile);
              }
            });
      }
    });
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  final _userSubject = BehaviorSubject<Map<String, Object?>>.seeded({});
  StreamSubscription? _authStateSubscription;
  StreamSubscription<Map<String, Object?>?>? profileStreamSubscription;

  Stream<Map<String, Object?>?> get profileDocStream => _userSubject.stream;

  String? get currentUserId {
    return _auth.currentUser?.uid;
  }

  String? get currentUserEmail {
    return _auth.currentUser?.email;
  }

  /// Check shared prefs for onboarding status.
  Future<bool> get userHasOnboarded async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarded') ?? false;
  }

  Future<bool> saveOnboardingName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString('onboarding-name', name);
  }

  Future<void> signInWithGoogle() async {
    final UserCredential userCredential;
    if (kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      userCredential = await FirebaseAuth.instance.signInWithPopup(
        googleProvider,
      );
    } else {
      // google_sign_in v7: use singleton and authenticate()
      final GoogleSignInAccount googleUser;
      try {
        googleUser = await GoogleSignIn.instance.authenticate();
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          return; // User cancelled, do nothing
        }
        rethrow;
      }
      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
      );

      userCredential = await _auth.signInWithCredential(credential);
    }

    _onUserSignedIn(userCredential);
  }

  Future<void> signInWithApple() async {
    final appleProvider = AppleAuthProvider();
    appleProvider.addScope('email');
    appleProvider.addScope('name');

    final UserCredential userCredential;
    if (kIsWeb) {
      userCredential = await FirebaseAuth.instance.signInWithPopup(
        appleProvider,
      );
    } else {
      userCredential = await FirebaseAuth.instance.signInWithProvider(
        appleProvider,
      );
    }

    _onUserSignedIn(userCredential);
  }

  // If there is a name from the onboarding process in shared preferences, save
  // it to the database and remove shared preferences, otherwise just return.
  Future<void> _migrateNameToFirestore(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('onboarding-name');
    if (savedName == null || savedName.isEmpty) {
      return;
    }

    final profilesCollection = FirebaseFirestore.instance.collection(
      'profiles',
    );

    await profilesCollection.doc(userId).set({
      'name': savedName,
    }, SetOptions(merge: true));

    await prefs.remove('onboarding-name');
  }

  Future<void> _onUserSignedIn(UserCredential userCredential) async {
    if (userCredential.user == null) {
      throw 'The UserCredential returned on sign in had no user object';
    }
    await _migrateNameToFirestore(userCredential.user!.uid);
  }

  Future<void> signOut() async {
    await profileStreamSubscription?.cancel();
    await _authStateSubscription?.cancel();
    return _auth.signOut();
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
}
