import 'package:flutter_test/flutter_test.dart';
import 'package:level_up_shared/level_up_shared.dart';

void main() {
  group('Workout.fromJsonWithId', () {
    test('creates Workout from valid JSON', () {
      final workout = Workout.fromJsonWithId('w-1', {
        'category': 0,
        'description': 'Full court basketball drills',
        'exerciseIds': ['e-1', 'e-2', 'e-3'],
      });

      expect(workout.id, 'w-1');
      expect(workout.category, 0);
      expect(workout.description, 'Full court basketball drills');
      expect(workout.exerciseIds, ['e-1', 'e-2', 'e-3']);
    });

    test('handles empty exerciseIds list', () {
      final workout = Workout.fromJsonWithId('w-2', {
        'category': 1,
        'description': 'Empty workout',
        'exerciseIds': <String>[],
      });

      expect(workout.exerciseIds, isEmpty);
    });

    test('throws when category is missing', () {
      expect(
        () => Workout.fromJsonWithId('x', {
          'description': 'D',
          'exerciseIds': [],
        }),
        throwsA(anything),
      );
    });

    test('throws when description is missing', () {
      expect(
        () => Workout.fromJsonWithId('x', {
          'category': 0,
          'exerciseIds': [],
        }),
        throwsA(anything),
      );
    });

    test('throws when exerciseIds is missing', () {
      expect(
        () => Workout.fromJsonWithId('x', {
          'category': 0,
          'description': 'D',
        }),
        throwsA(anything),
      );
    });
  });

  group('Workout.toJson', () {
    test('serializes description and exerciseIds', () {
      final workout = Workout(
        id: 'w-1',
        category: 0,
        description: 'Drills',
        exerciseIds: ['e-1', 'e-2'],
      );

      final json = workout.toJson();

      expect(json['description'], 'Drills');
      expect(json['exerciseIds'], ['e-1', 'e-2']);
    });

    test('toJson includes category', () {
      final workout = Workout(
        id: 'w-1',
        category: 2,
        description: 'Fitness',
        exerciseIds: [],
      );

      final json = workout.toJson();
      expect(json['category'], 2);
    });

    test('toJson round-trips through fromJsonWithId', () {
      final original = Workout(
        id: 'w-1',
        category: 1,
        description: 'Strength',
        exerciseIds: ['e-1', 'e-2'],
      );

      final json = original.toJson();
      final restored = Workout.fromJsonWithId('w-1', json);

      expect(restored.category, original.category);
      expect(restored.description, original.description);
      expect(restored.exerciseIds, original.exerciseIds);
    });
  });

  group('WorkoutCategory', () {
    test('all categories have display names', () {
      for (final category in WorkoutCategory.values) {
        expect(category.displayName, isNotEmpty);
      }
    });

    test('category indices are stable', () {
      expect(WorkoutCategory.basketball.index, 0);
      expect(WorkoutCategory.strength.index, 1);
      expect(WorkoutCategory.fitness.index, 2);
    });
  });
}
