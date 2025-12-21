import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProgramDetailsScreen extends StatelessWidget {
  final String programId;

  const ProgramDetailsScreen({super.key, required this.programId});

  @override
  Widget build(BuildContext context) {
    // In a real app, you would fetch program details based on programId
    final programDetails =
        {
          'weight-loss': {
            'title': 'Weight Loss Program',
            'description': 'Our 12-week weight loss program combines...',
            'image': 'assets/weight_loss.jpg',
          },
          // Add other programs...
        }[programId];

    return Scaffold(
      appBar: AppBar(
        title: Text(programDetails?['title'] ?? 'Program Details'),
      ),
      body:
          programDetails == null
              ? const Center(child: Text('Program not found'))
              : SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset(programDetails['image']!),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(programDetails['description']!),
                    ),
                    ElevatedButton(
                      onPressed: () => context.push('/signup'),
                      child: const Text('Join This Program'),
                    ),
                  ],
                ),
              ),
    );
  }
}
