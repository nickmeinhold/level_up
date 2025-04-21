import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:level_up/utils/locator.dart';
import 'package:level_up/workout/services/workouts_service.dart';
import 'package:level_up_shared/level_up_shared.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  const WorkoutDetailsScreen({required this.workoutId, super.key});

  final String workoutId;

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> {
  int _currentStep = 0;
  late Workout _workout;
  bool _loadingWorkout = true;

  Future<void> _loadWorkout() async {
    _workout = await locate<WorkoutsService>().retrieveWorkout(
      widget.workoutId,
    );
    if (mounted) {
      setState(() {
        _loadingWorkout = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadWorkout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:
          (_loadingWorkout)
              ? Center(child: CircularProgressIndicator())
              : Column(
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
                        child: Image.network(
                          locate<WorkoutsService>().getWorkoutImageUrl(
                            _workout.id,
                          ),
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
                              padding: const EdgeInsets.only(
                                left: 18.0,
                                top: 18.0,
                              ),
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
                  FutureBuilder<List<Exercise>>(
                    future: locate<WorkoutsService>().retrieveExercises(
                      _workout.exerciseIds,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text(snapshot.error.toString()));
                      }
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      List<Exercise> exercises = snapshot.data!;
                      return Expanded(
                        flex: 15,
                        child: Stepper(
                          type: StepperType.vertical,
                          currentStep: _currentStep,
                          onStepTapped: (step) {
                            _currentStep = step;
                            context.pushNamed(
                              'exercise-screen',
                              pathParameters: {
                                'exerciseId': exercises[step].id,
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
                            for (int i = 0; i < exercises.length; i++)
                              Step(
                                title: Text(exercises[i].title),
                                subtitle: Text(exercises[i].subtitle),
                                content: SizedBox.shrink(),
                                state:
                                    _currentStep > i
                                        ? StepState.complete
                                        : StepState.indexed,
                                isActive: _currentStep > i,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
    );
  }
}
