import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:level_up_shared/level_up_shared.dart';

class WorkoutsService {
  WorkoutsService({
    required FirebaseFirestore firestore,
    required FirebaseStorage workoutImagesStorage,
  }) : _firestore = firestore,
       _workoutImagesStorage = workoutImagesStorage;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _workoutImagesStorage;

  // We retrieve the exercises of a given workout and add them to a stream
  // that updates the UI
  final _exercisesStreamController =
      StreamController<List<Exercise>>.broadcast();
  Stream<List<Exercise>> get exercisesStream =>
      _exercisesStreamController.stream;

  Future<Exercise> retrieveExercise(String exerciseId) async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot =
        await _firestore.collection('exercises').doc(exerciseId).get();

    return Exercise.fromJsonWithId(docSnapshot.id, docSnapshot.data() ?? {});
  }

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
      return Workout.fromJsonWithId(docSnapshot.id, docSnapshot.data() ?? {});
    });
  }

  Future<Workout> retrieveWorkout(String streamId) async {
    DocumentSnapshot<Map<String, dynamic>> docSnapshot =
        await _firestore.collection('workouts').doc(streamId).get();

    return Workout.fromJsonWithId(docSnapshot.id, docSnapshot.data() ?? {});
  }

  Stream<List<Workout>> streamOfWorkouts() {
    Stream<QuerySnapshot<Map<String, dynamic>>> querySnapshotStream =
        _firestore
            .collection('workouts')
            .orderBy('createdAt', descending: true)
            .snapshots();

    return querySnapshotStream.map<List<Workout>>((querySnapshot) {
      return querySnapshot.docs.map((docSnapshot) {
        return Workout.fromJsonWithId(docSnapshot.id, docSnapshot.data());
      }).toList();
    });
  }

  Future<void> createWorkout(Workout workout) {
    final Map<String, Object?> json = workout.toJson();
    json['createdAt'] = FieldValue.serverTimestamp();
    return _firestore.collection('workouts').add(json);
  }

  Future<void> updateWorkout({
    required String workoutId,
    required String description,
    required int category,
  }) {
    return _firestore.collection('workouts').doc(workoutId).set({
      'description': description,
      'category': category,
    }, SetOptions(merge: true));
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

  Future<void> updateExercise(Exercise exercise, String workoutId) {
    return _firestore
        .collection('exercises')
        .doc(exercise.id)
        .update(exercise.toJson());
  }

  Future<void> uploadWorkoutImage(String workoutId, Uint8List data) async {
    final task = _workoutImagesStorage
        .ref()
        .child(workoutId)
        .child('main_image.png')
        .putData(data, SettableMetadata(contentType: 'image/png'));

    final _ = await task;
  }

  String getWorkoutImageUrl(String workoutId) {
    return 'https://storage.googleapis.com/workout-images/$workoutId/main_image.png';
  }

  void dispose() {
    _exercisesStreamController.close();
  }
}
