import 'package:level_up_client/workout/models/exercise.dart';

class Workout {
  const Workout({
    required this.id,
    required this.description,
    required this.image,
    required this.exercises,
  });

  final String id;
  final String description;
  final String image;
  final List<Exercise> exercises;
}
