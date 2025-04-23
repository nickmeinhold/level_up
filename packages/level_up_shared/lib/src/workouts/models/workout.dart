class Workout {
  const Workout({
    required this.id,
    required this.description,
    required this.exerciseIds,
  });

  final String id;
  final String description;
  final List<String> exerciseIds;

  Map<String, Object?> toJson() {
    return {'description': description, 'exerciseIds': exerciseIds};
  }

  factory Workout.fromJsonWithId(String id, Map<String, Object?> json) {
    return Workout(
      id: id,
      description: json['description'] as String,
      exerciseIds: List<String>.from(json['exerciseIds'] as List),
    );
  }
}
