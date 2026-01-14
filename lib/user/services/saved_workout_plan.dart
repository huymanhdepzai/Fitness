enum SavedPlanDayType { workout, rest }

class SavedPlanExercise {
  final String exerciseId;
  final String name;

  const SavedPlanExercise({
    required this.exerciseId,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'name': name,
  };

  factory SavedPlanExercise.fromJson(Map<String, dynamic> json) =>
      SavedPlanExercise(
        exerciseId: json['exerciseId'] as String,
        name: json['name'] as String,
      );
}

class SavedPlanDay {
  final DateTime date; // normalized day
  final SavedPlanDayType type;
  final String? target;
  final List<SavedPlanExercise> exercises;

  const SavedPlanDay({
    required this.date,
    required this.type,
    this.target,
    this.exercises = const [],
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'type': type.name,
    'target': target,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory SavedPlanDay.fromJson(Map<String, dynamic> json) => SavedPlanDay(
    date: DateTime.parse(json['date'] as String),
    type: SavedPlanDayType.values
        .firstWhere((e) => e.name == (json['type'] as String)),
    target: json['target'] as String?,
    exercises: ((json['exercises'] as List?) ?? [])
        .map((e) => SavedPlanExercise.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class SavedWorkoutPlan {
  final String goal;
  final int durationDays;
  final DateTime startDate; // normalized
  final DateTime createdAt;
  final List<SavedPlanDay> days;

  const SavedWorkoutPlan({
    required this.goal,
    required this.durationDays,
    required this.startDate,
    required this.createdAt,
    required this.days,
  });

  Map<String, dynamic> toJson() => {
    'goal': goal,
    'durationDays': durationDays,
    'startDate': startDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'days': days.map((d) => d.toJson()).toList(),
  };

  factory SavedWorkoutPlan.fromJson(Map<String, dynamic> json) =>
      SavedWorkoutPlan(
        goal: json['goal'] as String,
        durationDays: json['durationDays'] as int,
        startDate: DateTime.parse(json['startDate'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        days: (json['days'] as List)
            .map((e) => SavedPlanDay.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
