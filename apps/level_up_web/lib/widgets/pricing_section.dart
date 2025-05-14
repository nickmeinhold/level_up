import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PricingSection extends StatelessWidget {
  const PricingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Affordable Excellence',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PricingCard(
              title: 'LevelUp App',
              price: '\$29/month',
              features: const [
                'Custom workout plans',
                'Nutrition guidance',
                'Progress tracking',
                'Community support',
              ],
            ),
            const SizedBox(width: 40),
            PricingCard(
              title: 'Personal Trainer',
              price: '\$99/month',
              features: const [
                'Everything in LevelUp App',
                '1-on-1 video sessions',
                'Customized coaching',
                'Priority support',
              ],
              isFeatured: true,
            ),
          ],
        ),
      ],
    );
  }
}

class PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final List<String> features;
  final bool isFeatured;

  const PricingCard({
    super.key,
    required this.title,
    required this.price,
    required this.features,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: isFeatured ? Colors.blue[50] : null,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isFeatured ? Colors.blue : null,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              price,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(feature),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/signup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFeatured ? Colors.blue : null,
              ),
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
