// providers/payment_provider.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  // Add to PaymentProvider class
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
}
