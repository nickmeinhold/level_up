import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up_coach/utils/locator.dart';
import 'package:level_up_coach/workouts/services/workouts_service.dart';
import 'package:level_up_shared/level_up_shared.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final String workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  bool _uploading = false;

  Future<void> _pickFile() async {
    setState(() {
      _uploading = true;
    });
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['png'],
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        Uint8List fileData = Uint8List(0);

        if (file.bytes != null) {
          // Web or when bytes are available
          fileData = file.bytes!;
        } else if (file.path != null) {
          // Native platforms
          fileData = await File(file.path!).readAsBytes();
        }

        locate<WorkoutsService>().uploadWorkoutImage(
          widget.workoutId,
          fileData,
        );
      } else {
        log('User canceled the picker');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Workout>(
      stream: locate<WorkoutsService>().workoutStream(widget.workoutId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        Workout workout = snapshot.data!;
        // Retrieve the exercises and add them to the exercises stream
        locate<WorkoutsService>().retrieveAndStreamExercises(
          workout.exerciseIds,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(workout.description),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  context.pushNamed<String>(
                    'create-exercise',
                    pathParameters: {'workoutId': widget.workoutId},
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(workout.description),
                ),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child:
                            (_uploading)
                                ? CircularProgressIndicator()
                                : ElevatedButton(
                                  onPressed: _pickFile,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    'Upload Image',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                      ),
                      FutureBuilder<String>(
                        future: locate<WorkoutsService>().getWorkoutImageUrl(
                          widget.workoutId,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(snapshot.error.toString()),
                            );
                          }
                          if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                          }
                          return Image.network(snapshot.data!);
                        },
                      ),
                    ],
                  ),
                ),
                Text(
                  'Exercises (${workout.exerciseIds.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<List<Exercise>>(
                    stream: locate<WorkoutsService>().exercisesStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text(snapshot.error.toString()));
                      }
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      List<Exercise> exercises = snapshot.data!;
                      return ListView.builder(
                        itemCount: exercises.length,
                        itemBuilder: (context, index) {
                          Exercise exercise = exercises[index];
                          return switch (exercise) {
                            TimedExercise() => TimedExerciseWidget(
                              exercise: exercise,
                            ),
                            RepsExerciseWithWeight() =>
                              RepsExerciseWithWeightWidget(exercise: exercise),
                            RepsExercise() => RepsExerciseWidget(
                              exercise: exercise,
                            ),
                          };
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TimedExerciseWidget extends StatelessWidget {
  const TimedExerciseWidget({super.key, required this.exercise});

  final TimedExercise exercise;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Sets: ${exercise.sets}'),
            Text('Time: ${exercise.time}'),
          ],
        ),
      ),
    );
  }
}

class RepsExerciseWidget extends StatelessWidget {
  const RepsExerciseWidget({super.key, required this.exercise});

  final RepsExercise exercise;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Sets: ${exercise.sets}'),
            Text('Reps: ${exercise.reps}'),
          ],
        ),
      ),
    );
  }
}

class RepsExerciseWithWeightWidget extends StatelessWidget {
  const RepsExerciseWithWeightWidget({super.key, required this.exercise});

  final RepsExerciseWithWeight exercise;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Sets: ${exercise.sets}'),
            Text('Reps: ${exercise.reps}'),
            Text('Weight: ${exercise.weight} kg'),
          ],
        ),
      ),
    );
  }
}
