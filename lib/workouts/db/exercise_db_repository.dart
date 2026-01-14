import 'package:isar/isar.dart';
import 'exercise_entity.dart';
import 'isar_db.dart';

class TargetGroup {
  final String target; // lowercase
  final int count;
  final String? previewGifUrl;

  const TargetGroup({
    required this.target,
    required this.count,
    required this.previewGifUrl,
  });
}

class ExerciseDbRepository {
  final IsarDb _db;
  ExerciseDbRepository(this._db);

  Future<void> init() => _db.ensureSeeded();

  Future<List<String>> getExerciseNamesForGoalAndTarget({
    required String goal,
    required String target,
    int limit = 200, // tránh load quá nhiều, tuỳ bạn
  }) async {
    final g = goal.toLowerCase();
    final t = target.toLowerCase();

    final items = await _db.isar.exerciseEntitys
        .filter()
        .goalsElementEqualTo(g)
        .primaryTargetEqualTo(t)
        .sortByName()
        .limit(limit)
        .findAll();

    final names = items
        .map((e) => e.name.trim())
        .where((n) => n.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return names;
  }

  Future<List<TargetGroup>> getTargetGroupsForGoal(String goal) async {
    final g = goal.toLowerCase();

    // lấy danh sách target unique (không cần sortByPrimaryTarget)
    final distinct = await _db.isar.exerciseEntitys
        .filter()
        .goalsElementEqualTo(g)
        .distinctByPrimaryTarget()
        .findAll();

    final targets = distinct
        .map((e) => e.primaryTarget)
        .where((t) => t.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort(); // sort ở Dart

    final groups = <TargetGroup>[];

    for (final t in targets) {
      final c = await _db.isar.exerciseEntitys
          .filter()
          .goalsElementEqualTo(g)
          .primaryTargetEqualTo(t)
          .count();

      final preview = await _db.isar.exerciseEntitys
          .filter()
          .goalsElementEqualTo(g)
          .primaryTargetEqualTo(t)
          .findFirst();

      groups.add(TargetGroup(
        target: t,
        count: c,
        previewGifUrl: preview?.gifUrl,
      ));
    }

    groups.sort((a, b) => b.count.compareTo(a.count));
    return groups;
  }


  Future<List<ExerciseEntity>> getByGoalAndTargetPaged({
    required String goal,
    required String target,
    required int page,
    int pageSize = 20,
  }) async {
    final g = goal.toLowerCase();
    final t = target.toLowerCase();
    final offset = page * pageSize;

    return _db.isar.exerciseEntitys
        .filter()
        .goalsElementEqualTo(g)
        .primaryTargetEqualTo(t)
        .sortByName()
        .offset(offset)
        .limit(pageSize)
        .findAll();
  }

  Future<ExerciseEntity?> getByExerciseId(String exerciseId) {
    return _db.isar.exerciseEntitys
        .filter()
        .exerciseIdEqualTo(exerciseId)
        .findFirst();
  }
}
