import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:level_up_shared/level_up_shared.dart';

class WorkoutsService {
  WorkoutsService({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  // We retrieve the exercises of a given workout and add them to a stream
  // that updates the UI
  final _exercisesStreamController =
      StreamController<List<Exercise>>.broadcast();
  Stream<List<Exercise>> get exercisesStream =>
      _exercisesStreamController.stream;

  // Retrieve the exercises and add them to the exercises stream
  Future<void> retrieveAndStreamExercises(List<String> exerciseIds) async {
    if (exerciseIds.length > 30) throw 'Exceeded valid size for whereIn query';
    if (exerciseIds.isEmpty) return;

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await _firestore
            .collection('exercises')
            .where(FieldPath.documentId, whereIn: exerciseIds)
            .get();

    final List<Exercise> exercises = [];
    for (final docSnapshot in querySnapshot.docs) {
      exercises.add(
        Exercise.fromJsonWithId(docSnapshot.id, docSnapshot.data()),
      );
    }

    _exercisesStreamController.add(exercises);
  }

  Stream<Workout> workoutStream(String streamId) {
    Stream<DocumentSnapshot<Map<String, dynamic>>> docSnapshotStream =
        _firestore.collection('workouts').doc(streamId).snapshots();

    return docSnapshotStream.map<Workout>((docSnapshot) {
      return Workout.fromJsonWthId(docSnapshot.id, docSnapshot.data() ?? {});
    });
  }

  Stream<List<Workout>> streamOfWorkouts() {
    Stream<QuerySnapshot<Map<String, dynamic>>> querySnapshotStream =
        _firestore
            .collection('workouts')
            .orderBy('createdAt', descending: true)
            .snapshots();

    return querySnapshotStream.map<List<Workout>>((querySnapshot) {
      return querySnapshot.docs.map((docSnapshot) {
        return Workout.fromJsonWthId(docSnapshot.id, docSnapshot.data());
      }).toList();
    });
  }

  Future<void> createWorkout(Workout workout) {
    final Map<String, Object?> json = workout.toJson();
    json['createdAt'] = FieldValue.serverTimestamp();
    return _firestore.collection('workouts').add(json);
  }

  Future<String> createExercise(Exercise exercise, String workoutId) async {
    final docRef = await _firestore
        .collection('exercises')
        .add(exercise.toJson());

    await _firestore.collection('workouts').doc(workoutId).set({
      'exerciseIds': FieldValue.arrayUnion([docRef.id]),
    }, SetOptions(merge: true));

    return docRef.id;
  }

  void dispose() {
    _exercisesStreamController.close();
  }
}
