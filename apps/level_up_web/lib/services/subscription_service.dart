// providers/payment_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:level_up_shared/level_up_shared.dart';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class SubscriptionService {
  SubscriptionService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> processWebPayment({
    required String productId,
    required double amount,
  }) async {
    // 1. Create Checkout Session on your server
    final response = await http.post(
      Uri.parse('YOUR_BACKEND_URL/create-checkout-session'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'product_id': productId,
        'amount': amount,
        'success_url':
            '${Uri.base.origin}/success?session_id={CHECKOUT_SESSION_ID}',
        'cancel_url': '${Uri.base.origin}/cancel',
      }),
    );

    final jsonResponse = json.decode(response.body);
    final sessionId = jsonResponse['sessionId'];

    // 2. Redirect to Stripe Checkout
    await launchUrl(Uri.parse('https://checkout.stripe.com/pay/$sessionId'));
  }

  Future<SubscriptionStatus> retrieveSubscriptionStatus() async {
    if (_auth.currentUser == null) {
      throw 'You must be signed in to see your subscription status.';
    }

    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore
            .collection('subscriptions')
            .doc(_auth.currentUser!.uid)
            .get();

    switch (snapshot['status']) {
      case 'active':
        return SubscriptionStatus.active;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      case 'incomplete':
        return SubscriptionStatus.incomplete;
      default:
        return SubscriptionStatus.incomplete;
    }
  }
}
