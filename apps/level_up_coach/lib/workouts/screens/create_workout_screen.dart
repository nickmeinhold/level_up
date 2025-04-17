import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up_coach/utils/locator.dart';
import 'package:level_up_coach/workouts/services/workouts_service.dart';
import 'package:level_up_shared/level_up_shared.dart';

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final List<String> _exerciseIds = [];

  @override
  void dispose() {
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveWorkout() async {
    if (_formKey.currentState!.validate()) {
      try {
        final workout = Workout(
          id: '', // Firestore will generate ID
          description: _descriptionController.text,
          imageUrl: _imageUrlController.text,
          exerciseIds: [],
        );

        await locate<WorkoutsService>().createWorkout(workout);

        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving workout: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Workout'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveWorkout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Workout Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a workout description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image Url',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the image URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text('Exercises', style: TextStyle(fontSize: 18)),
              const Divider(),
              Expanded(
                child:
                    _exerciseIds.isEmpty
                        ? Center(
                          child: Text(
                            'No exercises added yet',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                        : ListView.builder(
                          itemCount: _exerciseIds.length,
                          itemBuilder: (context, index) {
                            // In a real app, you'd fetch and display exercise details
                            return ListTile(
                              title: Text('Exercise ${index + 1}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _exerciseIds.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
