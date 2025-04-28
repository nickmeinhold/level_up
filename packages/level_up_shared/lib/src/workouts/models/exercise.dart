sealed class Exercise {
  const Exercise({
    required this.id,
    this.videoUrl,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String? videoUrl;

  Map<String, Object?> toJson();

  factory Exercise.fromJsonWithId(String id, Map<String, Object?> json) {
    return switch (json['type'] as String) {
      'timed' => TimedExercise.fromJsonWithId(id, json),
      'reps' => RepsExercise.fromJsonWithId(id, json),
      'repsWithWeight' => RepsExerciseWithWeight.fromJsonWithId(id, json),
      _ => throw 'No type was present in the Exercise json from firestore',
    };
  }
}

class TimedExercise extends Exercise {
  const TimedExercise({
    required super.id,
    super.videoUrl,
    required super.title,
    required super.subtitle,
    required super.description,
    required this.time,
    required this.sets,
  });

  final int time;
  final int sets;

  @override
  Map<String, Object?> toJson() {
    return {
      'type': 'timed',
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'videoUrl': videoUrl,
      'time': time,
      'sets': sets,
    };
  }

  factory TimedExercise.fromJsonWithId(String id, Map<String, Object?> json) {
    return TimedExercise(
      id: id,
      videoUrl: json['videoUrl'] as String?,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      description: json['description'] as String,
      time: json['time'] as int,
      sets: json['sets'] as int,
    );
  }
}

class RepsExercise extends Exercise {
  const RepsExercise({
    required super.id,
    super.videoUrl,
    required super.title,
    required super.subtitle,
    required super.description,
    required this.reps,
    required this.sets,
  });

  final int reps;
  final int sets;

  @override
  Map<String, Object?> toJson() {
    return {
      'type': 'reps',
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'videoUrl': videoUrl,
      'reps': reps,
      'sets': sets,
    };
  }

  factory RepsExercise.fromJsonWithId(String id, Map<String, Object?> json) {
    return RepsExercise(
      id: id,
      videoUrl: json['videoUrl'] as String?,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      description: json['description'] as String,
      reps: json['reps'] as int,
      sets: json['sets'] as int,
    );
  }
}

class RepsExerciseWithWeight extends RepsExercise {
  const RepsExerciseWithWeight({
    required super.id,
    super.videoUrl,
    required super.title,
    required super.subtitle,
    required super.description,
    required super.reps,
    required super.sets,
    required this.weight,
  });

  final double weight;

  @override
  Map<String, Object?> toJson() {
    return {
      'type': 'repsWithWeight',
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'videoUrl': videoUrl,
      'weight': weight,
      'reps': reps,
      'sets': sets,
    };
  }

  factory RepsExerciseWithWeight.fromJsonWithId(
    String id,
    Map<String, Object?> json,
  ) {
    return RepsExerciseWithWeight(
      id: id,
      videoUrl: json['videoUrl'] as String?,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      description: json['description'] as String,
      reps: json['reps'] as int,
      sets: json['sets'] as int,
      weight: json['weight'] as double,
    );
  }
}

enum ExerciseType { timed, reps, repsWithWeight }

extension ExerciseTypeExtension on ExerciseType {
  String get displayName {
    switch (this) {
      case ExerciseType.timed:
        return 'Timed';
      case ExerciseType.reps:
        return 'Reps';
      case ExerciseType.repsWithWeight:
        return 'Reps With Weight';
    }
  }
}
