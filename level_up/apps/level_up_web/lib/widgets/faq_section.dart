import 'package:flutter/material.dart';

class FAQSection extends StatelessWidget {
  const FAQSection({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'question': 'How is LevelUp different from a personal trainer?',
        'answer': 'LevelUp provides...',
      },
      // Add more FAQs...
    ];

    return Column(
      children: [
        const Text(
          'Frequently Asked Questions',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ...faqs.map(
          (faq) => ExpansionTile(
            title: Text(faq['question']!),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(faq['answer']!),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
