// screens/payment_success_screen.dart
import 'package:flutter/material.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String sessionId;

  const PaymentSuccessScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Successful')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text(
              'Thank you for your purchase!',
              style: TextStyle(fontSize: 24),
            ),
            Text('Order ID: $sessionId'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  () => Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('Return to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
