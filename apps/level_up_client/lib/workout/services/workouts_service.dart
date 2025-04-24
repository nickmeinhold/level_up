import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:level_up_shared/level_up_shared.dart';

class WorkoutsService {
  WorkoutsService({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  String getWorkoutImageUrl(String workoutId) {
    return 'https://storage.googleapis.com/workout-images/$workoutId/main_image.png';
  }

  Future<List<Workout>> retrieveWorkouts() async {
    QuerySnapshot<Map<String, Object?>> querySnapshot =
        await _firestore.collection('workouts').get();

    return querySnapshot.docs.map<Workout>((doc) {
      return Workout.fromJsonWithId(doc.id, doc.data());
    }).toList();
  }

  Future<Workout> retrieveWorkout(String workoutId) async {
    DocumentSnapshot<Map<String, Object?>> docSnapshot =
        await _firestore.collection('workouts').doc(workoutId).get();
    return Workout.fromJsonWithId(docSnapshot.id, docSnapshot.data() ?? {});
  }

  Future<Exercise> retrieveExercise(String exerciseId) async {
    DocumentSnapshot<Map<String, Object?>> docSnapshot =
        await _firestore.collection('exercises').doc(exerciseId).get();

    return Exercise.fromJsonWithId(docSnapshot.id, docSnapshot.data() ?? {});
  }

  Future<List<Exercise>> retrieveExercises(List<String> exerciseIds) async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('exercises')
            .where(FieldPath.documentId, whereIn: exerciseIds)
            .get();

    List<Exercise> exercises = [];
    for (final docSnapshot in querySnapshot.docs) {
      exercises.add(
        Exercise.fromJsonWithId(docSnapshot.id, docSnapshot.data()),
      );
    }

    return exercises;
  }
}
