import 'package:flutter/material.dart';
import 'package:web/web.dart' hide Text;

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  void initState() {
    super.initState();
    window.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50], // Light green background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Success Icon
              Icon(
                Icons.check_circle_outline,
                color: Colors.green[700],
                size: 100,
              ),
              const SizedBox(height: 30),

              // Main Success Message
              Text(
                'Thanks for signing up!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              const SizedBox(height: 15),

              // Instruction Message
              Text(
                'You can now close this window.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.grey[700]),
              ),
              const SizedBox(height: 50),

              // Call to Action / Next Step Message
              Text(
                "Let's get to work!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 20),

              // Optional: A small message if the user doesn't close it
              Text(
                'Your subscription is active and ready.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
