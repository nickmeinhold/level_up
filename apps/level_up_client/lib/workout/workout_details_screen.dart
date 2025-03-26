import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up/utils/locator.dart';
import 'package:level_up/workout/models/workout.dart';
import 'package:level_up/workout/services/workouts_service.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  const WorkoutDetailsScreen({required this.workoutId, super.key});

  final String workoutId;

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> {
  int _currentStep = 0;
  late Workout _workout;

  @override
  void initState() {
    super.initState();
    _workout = locate<WorkoutsService>().retrieveWorkout(widget.workoutId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 10,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(125),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: Image.asset(
                  _workout.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0, top: 18.0),
                      child: Text(
                        'DESCRIPTION',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_workout.description),
                ),
              ],
            ),
          ),
          // Bottom two-thirds: Stepper
          Expanded(
            flex: 15,
            child: Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepTapped: (step) {
                _currentStep = step;
                context.pushNamed(
                  'exercise-screen',
                  pathParameters: {
                    'workoutId': widget.workoutId,
                    'exerciseNum': '$_currentStep',
                  },
                );
                // setState(() {
                //   _currentStep = step;
                // });
              },
              // onStepContinue: () {
              //   setState(() {
              //     if (_currentStep < 2) {
              //       _currentStep++;
              //     }
              //   });
              // },
              // onStepCancel: () {
              //   setState(() {
              //     if (_currentStep > 0) {
              //       _currentStep--;
              //     }
              //   });
              // },
              controlsBuilder: (context, controls) {
                return SizedBox(
                  height: 30,
                  child: LinearProgressIndicator(value: 0.0),
                );
              },
              steps: [
                for (int i = 0; i < _workout.exercises.length; i++)
                  Step(
                    title: Text(_workout.exercises[i].title),
                    subtitle: Text(_workout.exercises[i].subtitle),
                    content: SizedBox.shrink(),
                    state:
                        _currentStep > i
                            ? StepState.complete
                            : StepState.indexed,
                    isActive: _currentStep > i,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
