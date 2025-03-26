import 'package:flutter/material.dart';
import 'package:level_up/workout/models/exercise.dart';

class RepsExerciseView extends StatefulWidget {
  const RepsExerciseView({required this.exercise, super.key});

  final RepsExercise exercise;

  @override
  State<RepsExerciseView> createState() => _RepsExerciseViewState();
}

class _RepsExerciseViewState extends State<RepsExerciseView> {
  late final int _reps;
  late final int _sets;
  late final List<bool> _isChecked;

  @override
  void initState() {
    super.initState();
    _sets = widget.exercise.sets;
    _reps = widget.exercise.reps;
    _isChecked = List.filled(_sets, false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16.0),

        // Reps and sets checkboxes
        Row(
          children: [
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
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'REPS',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Column(
                    children: List.generate(_sets, (index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
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
                                '$_reps',
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
