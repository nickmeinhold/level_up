class Workout {
  const Workout({
    required this.id,
    required this.description,
    required this.imageUrl,
    required this.exerciseIds,
  });

  final String id;
  final String description;
  final String imageUrl;
  final List<String> exerciseIds;

  Map<String, Object?> toJson() {
    return {
      'description': description,
      'imageUrl': imageUrl,
      'exerciseIds': exerciseIds,
    };
  }

  factory Workout.fromJsonWthId(String id, Map<String, Object?> json) {
    return Workout(
      id: id,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      exerciseIds: List<String>.from(json['exerciseIds'] as List),
    );
  }
}
