import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProgramsSection extends StatelessWidget {
  const ProgramsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Our Programs',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: const [
            ProgramCard(
              id: 'weight-loss',
              title: 'Weight Loss',
              description: '12-week fat loss program',
              icon: Icons.fitness_center,
            ),
            ProgramCard(
              id: 'muscle-gain',
              title: 'Muscle Gain',
              description: 'Build lean muscle mass',
              icon: Icons.accessibility_new,
            ),
            ProgramCard(
              id: 'strength',
              title: 'Strength Training',
              description: 'Increase your power',
              icon: Icons.bolt,
            ),
          ],
        ),
      ],
    );
  }
}

class ProgramCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const ProgramCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/program/$id'),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 50, color: Colors.blue),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(description),
            ],
          ),
        ),
      ),
    );
  }
}
