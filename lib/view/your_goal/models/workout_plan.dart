// lib/view/your_goal/models/workout_plan.dart

enum PlanDayType { workout, rest }

/// ✅ Mỗi bài trong plan cần có id + name để:
/// - hiển thị danh sách bài
/// - click mở ExerciseInstructionsView(exerciseId)
class PlanExercise {
  final String exerciseId;
  final String name;

  const PlanExercise({
    required this.exerciseId,
    required this.name,
  });
}

/// 1 ngày của kế hoạch
class PlanDay {
  final DateTime date; // normalized (yyyy-mm-dd 00:00)
  final PlanDayType type;
  final String? target;

  /// ✅ Mỗi ngày có thể có nhiều bài (không nhất thiết 1 bài)
  List<PlanExercise> exercises;

  PlanDay({
    required this.date,
    required this.type,
    this.target,
    List<PlanExercise>? exercises,
  }) : exercises = exercises ?? [];
}

class WorkoutPlanGenerator {
  static DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Generator đơn giản:
  /// - durationDays: tổng số ngày
  /// - có ngày nghỉ
  /// - số buổi/tuần: 30 ngày -> 4 buổi/tuần, >30 -> 5 buổi/tuần
  ///
  /// NOTE: hàm này chỉ tạo "khung plan" gồm workout/rest + target.
  /// Danh sách exercises sẽ được PlanPreviewScreen gán sau.
  static List<PlanDay> generate({
    required String goal,
    required int durationDays,
    required DateTime startDate,
    required List<String> availableTargetsSorted,
  }) {
    final start = normalize(startDate);

    // Nếu không có target thì vẫn tạo plan nhưng workout không có target
    final targets = availableTargetsSorted.isEmpty
        ? <String>['full body']
        : availableTargetsSorted;

    final sessionsPerWeek = durationDays <= 30 ? 4 : 5;

    // pattern theo tuần (7 ngày)
    // 4 buổi: Mon Wed Fri Sun
    // 5 buổi: Mon Tue Thu Fri Sun
    final Set<int> workoutWeekdays = sessionsPerWeek == 4
        ? {DateTime.monday, DateTime.wednesday, DateTime.friday, DateTime.sunday}
        : {DateTime.monday, DateTime.tuesday, DateTime.thursday, DateTime.friday, DateTime.sunday};

    final plan = <PlanDay>[];
    int targetIndex = 0;

    for (int i = 0; i < durationDays; i++) {
      final day = normalize(start.add(Duration(days: i)));
      final isWorkout = workoutWeekdays.contains(day.weekday);

      if (!isWorkout) {
        plan.add(PlanDay(date: day, type: PlanDayType.rest));
        continue;
      }

      final target = targets[targetIndex % targets.length].toLowerCase();
      targetIndex++;

      plan.add(
        PlanDay(
          date: day,
          type: PlanDayType.workout,
          target: target,
          exercises: const [],
        ),
      );
    }

    return plan;
  }
}
