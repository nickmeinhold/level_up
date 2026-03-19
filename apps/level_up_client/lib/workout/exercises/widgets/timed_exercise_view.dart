import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up_shared/level_up_shared.dart';

const int kSecondsPerMinute = 60;

class TimedExerciseView extends StatefulWidget {
  const TimedExerciseView({required this.exercise, super.key});

  final TimedExercise exercise;

  @override
  State<TimedExerciseView> createState() => _TimedExerciseViewState();
}

class _TimedExerciseViewState extends State<TimedExerciseView> {
  Timer? _timer;
  late int _countdown;
  bool _isCountdownActive = false;
  late int _sets;
  late List<bool> _isChecked;
  int _numCompletedSets = 0;

  @override
  void initState() {
    super.initState();
    _countdown = widget.exercise.time;
    _sets = widget.exercise.sets;
    _isChecked = List.filled(_sets, false);
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
      _countdown = widget.exercise.time;
      _isCountdownActive = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _isCountdownActive = false;
          timer.cancel();
          _timeIsUp();
        }
      });
    });
  }

  Future<void> _timeIsUp() async {
    final choseRepeat = await context.push<bool>('/time-up');
    if (mounted) {
      setState(() {
        if (choseRepeat!) {
          _numCompletedSets++;
        }
        if (_numCompletedSets == _isChecked.length) {
          context.pop();
        }
        for (int i = 0; i < _isChecked.length; i++) {
          if (i < _numCompletedSets) {
            _isChecked[i] = true;
          } else {
            _isChecked[i] = false;
          }
        }
        _countdown = widget.exercise.time;
      });
    }
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ kSecondsPerMinute;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Play button with countdown and checkbox
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _isCountdownActive
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                size: 100.0,
                color: Colors.lightBlue,
              ),
              onPressed: _startCountdown,
            ),
            const SizedBox(width: 8.0),
            Text(
              _formatTime(_countdown),
              style: const TextStyle(
                fontSize: 56.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16.0),

        // Reps and sets checkboxes
        Row(
          children: [
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SET',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Column(
                    children: List.generate(_sets, (index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _sets = index + 1;
                            });
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  _sets >= index + 1
                                      ? Colors.green
                                      : Colors.grey[300],
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color:
                                      _sets >= index + 1
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('', style: TextStyle(fontWeight: FontWeight.bold)),
                  Column(
                    children: List.generate(_sets, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Checkbox(
                          value: _isChecked[index],
                          onChanged: (newValue) {
                            setState(() {
                              _isChecked[index] = newValue!;

                              if (newValue) {
                                _numCompletedSets = index + 1;
                              }

                              if (_numCompletedSets == _isChecked.length) {
                                context.pop();
                              }
                            });
                          },
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
    );
  }
}
