// widgets/payment_modal.dart
import 'package:flutter/material.dart';
import 'package:level_up_web/services/payment_service.dart';
import 'package:level_up_web/utils/locator.dart';

class PaymentModal extends StatefulWidget {
  final String productName;
  final double amount;
  final String productId;

  const PaymentModal({
    super.key,
    required this.productName,
    required this.amount,
    required this.productId,
  });

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Join ${widget.productName}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 20),
          Text(
            'Price: \$${widget.amount}/month',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 30),
          const Text(
            'Payment Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Stripe Card Field would go here in a mobile app
          // For web, we'll use Stripe Elements (see next section)
          const Spacer(),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      setState(() {
                        _isLoading = true;
                      });
                      await locate<PaymentService>().processWebPayment(
                        productId: widget.productId,
                        amount: widget.amount,
                      );
                      setState(() {
                        _isLoading = false;
                      });

                      if (!_isLoading &&
                          _errorMessage == null &&
                          context.mounted) {
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        _errorMessage = e.toString();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Payment failed: ${e.toString()}'),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Complete Payment'),
                ),
              ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
