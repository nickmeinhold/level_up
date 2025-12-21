import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentModal extends StatefulWidget {
  final String planName;
  final double planPrice;
  final bool isAnnual;

  const PaymentModal({
    super.key,
    required this.planName,
    required this.planPrice,
    this.isAnnual = false,
  });

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isProcessing = false;
  bool _savePaymentInfo = true;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Complete Your Purchase',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildPlanSummary(),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildCardNumberField(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildExpiryField()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildCvvField()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildNameField(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _savePaymentInfo,
                          onChanged: (value) {
                            setState(() {
                              _savePaymentInfo = value ?? false;
                            });
                          },
                        ),
                        const Text(
                          'Save payment information for future purchases',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  child:
                      _isProcessing
                          ? const CircularProgressIndicator()
                          : Text(
                            'Pay \$${widget.planPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your payment is secure and encrypted',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: Colors.blue),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.planName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                widget.isAnnual
                    ? 'Annual Plan (Billed Yearly)'
                    : 'Monthly Plan (Billed Monthly)',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '\$${widget.planPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            widget.isAnnual ? '/year' : '/month',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCardNumberField() {
    return TextFormField(
      controller: _cardNumberController,
      decoration: const InputDecoration(
        labelText: 'Card Number',
        prefixIcon: Icon(Icons.credit_card),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(16),
        CardNumberFormatter(),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter card number';
        }
        if (value.length < 16) {
          return 'Invalid card number';
        }
        return null;
      },
    );
  }

  Widget _buildExpiryField() {
    return TextFormField(
      controller: _expiryController,
      decoration: const InputDecoration(
        labelText: 'MM/YY',
        prefixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
        CardExpiryFormatter(),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter expiry date';
        }
        if (value.length < 5) {
          return 'Invalid expiry date';
        }
        return null;
      },
    );
  }

  Widget _buildCvvField() {
    return TextFormField(
      controller: _cvvController,
      decoration: const InputDecoration(
        labelText: 'CVV',
        prefixIcon: Icon(Icons.lock),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      obscureText: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter CVV';
        }
        if (value.length < 3) {
          return 'Invalid CVV';
        }
        return null;
      },
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Name on Card',
        prefixIcon: Icon(Icons.person),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter name';
        }
        return null;
      },
    );
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you would integrate with a payment processor like Stripe
      // await _paymentService.processPayment(
      //   cardNumber: _cardNumberController.text,
      //   expiry: _expiryController.text,
      //   cvv: _cvvController.text,
      //   name: _nameController.text,
      //   amount: widget.planPrice,
      // );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

// Custom formatters for card input
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length >= 16) {
      return TextEditingValue(
        text:
            '${text.substring(0, 4)} ${text.substring(4, 8)} '
            '${text.substring(8, 12)} ${text.substring(12, 16)}',
        selection: TextSelection.collapsed(offset: 19),
      );
    } else if (text.length >= 12) {
      return TextEditingValue(
        text:
            '${text.substring(0, 4)} ${text.substring(4, 8)} '
            '${text.substring(8, 12)}',
        selection: TextSelection.collapsed(offset: 14),
      );
    } else if (text.length >= 8) {
      return TextEditingValue(
        text: '${text.substring(0, 4)} ${text.substring(4, 8)}',
        selection: TextSelection.collapsed(offset: 9),
      );
    } else if (text.length >= 4) {
      return TextEditingValue(
        text: text.substring(0, 4),
        selection: TextSelection.collapsed(offset: 4),
      );
    }
    return newValue;
  }
}

class CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length >= 4) {
      return TextEditingValue(
        text: '${text.substring(0, 2)}/${text.substring(2, 4)}',
        selection: TextSelection.collapsed(offset: 5),
      );
    } else if (text.length >= 2) {
      return TextEditingValue(
        text: '${text.substring(0, 2)}/',
        selection: TextSelection.collapsed(offset: 3),
      );
    }
    return newValue;
  }
}
