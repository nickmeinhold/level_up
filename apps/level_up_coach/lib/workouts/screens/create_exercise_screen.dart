import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up_coach/utils/locator.dart';
import 'package:level_up_coach/workouts/services/workouts_service.dart';
import 'package:level_up_shared/level_up_shared.dart';
import 'record_video_screen.dart';

class CreateExerciseScreen extends StatefulWidget {
  const CreateExerciseScreen({super.key, required this.workoutId});

  final String workoutId;

  @override
  State<CreateExerciseScreen> createState() => _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends State<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeController = TextEditingController();
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _setsController = TextEditingController();

  ExerciseType _selectedType = ExerciseType.timed;
  String? _videoUrl;

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    _setsController.dispose();
    super.dispose();
  }

  Future<String?> _saveExercise() async {
    if (_formKey.currentState!.validate()) {
      try {
        final exercise = switch (_selectedType) {
          ExerciseType.reps => RepsExercise(
            id: 'id',
            videoUrl: _videoUrl!,
            title: _titleController.text,
            subtitle: _subtitleController.text,
            description: _descriptionController.text,
            reps: int.parse(_repsController.text),
            sets: int.parse(_setsController.text),
          ),
          ExerciseType.timed => TimedExercise(
            id: 'id',
            videoUrl: _videoUrl!,
            title: _titleController.text,
            subtitle: _subtitleController.text,
            description: _descriptionController.text,
            time: int.parse(_timeController.text),
            sets: int.parse(_setsController.text),
          ),
          ExerciseType.repsWithWeight => RepsExerciseWithWeight(
            id: 'id',
            videoUrl: _videoUrl!,
            title: _titleController.text,
            subtitle: _subtitleController.text,
            description: _descriptionController.text,
            reps: int.parse(_repsController.text),
            sets: int.parse(_setsController.text),
            weight: double.parse(_weightController.text),
          ),
        };

        String exerciseId = await locate<WorkoutsService>().createExercise(
          exercise,
          widget.workoutId,
        );

        if (mounted) {
          context.pop(exerciseId);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving exercise: $e')));
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Exercise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final exerciseId = await _saveExercise();
              if (exerciseId != null && context.mounted) {
                context.pop(exerciseId);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subtitleController,
                decoration: const InputDecoration(
                  labelText: 'Subtitle',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subtitle';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ExerciseType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Exercise Type',
                  border: OutlineInputBorder(),
                ),
                items:
                    ExerciseType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      );
                    }).toList(),
                onChanged: (type) {
                  if (type != null) {
                    setState(() {
                      _selectedType = type;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_selectedType == ExerciseType.timed) ...[
                    Expanded(
                      child: TextFormField(
                        controller: _timeController,
                        decoration: const InputDecoration(
                          labelText: 'Time (sec)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty &&
                                  _selectedType == ExerciseType.timed) {
                            return 'Please enter a time';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],

                  if (_selectedType == ExerciseType.repsWithWeight) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty &&
                                  _selectedType ==
                                      ExerciseType.repsWithWeight) {
                            return 'Please enter a weight';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_selectedType == ExerciseType.repsWithWeight ||
                      _selectedType == ExerciseType.reps) ...[
                    Expanded(
                      child: TextFormField(
                        controller: _repsController,
                        decoration: const InputDecoration(
                          labelText: 'Reps',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty &&
                                  (_selectedType ==
                                          ExerciseType.repsWithWeight ||
                                      _selectedType == ExerciseType.reps)) {
                            return 'Please enter a value for reps';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: TextFormField(
                      controller: _setsController,
                      decoration: const InputDecoration(
                        labelText: 'Sets',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a value for reps';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_videoUrl != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Video attached:'),
                    Text(_videoUrl!),
                    const SizedBox(height: 8),
                  ],
                ),
              ElevatedButton.icon(
                icon: const Icon(Icons.videocam),
                label: const Text('Record Video'),
                onPressed: () async {
                  final videoUrl = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecordVideoScreen(),
                    ),
                  );

                  if (videoUrl != null) {
                    setState(() {
                      _videoUrl = videoUrl;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
