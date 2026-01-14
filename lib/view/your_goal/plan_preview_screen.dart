import 'dart:ui';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../workouts/db/exercise_db_repository.dart';
import '../../workouts/db/exercise_entity.dart';
import '../../workouts/db/isar_db.dart';
import '../../services/notification_service.dart';
import '../daily_schedule_view/workout_note_storage.dart';
import 'models/workout_plan.dart';
import '../welcome/welcome_screen.dart';

// ✅ lưu plan
import '../../user/services/saved_workout_plan.dart';
import '../../user/services/workout_plan_storage.dart';

class PlanPreviewScreen extends StatefulWidget {
  final String goal;
  final int durationDays;
  const PlanPreviewScreen({
    super.key,
    required this.goal,
    required this.durationDays,
  });

  @override
  State<PlanPreviewScreen> createState() => _PlanPreviewScreenState();
}

class _PlanPreviewScreenState extends State<PlanPreviewScreen> {
  final _repo = ExerciseDbRepository(IsarDb());

  bool _loading = true;
  List<PlanDay> _plan = [];
  List<TargetGroup> _groups = [];

  DateTime get _startDate =>
      WorkoutPlanGenerator.normalize(DateTime.now().add(const Duration(days: 0)));

  @override
  void initState() {
    super.initState();
    _loadAndBuildPlan();
  }

  // ====== giữ nguyên toàn bộ logic của bạn (range, load, build plan, confirm...) ======
  (int min, int max) _rangeForGoal(String goal) {
    switch (goal.toLowerCase()) {
      case 'lose_fat':
        return (10, 14);
      case 'lean_tone':
        return (8, 13);
      case 'improve_shape':
        return (6, 10);
      default:
        return (6, 10);
    }
  }

  int _sessionSizeForWorkoutIndex(String goal, int workoutIndex) {
    final (min, max) = _rangeForGoal(goal);
    final span = (max - min) + 1;
    return min + (workoutIndex % span);
  }

  Future<List<ExerciseEntity>> _loadExercisePoolForTarget({
    required String goal,
    required String target,
    int maxPages = 6,
    int pageSize = 20,
  }) async {
    final raw = <ExerciseEntity>[];

    for (int page = 0; page < maxPages; page++) {
      final items = await _repo.getByGoalAndTargetPaged(
        goal: goal,
        target: target,
        page: page,
        pageSize: pageSize,
      );
      if (items.isEmpty) break;
      raw.addAll(items);
    }

    final seen = <String>{};
    final pool = <ExerciseEntity>[];
    for (final e in raw) {
      if (seen.add(e.exerciseId)) pool.add(e);
    }
    return pool;
  }

  Future<void> _loadAndBuildPlan() async {
    await _repo.init();

    final groups = await _repo.getTargetGroupsForGoal(widget.goal);
    final targetsSorted = groups.map((g) => g.target).toList();

    final basePlan = WorkoutPlanGenerator.generate(
      goal: widget.goal,
      durationDays: widget.durationDays,
      startDate: _startDate,
      availableTargetsSorted: targetsSorted,
    );

    final uniqueTargets = basePlan
        .where((p) => p.type == PlanDayType.workout && (p.target ?? '').isNotEmpty)
        .map((p) => p.target!)
        .toSet()
        .toList();

    final Map<String, List<ExerciseEntity>> pools = {};
    for (final t in uniqueTargets) {
      pools[t] = await _loadExercisePoolForTarget(goal: widget.goal, target: t);
    }

    final Map<String, int> cursor = {for (final t in uniqueTargets) t: 0};

    int workoutIndex = 0;
    for (final p in basePlan) {
      if (p.type != PlanDayType.workout || p.target == null) {
        p.exercises = const [];
        continue;
      }

      final t = p.target!;
      final pool = pools[t] ?? const [];
      final sessionSize = _sessionSizeForWorkoutIndex(widget.goal, workoutIndex);
      workoutIndex++;

      if (pool.isEmpty) {
        p.exercises = const [];
        continue;
      }

      final start = cursor[t] ?? 0;
      final picked = <PlanExercise>[];

      for (int i = 0; i < sessionSize; i++) {
        final e = pool[(start + i) % pool.length];
        picked.add(PlanExercise(exerciseId: e.exerciseId, name: e.name));
      }

      cursor[t] = (start + sessionSize) % pool.length;
      p.exercises = picked;
    }

    if (!mounted) return;
    setState(() {
      _groups = groups;
      _plan = basePlan;
      _loading = false;
    });
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _goalLabel(String goal) {
    switch (goal.toLowerCase()) {
      case 'lose_fat':
        return 'Giảm mỡ';
      case 'lean_tone':
        return 'Săn chắc';
      case 'improve_shape':
        return 'Cải thiện hình dáng';
      default:
        return goal;
    }
  }

  Future<void> _confirmPlanAndAddNotes() async {
    await WorkoutNoteStorage.clearAllNotesAndCancelNotifications(
      cancelNotification: NotificationService.cancelNotification,
    );

    final savedDays = _plan.map((p) {
      return SavedPlanDay(
        date: p.date,
        type: p.type == PlanDayType.rest ? SavedPlanDayType.rest : SavedPlanDayType.workout,
        target: p.target,
        exercises: p.exercises
            .map((ex) => SavedPlanExercise(exerciseId: ex.exerciseId, name: ex.name))
            .toList(),
      );
    }).toList();

    await WorkoutPlanStorage.clearPlan();
    await WorkoutPlanStorage.savePlan(
      SavedWorkoutPlan(
        goal: widget.goal,
        durationDays: widget.durationDays,
        startDate: _startDate,
        createdAt: DateTime.now(),
        days: savedDays,
      ),
    );

    const hour = 18;
    const minute = 0;

    for (final p in _plan) {
      if (p.type != PlanDayType.workout) continue;

      final idStr = '${p.date.millisecondsSinceEpoch}_${(p.target ?? 't')}';
      final notificationId = idStr.hashCode;

      final dateTime = DateTime(p.date.year, p.date.month, p.date.day, hour, minute);

      final count = p.exercises.length;
      final title = 'Workout: ${p.target ?? 'Training'} ($count bài)';

      final descLines = <String>[
        if (p.target != null) 'Nhóm: ${p.target}',
        'Mục tiêu: ${widget.goal}',
        'Plan: ${widget.durationDays} ngày',
        '',
        'Danh sách bài:',
        if (p.exercises.isEmpty) '- (chưa có bài phù hợp)',
        ...p.exercises.map((e) => '- ${e.name}'),
      ];

      final note = WorkoutNote(
        id: idStr,
        notificationId: notificationId,
        dateTime: dateTime,
        title: title,
        description: descLines.join('\n'),
      );

      await WorkoutNoteStorage.addNote(note);

      await NotificationService.scheduleWorkoutNotification(
        id: notificationId,
        dateTime: dateTime,
        title: note.title,
        body: count > 0 ? 'Bài đầu: ${p.exercises.first.name}' : 'Đến giờ tập rồi! 💪',
      );
    }

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      WelcomeScreen.routeName,
          (route) => false,
    );
  }

