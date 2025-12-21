import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:level_up_shared/level_up_shared.dart';

import 'package:url_launcher/url_launcher.dart';

class SubscriptionService {
  SubscriptionService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> processWebPayment() async {
    final callable = FirebaseFunctions.instance.httpsCallable(
      'createCheckoutSession',
    );

    final result = await callable.call({});
    String urlString = result.data['url'] as String;
    await launchUrl(Uri.parse(urlString), webOnlyWindowName: '_self');
  }

  Future<void> cancelSubscription() async {
    final callable = FirebaseFunctions.instance.httpsCallable(
      'cancelSubscrition',
    );

    await callable.call({});
  }

  Stream<SubscriptionStatus> subscriptionStatusStream() {
    if (_auth.currentUser == null) {
      throw 'You must be signed in to see your subscription status.';
    }

    return _firestore
        .collection('subscriptions')
        .doc(_auth.currentUser!.uid)
        .snapshots()
        .map((snapshot) {
          switch (snapshot.data()!['status']) {
            case 'active':
              return SubscriptionStatus.active;
            case 'cancelled':
              return SubscriptionStatus.cancelled;
            case 'incomplete':
              return SubscriptionStatus.incomplete;
            default:
              return SubscriptionStatus.incomplete;
          }
        });
  }
}
