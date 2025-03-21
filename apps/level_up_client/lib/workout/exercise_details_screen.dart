// import 'package:flutter/material.dart';
// import 'package:level_up/workout/models/exercise.dart';

// class ExerciseDetailsScreen extends StatefulWidget {
//   const ExerciseDetailsScreen({super.key, required this.exerciseId});

//   final String exerciseId;

//   @override
//   State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
// }

// class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
//   late Exercise _exercise;

//   @override
//   void initState() {
//     super.initState();
//     // _exercise =
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:async';

class ExerciseDetailsScreen extends StatefulWidget {
  const ExerciseDetailsScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  State<ExerciseDetailsScreen> createState() => _WorkoutVideoRouteState();
}

class _WorkoutVideoRouteState extends State<ExerciseDetailsScreen> {
  late YoutubePlayerController _controller;
  bool _isChecked = false;
  int _countdown = 60; // 60 seconds countdown
  bool _isCountdownActive = false;
  Timer? _timer;
  int _reps = 0;
  int _rounds = 0;

  @override
  void initState() {
    super.initState();
    // Replace with your YouTube video ID
    const String videoId = 'dQw4w9WgXcQ'; // Example video ID

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    if (_isCountdownActive) {
      _timer?.cancel();
      setState(() {
        _isCountdownActive = false;
      });
      return;
    }

    setState(() {
      _countdown = 60;
      _isCountdownActive = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _isCountdownActive = false;
          timer.cancel();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Video'),
        backgroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // YouTube video with fixed height
            SizedBox(
              height: screenHeight / 3,
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.red,
                progressColors: const ProgressBarColors(
                  playedColor: Colors.red,
                  handleColor: Colors.redAccent,
                ),
              ),
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
                    child: const Text(
                      'This workout focuses on building core strength and endurance. Follow along with the video and complete the required reps and rounds. Make sure to maintain proper form throughout the exercise.',
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
                          onPressed: () {},
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

                  // Play button with countdown and checkbox
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isCountdownActive
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          size: 40.0,
                          color: Colors.red,
                        ),
                        onPressed: _startCountdown,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        _formatTime(_countdown),
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const Text('Completed'),
                      Checkbox(
                        value: _isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            _isChecked = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16.0),

                  // Reps and rounds checkboxes
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'REPS',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: List.generate(5, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _reps = index + 1;
                                      });
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            _reps >= index + 1
                                                ? Colors.blue
                                                : Colors.grey[300],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color:
                                                _reps >= index + 1
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ROUNDS',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: List.generate(5, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _rounds = index + 1;
                                      });
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            _rounds >= index + 1
                                                ? Colors.green
                                                : Colors.grey[300],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color:
                                                _rounds >= index + 1
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Adding some bottom padding for better scrolling experience
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
