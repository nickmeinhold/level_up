import 'package:flutter_test/flutter_test.dart';
import 'package:level_up_shared/level_up_shared.dart';

void main() {
  group('Exercise.fromJsonWithId', () {
    test('creates TimedExercise from valid JSON', () {
      final exercise = Exercise.fromJsonWithId('e-1', {
        'type': 'timed',
        'title': 'Planks',
        'subtitle': 'Core',
        'description': 'Hold the plank position',
        'time': 60,
        'sets': 3,
      });

      expect(exercise, isA<TimedExercise>());
      final timed = exercise as TimedExercise;
      expect(timed.id, 'e-1');
      expect(timed.title, 'Planks');
      expect(timed.time, 60);
      expect(timed.sets, 3);
      expect(timed.videoUrl, isNull);
      expect(timed.youtubeId, isNull);
    });

    test('creates RepsExercise from valid JSON', () {
      final exercise = Exercise.fromJsonWithId('e-2', {
        'type': 'reps',
        'title': 'Push-ups',
        'subtitle': 'Upper body',
        'description': 'Standard push-ups',
        'reps': 15,
        'sets': 4,
      });

      expect(exercise, isA<RepsExercise>());
      final reps = exercise as RepsExercise;
      expect(reps.reps, 15);
      expect(reps.sets, 4);
    });

    test('creates RepsExerciseWithWeight from valid JSON', () {
      final exercise = Exercise.fromJsonWithId('e-3', {
        'type': 'repsWithWeight',
        'title': 'Bench Press',
        'subtitle': 'Chest',
        'description': 'Flat bench press',
        'reps': 10,
        'sets': 3,
        'weight': 135.5,
      });

      expect(exercise, isA<RepsExerciseWithWeight>());
      final weighted = exercise as RepsExerciseWithWeight;
      expect(weighted.weight, 135.5);
      expect(weighted.reps, 10);
      expect(weighted.sets, 3);
    });

    test('RepsExerciseWithWeight handles integer weight', () {
      final exercise = Exercise.fromJsonWithId('e-4', {
        'type': 'repsWithWeight',
        'title': 'Squat',
        'subtitle': 'Legs',
        'description': 'Barbell squat',
        'reps': 8,
        'sets': 5,
        'weight': 225,
      });

      final weighted = exercise as RepsExerciseWithWeight;
      expect(weighted.weight, 225.0);
    });

    test('preserves optional videoUrl and youtubeId', () {
      final exercise = Exercise.fromJsonWithId('e-5', {
        'type': 'timed',
        'title': 'Stretch',
        'subtitle': 'Flexibility',
        'description': 'Full body stretch',
        'time': 30,
        'sets': 1,
        'videoUrl': 'https://example.com/video.mp4',
        'youtubeId': 'abc123',
      });

      expect(exercise.videoUrl, 'https://example.com/video.mp4');
      expect(exercise.youtubeId, 'abc123');
    });

    test('throws on unknown exercise type', () {
      expect(
        () => Exercise.fromJsonWithId('x', {
          'type': 'unknown',
          'title': 'T',
          'subtitle': 'S',
          'description': 'D',
        }),
        throwsA(isA<String>()),
      );
    });

    test('throws when type is missing', () {
      expect(
        () => Exercise.fromJsonWithId('x', {
          'title': 'T',
          'subtitle': 'S',
          'description': 'D',
        }),
        throwsA(anything),
      );
    });
  });

  group('Exercise.toJson round-trip', () {
    test('TimedExercise serializes and deserializes', () {
      final original = TimedExercise(
        id: 'e-1',
        title: 'Planks',
        subtitle: 'Core',
        description: 'Hold it',
        time: 60,
        sets: 3,
        youtubeId: 'yt123',
      );

      final json = original.toJson();
      final restored = Exercise.fromJsonWithId('e-1', json) as TimedExercise;

      expect(restored.title, original.title);
      expect(restored.time, original.time);
      expect(restored.sets, original.sets);
      expect(restored.youtubeId, original.youtubeId);
    });

    test('RepsExercise serializes and deserializes', () {
      final original = RepsExercise(
        id: 'e-2',
        title: 'Push-ups',
        subtitle: 'Upper',
        description: 'Standard',
        reps: 15,
        sets: 4,
      );

      final json = original.toJson();
      final restored = Exercise.fromJsonWithId('e-2', json) as RepsExercise;

      expect(restored.reps, original.reps);
      expect(restored.sets, original.sets);
    });

    test('RepsExerciseWithWeight serializes and deserializes', () {
      final original = RepsExerciseWithWeight(
        id: 'e-3',
        title: 'Bench',
        subtitle: 'Chest',
        description: 'Flat',
        reps: 10,
        sets: 3,
        weight: 135.5,
      );

      final json = original.toJson();
      final restored =
          Exercise.fromJsonWithId('e-3', json) as RepsExerciseWithWeight;

      expect(restored.weight, original.weight);
      expect(restored.reps, original.reps);
    });
  });

  group('Exercise sealed class exhaustiveness', () {
    test('all subtypes are pattern-matchable', () {
      final exercises = <Exercise>[
        TimedExercise(
          id: '1',
          title: 'T',
          subtitle: 'S',
          description: 'D',
          time: 30,
          sets: 1,
        ),
        RepsExercise(
          id: '2',
          title: 'T',
          subtitle: 'S',
          description: 'D',
          reps: 10,
          sets: 3,
        ),
        RepsExerciseWithWeight(
          id: '3',
          title: 'T',
          subtitle: 'S',
          description: 'D',
          reps: 8,
          sets: 4,
          weight: 100,
        ),
      ];

      for (final exercise in exercises) {
        // This verifies the switch is exhaustive at compile time.
        // If a new subtype is added without updating this switch, it
        // will fail to compile — catching the exact class of bug we
        // found in exercise_details_screen.dart.
        final label = switch (exercise) {
          TimedExercise() => 'timed',
          RepsExerciseWithWeight() => 'weighted',
          RepsExercise() => 'reps',
        };
        expect(label, isNotEmpty);
      }
    });
  });
}
