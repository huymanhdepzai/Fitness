import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/exercise_goal_filter.dart';
import 'exercise_entity.dart';

class IsarDb {
  static const _seedKey = 'exercises_seed_version';
  static const _seedVersion = 3; // tăng số này khi bạn đổi schema/logic seed

  static final IsarDb _instance = IsarDb._();
  IsarDb._();
  factory IsarDb() => _instance;

  Isar? _isar;
  Isar get isar => _isar!;

  Future<void> open() async {
    if (_isar != null) return;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [ExerciseEntitySchema],
      directory: dir.path,
    );
  }

  Future<void> ensureSeeded() async {
    await open();
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_seedKey) ?? 0;

    // đã seed đúng version thì thôi
    if (current == _seedVersion) return;

    // nếu muốn “seed lại” mỗi lần đổi version: clear collection
    await isar.writeTxn(() async {
      await isar.exerciseEntitys.clear();
    });

    const assetPath = 'assets/data/exercises_data.json';
    final jsonStr = await rootBundle.loadString(assetPath);
    final raw = jsonDecode(jsonStr);
    if (raw is! List) {
      await prefs.setInt(_seedKey, _seedVersion);
      return;
    }

    final lose = ExerciseGoalFilter.musclesForGoal('lose_fat').map((e) => e.toLowerCase()).toSet();
    final lean = ExerciseGoalFilter.musclesForGoal('lean_tone').map((e) => e.toLowerCase()).toSet();
    final shape = ExerciseGoalFilter.musclesForGoal('improve_shape').map((e) => e.toLowerCase()).toSet();

    final loseParts = ExerciseGoalFilter.bodyPartsForGoal('lose_fat').map((e) => e.toLowerCase()).toSet();
    final leanParts = ExerciseGoalFilter.bodyPartsForGoal('lean_tone').map((e) => e.toLowerCase()).toSet();
    final shapeParts = ExerciseGoalFilter.bodyPartsForGoal('improve_shape').map((e) => e.toLowerCase()).toSet();

    bool matchGoal(Set<String> allowedMuscles, Set<String> allowedParts, ExerciseEntity x) {
      final muscles = <String>{...x.targetMuscles, ...x.secondaryMuscles};
      final muscleHit = muscles.any(allowedMuscles.contains);
      final bodyHit = x.bodyParts.any(allowedParts.contains);
      return muscleHit || bodyHit;
    }

    final items = <ExerciseEntity>[];

    for (final item in raw) {
      if (item is! Map) continue;
      final m = Map<String, dynamic>.from(item as Map);

      List<String> listStr(String k) {
        final v = m[k];
        if (v is List) {
          return v.whereType<String>().map((e) => e.toLowerCase()).toList();
        }
        return const [];
      }

      final e = ExerciseEntity()
        ..exerciseId = (m['exerciseId'] ?? '').toString()
        ..name = (m['name'] ?? '').toString()
        ..gifUrl = (m['gifUrl'] ?? '').toString()
        ..targetMuscles = listStr('targetMuscles')
        ..secondaryMuscles = listStr('secondaryMuscles')
        ..bodyParts = listStr('bodyParts')
        ..equipments = listStr('equipments')
        ..instructions = (m['instructions'] is List)
            ? (m['instructions'] as List).whereType<String>().toList()
            : const []
        ..primaryTarget = listStr('targetMuscles').isNotEmpty ? listStr('targetMuscles').first : '';



      e.goals = <String>[];
      if (matchGoal(lose, loseParts, e)) e.goals.add('lose_fat');
      if (matchGoal(lean, leanParts, e)) e.goals.add('lean_tone');
      if (matchGoal(shape, shapeParts, e)) e.goals.add('improve_shape');

      e.fixId();
      items.add(e);
    }

    await isar.writeTxn(() async {
      await isar.exerciseEntitys.putAll(items);
    });

    await prefs.setInt(_seedKey, _seedVersion);
  }
}
