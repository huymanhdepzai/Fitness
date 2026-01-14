import 'dart:async';
import '../models/exercise_model.dart';
import 'exercise_goal_filter.dart';
import 'exercise_repository.dart';

class ExerciseService {
  final ExerciseRepository _repo;
  ExerciseService(this._repo);

  Stream<List<ExerciseModel>> watchExercisesForGoal({String? goal}) async* {
    final all = await _repo.loadAllOnce();

    final allowedMuscles = ExerciseGoalFilter.musclesForGoal(goal)
        .map((e) => e.toLowerCase())
        .toSet();

    final allowedBodyParts = ExerciseGoalFilter.bodyPartsForGoal(goal)
        .map((e) => e.toLowerCase())
        .toSet();

    bool match(ExerciseModel x) {
      final muscles = <String>{...x.targetMuscles, ...x.secondaryMuscles}
          .map((e) => e.toLowerCase());

      final parts = x.bodyParts.map((e) => e.toLowerCase());

      return muscles.any(allowedMuscles.contains) ||
          parts.any(allowedBodyParts.contains);
    }

    // ✅ trả về ExerciseModel, bỏ toMapForUI()
    yield all.where(match).toList();
  }
}
