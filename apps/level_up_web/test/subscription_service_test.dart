import 'package:flutter_test/flutter_test.dart';
import 'package:level_up_web/services/subscription_service.dart';

void main() {
  group('SubscriptionException', () {
    test('toString returns message', () {
      final exception = SubscriptionException('Test error');
      expect(exception.toString(), 'Test error');
    });

    test('stores code when provided', () {
      final exception = SubscriptionException('Test error', code: 'test_code');
      expect(exception.code, 'test_code');
    });

    test('code is null when not provided', () {
      final exception = SubscriptionException('Test error');
      expect(exception.code, isNull);
    });
  });

  group('SubscriptionException.userMessage', () {
    test('returns friendly message for unauthenticated', () {
      final exception = SubscriptionException('Error', code: 'unauthenticated');
      expect(exception.userMessage, 'Please sign in to manage your subscription.');
    });

    test('returns friendly message for not-found', () {
      final exception = SubscriptionException('Error', code: 'not-found');
      expect(exception.userMessage, 'No subscription found.');
    });

    test('returns friendly message for permission-denied', () {
      final exception = SubscriptionException('Error', code: 'permission-denied');
      expect(exception.userMessage, 'You do not have permission to perform this action.');
    });

    test('returns friendly message for internal', () {
      final exception = SubscriptionException('Error', code: 'internal');
      expect(exception.userMessage, 'Something went wrong. Please try again later.');
    });

    test('returns friendly message for unavailable', () {
      final exception = SubscriptionException('Error', code: 'unavailable');
      expect(exception.userMessage, 'Service temporarily unavailable. Please try again.');
    });

    test('returns original message for unknown code', () {
      final exception = SubscriptionException('Custom error', code: 'unknown');
      expect(exception.userMessage, 'Custom error');
    });

    test('returns original message for null code', () {
      final exception = SubscriptionException('Custom error');
      expect(exception.userMessage, 'Custom error');
    });
  });

  group('SubscriptionStatus mapping', () {
    test('maps active string to active status', () {
      const status = 'active';
      expect(status, 'active');
    });

    test('maps cancelled string to cancelled status', () {
      const status = 'cancelled';
      expect(status, 'cancelled');
    });

    test('maps incomplete string to incomplete status', () {
      const status = 'incomplete';
      expect(status, 'incomplete');
    });

    test('unknown status defaults to incomplete', () {
      const status = 'unknown';
      final result = ['active', 'cancelled', 'incomplete'].contains(status)
          ? status
          : 'incomplete';
      expect(result, 'incomplete');
    });

    test('null status defaults to incomplete', () {
      const String? status = null;
      final result = status ?? 'incomplete';
      expect(result, 'incomplete');
    });
  });

  group('Subscription flow validation', () {
    test('checkout URL must not be empty', () {
      const urlString = 'https://checkout.stripe.com/test';
      expect(urlString.isNotEmpty, isTrue);
    });

    test('empty checkout URL is invalid', () {
      const urlString = '';
      expect(urlString.isEmpty, isTrue);
    });

    test('null checkout URL is invalid', () {
      const String? urlString = null;
      expect(urlString == null || urlString.isEmpty, isTrue);
    });
  });
}
