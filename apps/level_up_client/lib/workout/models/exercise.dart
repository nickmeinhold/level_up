sealed class Exercise {
  const Exercise({
    required this.id,
    required this.videoUrl,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String videoUrl;
}

class TimedExercise extends Exercise {
  const TimedExercise({
    required super.id,
    required super.videoUrl,
    required super.title,
    required super.subtitle,
    required super.description,
    required this.time,
    required this.rounds,
  });
  final int time;
  final int rounds;
}

class RepsExercise extends Exercise {
  const RepsExercise({
    required super.id,
    required super.videoUrl,
    required super.title,
    required super.subtitle,
    required super.description,
    required this.reps,
    required this.rounds,
  });

  final int reps;
  final int rounds;
}

class RepsExerciseWithWeights extends RepsExercise {
  const RepsExerciseWithWeights({
    required super.id,
    required super.videoUrl,
    required super.title,
    required super.subtitle,
    required super.description,
    required super.reps,
    required super.rounds,
    required this.weight,
  });

  final int weight;
}
