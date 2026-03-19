class Workout {
  const Workout({
    required this.id,
    required this.category,
    required this.description,
    required this.exerciseIds,
  });

  final String id;
  final int category;
  final String description;
  final List<String> exerciseIds;

  Map<String, Object?> toJson() {
    return {
      'category': category,
      'description': description,
      'exerciseIds': exerciseIds,
    };
  }

  factory Workout.fromJsonWithId(String id, Map<String, Object?> json) {
    return Workout(
      id: id,
      category: json['category'] as int,
      description: json['description'] as String,
      exerciseIds: List<String>.from(json['exerciseIds'] as List),
    );
  }
}

enum WorkoutCategory { basketball, strength, fitness }

extension WorkoutCategoryExtension on WorkoutCategory {
  String get displayName {
    switch (this) {
      case WorkoutCategory.basketball:
        return 'Basketball';
      case WorkoutCategory.strength:
        return 'Strength';
      case WorkoutCategory.fitness:
        return 'Fitness';
    }
  }
}
