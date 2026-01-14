class ExerciseModel {
  final String exerciseId;
  final String name;
  final String gifUrl;
  final List<String> targetMuscles;
  final List<String> secondaryMuscles;
  final List<String> bodyParts;
  final List<String> equipments;
  final List<String> instructions;

  const ExerciseModel({
    required this.exerciseId,
    required this.name,
    required this.gifUrl,
    required this.targetMuscles,
    required this.secondaryMuscles,
    required this.bodyParts,
    required this.equipments,
    required this.instructions,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    List<String> _list(dynamic v) =>
        (v is List) ? v.map((e) => e.toString()).toList() : <String>[];

    return ExerciseModel(
      exerciseId: (json['exerciseId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      gifUrl: (json['gifUrl'] ?? '').toString(),
      targetMuscles: _list(json['targetMuscles']),
      secondaryMuscles: _list(json['secondaryMuscles']),
      bodyParts: _list(json['bodyParts']),
      equipments: _list(json['equipments']),
      instructions: _list(json['instructions']),
    );
  }

  // nếu UI của bạn đang dùng Map (WhatTrainRow/WorkoutDetailView)
  Map<String, dynamic> toMapForUI() => {
    'exerciseId': exerciseId,
    'name': name,
    'gifUrl': gifUrl,
    'targetMuscles': targetMuscles,
    'secondaryMuscles': secondaryMuscles,
    'bodyParts': bodyParts,
    'equipments': equipments,
    'instructions': instructions,
  };
}
