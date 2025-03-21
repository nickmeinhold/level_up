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
          time: 300,
          rounds: 1,
        ),
        RepsExercise(
          id: '2',
          videoUrl: 'dQw4w9WgXcQ',
          title: 'Split squat',
          subtitle: '8 Reps per side',
          description: 'Split squat - 4 Sets, 8 Reps Per Side',
          reps: 8,
          rounds: 4,
        ),
        TimedExercise(
          id: '3',
          videoUrl: 'dQw4w9WgXcQ',
          title: 'Couch Stretch',
          subtitle: '1 Min Per Side',
          description: 'Couch Stretch - 2 sets, 1 Min Per Side',
          time: 60,
          rounds: 2,
        ),
      ],
    ),
    '1': Workout(
      id: '1',
      description: 'Workout 2',
      image: 'assets/images/workout1.jpg',
      exercises: [],
    ),
    '2': Workout(
      id: '2',
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
}
