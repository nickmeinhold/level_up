import 'package:flutter/material.dart';

class PaymentFailureScreen extends StatelessWidget {
  const PaymentFailureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50], // Light red background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Error Icon
              Icon(Icons.error_outline, color: Colors.red[700], size: 100),
              const SizedBox(height: 30),

              // Main Failure Message
              Text(
                'Sorry, there was a problem with your payment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[900],
                ),
              ),
              const SizedBox(height: 15),

              // Instruction Message
              Text(
                'Please close this window to review your account status.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.grey[700]),
              ),
              const SizedBox(height: 30),

              // Contact Email Message
              Text(
                'If you have any queries, please email',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[800]),
              ),
              const SizedBox(height: 5),
              Text(
                'contact@enspyr.co',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700], // Highlight email address
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'We apologize for the inconvenience.',
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
