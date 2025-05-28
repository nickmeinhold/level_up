import 'package:flutter/material.dart';

class PricingSection extends StatelessWidget {
  const PricingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Why Choose LevelUp Over a Personal Trainer?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // For mobile responsiveness
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 850) {
                  // Desktop/tablet layout
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: _buildLevelUpCard(),
                      ),
                      const SizedBox(width: 40),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: _buildTrainerCard(),
                      ),
                    ],
                  );
                } else {
                  // Mobile layout - vertical stacking
                  return Column(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: _buildLevelUpCard(),
                      ),
                      const SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: _buildTrainerCard(),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelUpCard() {
    return PricingCard(
      title: 'LevelUp App',
      price: '\$29/month',
      features: const [
        'Always available 24/7',
        'Consistent, science-backed workouts',
        'Affordable pricing',
        'No scheduling conflicts',
        'Progress tracking & analytics',
        'Large exercise library',
      ],
      isPositive: true,
    );
  }

  Widget _buildTrainerCard() {
    return PricingCard(
      title: 'Personal Trainer',
      price: '\$99+/session',
      features: const [
        'Limited availability',
        'Inconsistent quality between trainers',
        'Expensive sessions',
        'Scheduling conflicts common',
        'Manual progress tracking',
        'Limited exercise knowledge',
      ],
      isPositive: false,
    );
  }
}

class PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final List<String> features;
  final bool isPositive;

  const PricingCard({
    super.key,
    required this.title,
    required this.price,
    required this.features,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: isPositive ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              price,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isPositive ? Icons.check : Icons.close,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          color:
                              isPositive ? Colors.green[800] : Colors.red[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isPositive)
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPositive ? Colors.green : Colors.red,
                ),
                child: const Text('Get Started'),
              ),
          ],
        ),
      ),
    );
  }
}
