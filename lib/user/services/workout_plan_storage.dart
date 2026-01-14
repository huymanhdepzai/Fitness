import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'saved_workout_plan.dart';

class WorkoutPlanStorage {
  static const _key = 'saved_workout_plan_v1';

  static Future<void> savePlan(SavedWorkoutPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(plan.toJson()));
  }

  static Future<SavedWorkoutPlan?> loadPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_key);
    if (s == null || s.isEmpty) return null;

    try {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return SavedWorkoutPlan.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearPlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
