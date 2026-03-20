import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up_client/workout/exercises/widgets/reps_exercise_view.dart';
import 'package:level_up_client/workout/exercises/widgets/reps_exercise_with_weights_view.dart';
import 'package:level_up_client/workout/exercises/widgets/timed_exercise_view.dart';
import 'package:level_up_client/workout/services/workouts_service.dart';
import 'package:level_up_shared/level_up_shared.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  const ExerciseDetailsScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  YoutubePlayerController? _controller;
  Exercise? _exercise;
  bool _loadingExercise = true;
  String? _error;

  Future<void> _retrieveExercise() async {
    try {
      final exercise = await locate<WorkoutsService>().retrieveExercise(
        widget.exerciseId,
      );

      if (mounted) {
        setState(() {
          _exercise = exercise;
          _controller = YoutubePlayerController(
            initialVideoId: exercise.youtubeId ?? 'dQw4w9WgXcQ',
            flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
          );
          _loadingExercise = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load exercise. Please check your connection.';
          _loadingExercise = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _retrieveExercise();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Video')),
      body:
          (_loadingExercise)
              ? Center(child: CircularProgressIndicator())
              : (_error != null || _exercise == null)
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _error ?? 'Something went wrong.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _loadingExercise = true;
                          _error = null;
                        });
                        _retrieveExercise();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  children: [
                    // YouTube video with fixed height
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return YoutubePlayer(
                          controller: _controller!,
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
                              _exercise!.description,
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),

                          const SizedBox(height: 16.0),

                          // Two buttons row
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.pushNamed(
                                      'chat-screen',
                                      pathParameters: {
                                        'conversationId':
                                            locate<AuthService>()
                                                .currentUserId!,
                                        'currentUserId':
                                            locate<AuthService>()
                                                .currentUserId!,
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
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

                          switch (_exercise!) {
                            final TimedExercise e => TimedExerciseView(
                              exercise: e,
                            ),
                            final RepsExerciseWithWeight e =>
                              RepsExerciseWithWeightsView(exercise: e),
                            final RepsExercise e => RepsExerciseView(
                              exercise: e,
                            ),
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
