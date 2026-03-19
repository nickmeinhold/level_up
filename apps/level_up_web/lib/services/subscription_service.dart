import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:level_up_shared/level_up_shared.dart';

import 'package:url_launcher/url_launcher.dart';

/// Exception thrown when a subscription operation fails.
class SubscriptionException implements Exception {
  final String message;
  final String? code;

  SubscriptionException(this.message, {this.code});

  @override
  String toString() => message;

  /// Returns a user-friendly error message based on the error code.
  String get userMessage {
    switch (code) {
      case 'unauthenticated':
        return 'Please sign in to manage your subscription.';
      case 'not-found':
        return 'No subscription found.';
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'internal':
        return 'Something went wrong. Please try again later.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again.';
      default:
        return message;
    }
  }
}

class SubscriptionService {
  SubscriptionService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Initiates the web payment flow by creating a checkout session
  /// and redirecting to Stripe.
  ///
  /// Throws [SubscriptionException] if the operation fails.
  Future<void> processWebPayment() async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'createCheckoutSession',
      );

      final result = await callable.call({});
      final urlString = result.data['url'] as String?;

      if (urlString == null || urlString.isEmpty) {
        throw SubscriptionException(
          'Failed to get checkout URL',
          code: 'internal',
        );
      }

      final launched = await launchUrl(
        Uri.parse(urlString),
        webOnlyWindowName: '_self',
      );

      if (!launched) {
        throw SubscriptionException(
          'Failed to open checkout page',
          code: 'launch-failed',
        );
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Firebase Functions error: ${e.code} - ${e.message}');
      throw SubscriptionException(
        e.message ?? 'Failed to create checkout session',
        code: e.code,
      );
    } catch (e) {
      if (e is SubscriptionException) rethrow;
      debugPrint('Error processing payment: $e');
      throw SubscriptionException(
        'An unexpected error occurred',
        code: 'unknown',
      );
    }
  }

  /// Cancels the current subscription.
  ///
  /// Throws [SubscriptionException] if the operation fails.
  Future<void> cancelSubscription() async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'cancelSubscription',
      );

      await callable.call({});
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Firebase Functions error: ${e.code} - ${e.message}');
      throw SubscriptionException(
        e.message ?? 'Failed to cancel subscription',
        code: e.code,
      );
    } catch (e) {
      if (e is SubscriptionException) rethrow;
      debugPrint('Error canceling subscription: $e');
      throw SubscriptionException(
        'An unexpected error occurred',
        code: 'unknown',
      );
    }
  }

  /// Returns a stream of the current user's subscription status.
  ///
  /// Throws [SubscriptionException] if the user is not signed in.
  Stream<SubscriptionStatus> subscriptionStatusStream() {
    if (_auth.currentUser == null) {
      throw SubscriptionException(
        'You must be signed in to see your subscription status.',
        code: 'unauthenticated',
      );
    }

    return _firestore
        .collection('subscriptions')
        .doc(_auth.currentUser!.uid)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            return SubscriptionStatus.incomplete;
          }

          final status = snapshot.data()!['status'] as String?;
          switch (status) {
            case 'active':
              return SubscriptionStatus.active;
            case 'cancelled':
              return SubscriptionStatus.cancelled;
            case 'incomplete':
            default:
              return SubscriptionStatus.incomplete;
          }
        });
  }
}