  // =========================
  // UI HELPERS (MỚI)
  // =========================

  Widget _glass({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(14),
    double radius = 18,
    double opacity = 0.14,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _pill({
    required String text,
    Color? bg,
    Color? fg,
    IconData? icon,
  }) {
    final tColor = fg ?? Colors.white.withOpacity(0.96);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: (bg ?? Colors.white.withOpacity(0.16)),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: tColor),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: tColor),
          ),
        ],
      ),
    );
  }

  Widget _chipLight(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.lightGrayColor.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.blackColor,
        ),
      ),
    );
  }

  Widget _dayIcon(bool isRest) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: isRest ? null : LinearGradient(colors: AppColors.primaryG),
        color: isRest ? Colors.grey.shade200 : null,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Icon(
        isRest ? Icons.bedtime_rounded : Icons.fitness_center_rounded,
        color: isRest ? Colors.grey.shade700 : Colors.white,
        size: 22,
      ),
    );
  }

  Widget _gradientButton({
    required String text,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onTap : null,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: AppColors.primaryG),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 8)),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              shadows: [
                Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // CARD (ĐẸP HƠN) + EXPAND
  // =========================
  Widget _planDayCard(PlanDay p) {
    final isRest = p.type == PlanDayType.rest;
    final count = p.exercises.length;

    final preview = p.exercises.take(3).map((e) => e.name).toList();
    final remaining = (count - preview.length).clamp(0, 999);

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dayIcon(isRest),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _fmtDate(p.date),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ),
                  if (isRest)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'REST',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'WORKOUT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                isRest ? 'Nghỉ / phục hồi' : 'Nhóm: ${p.target ?? ''} • $count bài',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              if (!isRest) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final name in preview) _chipLight(name),
                    if (remaining > 0) _chipLight('+$remaining bài'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );

    final cardDecor = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.black.withOpacity(0.05)),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3)),
      ],
    );

    if (isRest) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: cardDecor,
        child: header,
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: cardDecor,
          child: ExpansionTile(
            tilePadding: const EdgeInsets.all(14),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            collapsedIconColor: Colors.grey.shade700,
            iconColor: Colors.grey.shade700,
            title: header,
            children: [
              if (p.exercises.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '(Chưa có bài phù hợp)',
                    style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700),
                  ),
                )
              else
                Column(
                  children: List.generate(p.exercises.length, (i) {
                    final ex = p.exercises[i];
                    return Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrayColor.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black.withOpacity(0.04)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: AppColors.primaryG),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              ex.name,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (minS, maxS) = _rangeForGoal(widget.goal);
    final goalText = _goalLabel(widget.goal);

    final workoutDays = _plan.where((e) => e.type == PlanDayType.workout).length;
    final restDays = _plan.where((e) => e.type == PlanDayType.rest).length;

    return Stack(
      children: [
        // ===== Gradient background =====
        Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryG)),
        ),

        // ✅ Dark overlay cho dễ đọc
        Container(color: Colors.black.withOpacity(0.18)),

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Kế hoạch ${widget.durationDays} ngày',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2)),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
            children: [
              // ===== Content =====
              Column(
                children: [
                  const SizedBox(height: 6),

                  // ===== Summary glass =====
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _glass(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _pill(text: goalText, icon: Icons.flag_rounded),
                              _pill(text: 'Bắt đầu: ${_fmtDate(_startDate)}', icon: Icons.event_rounded),
                              _pill(text: '$workoutDays workout • $restDays nghỉ', icon: Icons.check_circle_rounded),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Số buổi/tuần: ${widget.durationDays <= 30 ? 4 : 5} (có ngày nghỉ)\n'
                                'Số bài/buổi: $minS–$maxS',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                              shadows: const [
                                Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ===== List =====
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8F8FB),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(26),
                          topRight: Radius.circular(26),
                        ),
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                        itemCount: _plan.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _planDayCard(_plan[i]),
                      ),
                    ),
                  ),
                ],
              ),

              // ===== Sticky bottom button with blur =====
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.65),
                          border: Border(
                            top: BorderSide(color: Colors.black.withOpacity(0.06)),
                          ),
                        ),
                        child: _gradientButton(
                          text: 'Xác nhận kế hoạch & tạo lịch',
                          onTap: _confirmPlanAndAddNotes,
                          enabled: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
