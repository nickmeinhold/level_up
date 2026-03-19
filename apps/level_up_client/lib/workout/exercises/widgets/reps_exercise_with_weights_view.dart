import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up_shared/level_up_shared.dart';

class RepsExerciseWithWeightsView extends StatefulWidget {
  const RepsExerciseWithWeightsView({required this.exercise, super.key});

  final RepsExerciseWithWeight exercise;

  @override
  State<RepsExerciseWithWeightsView> createState() =>
      _RepsExerciseWithWeightsViewState();
}

class _RepsExerciseWithWeightsViewState
    extends State<RepsExerciseWithWeightsView> {
  late int _reps;
  late int _sets;
  late double _weight;
  late List<bool> _isChecked;
  int _numCompletedSets = 0;

  @override
  void initState() {
    super.initState();
    _reps = widget.exercise.reps;
    _sets = widget.exercise.sets;
    _weight = widget.exercise.weight;
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
                    'WEIGHT',
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
                              color: Colors.black,
                            ),
                            child: Center(
                              child: Text(
                                '$_weight',
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
