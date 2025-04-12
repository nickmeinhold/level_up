// widgets/coaching_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:level_up_web/widgets/payment_modal.dart';

class CoachingCard extends StatelessWidget {
  final String title;
  final double price;
  final List<String> features;
  final String productId;

  const CoachingCard({
    super.key,
    required this.title,
    required this.price,
    required this.features,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.robotoCondensed(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text('\$$price/month', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ...features
                .map(
                  (feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        const Icon(Icons.check, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(feature),
                      ],
                    ),
                  ),
                )
                .toList(),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder:
                      (context) => PaymentModal(
                        productName: title,
                        amount: price,
                        productId: productId,
                      ),
                );
              },
              child: const Text(
                'JOIN NOW',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
