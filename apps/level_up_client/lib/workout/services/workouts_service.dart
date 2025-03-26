import 'package:level_up/workout/models/exercise.dart';
import 'package:level_up/workout/models/workout.dart';

class WorkoutsService {
  const WorkoutsService();
  final Map<String, Workout> workouts = const {
    'trial': Workout(
      id: 'trial',
      description: 'Check out how the app works, and feel ',
      image: 'assets/images/trial_workout.jpg',
      exercises: [
        TimedExercise(
          id: '1',
          videoUrl: 'dQw4w9WgXcQ',
          title: 'Backward walking',
          subtitle: 'Walk backwards for 5 Mins',
          description: 'Backward walking - Walk backwards for 5 Mins',
          time: 2, // 300
          sets: 1,
        ),
        RepsExercise(
          id: '2',
          videoUrl: 'dQw4w9WgXcQ',
          title: 'Split squat',
          subtitle: '8 Reps per side',
          description: 'Split squat - 4 Sets, 8 Reps Per Side',
          reps: 8,
          sets: 4,
        ),
        TimedExercise(
          id: '3',
          videoUrl: 'dQw4w9WgXcQ',
          title: 'Couch Stretch',
          subtitle: '1 Min Per Side',
          description: 'Couch Stretch - 2 sets, 1 Min Per Side',
          time: 2, // 60
          sets: 2,
        ),
        RepsExerciseWithWeights(
          id: '4',
          videoUrl: 'dQw4w9WgXcQ',
          title: 'Bicep Curl',
          subtitle: '3 Sets',
          description: 'Bicep Curl - 3 Sets, 4 reps of 20kg each side',
          reps: 4,
          sets: 3,
          weight: 20,
        ),
      ],
    ),
    'w1': Workout(
      id: 'w1',
      description: 'Workout 2',
      image: 'assets/images/workout1.jpg',
      exercises: [],
    ),
    'w2': Workout(
      id: 'w2',
      description: 'Workout 3',
      image: 'assets/images/workout2.jpg',
      exercises: [],
    ),
  };

  List<Workout> retrieveWorkouts() {
    return workouts.values.toList();
  }

  Workout retrieveWorkout(String workoutId) {
    return workouts[workoutId]!;
  }

  Exercise retrieveExercise(String workoutId, int exerciseNum) {
    return workouts[workoutId]!.exercises[exerciseNum];
  }
}
