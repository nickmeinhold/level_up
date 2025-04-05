import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up/utils/locator.dart';
import 'package:level_up/workout/exercises/widgets/reps_exercise_view.dart';
import 'package:level_up/workout/exercises/widgets/reps_exercise_with_weights_view.dart';
import 'package:level_up/workout/exercises/widgets/timed_exercise_view.dart';
import 'package:level_up/workout/models/exercise.dart';
import 'package:level_up/workout/services/workouts_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  const ExerciseDetailsScreen({
    super.key,
    required this.workoutId,
    required this.exerciseNum,
  });

  final String workoutId;
  final String exerciseNum;

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  late YoutubePlayerController _controller;
  late final Exercise _exercise;

  @override
  void initState() {
    super.initState();

    _exercise =
        locate<WorkoutsService>()
            .retrieveWorkout(widget.workoutId)
            .exercises[int.parse(widget.exerciseNum)];

    _controller = YoutubePlayerController(
      initialVideoId: _exercise.videoUrl,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Video')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // YouTube video with fixed height
            LayoutBuilder(
              builder: (context, constraints) {
                return YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.red,
                  progressColors: const ProgressBarColors(
                    playedColor: Colors.red,
                    handleColor: Colors.redAccent,
                  ),
                );
              },
            ),

            // Rest of the content
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Description text
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      _exercise.description,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // Two buttons row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                          ),
                          child: const Text(
                            'COACH CHAT',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/video-form');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                          ),
                          child: const Text(
                            'SEND IN FORM',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20.0),

                  switch (_exercise) {
                    TimedExercise() => TimedExerciseView(exercise: _exercise),
                    RepsExerciseWithWeights() => RepsExerciseWithWeightsView(
                      exercise: _exercise,
                    ),
                    RepsExercise() => RepsExerciseView(exercise: _exercise),
                  },
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
