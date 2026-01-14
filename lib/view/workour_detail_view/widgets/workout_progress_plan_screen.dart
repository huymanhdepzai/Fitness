import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../user/services/saved_workout_plan.dart';
import '../../../user/services/workout_plan_storage.dart';
import '../../../utils/app_colors.dart';
import '../../activity/exercise_instructions_view.dart';

class WorkoutProgressPlanScreen extends StatefulWidget {
  const WorkoutProgressPlanScreen({super.key});

  @override
  State<WorkoutProgressPlanScreen> createState() => _WorkoutProgressPlanScreenState();
}

class _WorkoutProgressPlanScreenState extends State<WorkoutProgressPlanScreen> {
  SavedWorkoutPlan? _plan;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await WorkoutPlanStorage.loadPlan();
    if (!mounted) return;
    setState(() {
      _plan = p;
      _loading = false;
    });
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _fmtDDMM(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final fbUser = FirebaseAuth.instance.currentUser;

    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryG)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Kế hoạch tập luyện',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_plan == null)
            ? const Center(
          child: Text(
            'Bạn chưa có kế hoạch tập luyện.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        )
            : (fbUser == null)
            ? const Center(
          child: Text(
            'Chưa đăng nhập',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        )
            : _PlanBody(
          plan: _plan!,
          uid: fbUser.uid,
          fmtDate: _fmtDate,
          fmtDDMM: _fmtDDMM,
          dateOnly: _dateOnly,
        ),
      ),
    );
  }
}

class _PlanBody extends StatelessWidget {
  final SavedWorkoutPlan plan;
  final String uid;
  final String Function(DateTime) fmtDate;
  final String Function(DateTime) fmtDDMM;
  final DateTime Function(DateTime) dateOnly;

  const _PlanBody({
    required this.plan,
    required this.uid,
    required this.fmtDate,
    required this.fmtDDMM,
    required this.dateOnly,
  });

  @override
  Widget build(BuildContext context) {
    // Tính khoảng ngày của plan để query lịch sử 1 lần
    final days = plan.days;
    final minDay = days.map((e) => dateOnly(e.date)).reduce((a, b) => a.isBefore(b) ? a : b);
    final maxDay = days.map((e) => dateOnly(e.date)).reduce((a, b) => a.isAfter(b) ? a : b);

    final start = minDay;
    final end = maxDay.add(const Duration(days: 1)); // end exclusive

    final historyQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('workout_history')
        .where('performedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('performedAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('performedAt', descending: true);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(26), topRight: Radius.circular(26)),
      ),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: historyQuery.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text("Lỗi tải lịch sử: ${snap.error}"));
          }

          final historyDocs = snap.data?.docs ?? [];

          // doneByDay[dateOnly] = set exerciseId đã tập trong ngày đó
          final Map<DateTime, Set<String>> doneByDay = {};
          for (final d in historyDocs) {
            final m = d.data();
            final ts = m['performedAt'];
            if (ts is! Timestamp) continue;
            final day = dateOnly(ts.toDate());

            final exId = (m['exerciseId'] ?? '').toString().trim();
            if (exId.isEmpty) continue;

            doneByDay.putIfAbsent(day, () => <String>{}).add(exId);
          }

          // Tổng tiến độ toàn plan (chỉ tính ngày workout)
          int totalPlanned = 0;
          int totalDone = 0;

          for (final day in plan.days) {
            if (day.type == SavedPlanDayType.rest) continue;
            final plannedIds = day.exercises.map((e) => e.exerciseId.toString().trim()).where((x) => x.isNotEmpty).toSet();
            final doneIds = doneByDay[dateOnly(day.date)] ?? <String>{};
            totalPlanned += plannedIds.length;
            totalDone += plannedIds.intersection(doneIds).length;
          }

          final overall = totalPlanned == 0 ? 0.0 : (totalDone / totalPlanned).clamp(0.0, 1.0);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(colors: [
                        AppColors.primaryColor1.withOpacity(0.12),
                        AppColors.primaryColor2.withOpacity(0.08),
                      ]),
                      border: Border.all(color: Colors.black.withOpacity(0.04)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: AppColors.primaryG),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.calendar_month, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Workout Plan",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.blackColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Tổng: $totalDone/$totalPlanned bài đã hoàn thành",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  minHeight: 7,
                                  value: overall,
                                  backgroundColor: Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList.separated(
                  itemCount: plan.days.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final day = plan.days[i];
                    final isRest = day.type == SavedPlanDayType.rest;

                    final plannedIds = day.exercises
                        .map((e) => e.exerciseId.toString().trim())
                        .where((x) => x.isNotEmpty)
                        .toSet();
                    final doneIds = doneByDay[dateOnly(day.date)] ?? <String>{};

                    final doneCount = plannedIds.intersection(doneIds).length;
                    final plannedCount = plannedIds.length;
                    final percent = plannedCount == 0 ? 0.0 : (doneCount / plannedCount).clamp(0.0, 1.0);

                    return _PlanDayCard(
                      dateText: fmtDate(day.date),
                      dateShort: fmtDDMM(day.date),
                      isRest: isRest,
                      target: (day.target ?? '').toString().trim(),
                      exerciseCount: day.exercises.length,
                      exercises: day.exercises,
                      doneIdsToday: doneIds,
                      doneCount: doneCount,
                      plannedCount: plannedCount,
                      percent: percent,
                      onTapExercise: (exId) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExerciseInstructionsView(exerciseId: exId),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PlanDayCard extends StatelessWidget {
  final String dateText;
  final String dateShort;
  final bool isRest;
  final String target;
  final int exerciseCount;
  final List<SavedPlanExercise> exercises;

  final Set<String> doneIdsToday;
  final int doneCount;
  final int plannedCount;
  final double percent;

  final void Function(String exerciseId) onTapExercise;

  const _PlanDayCard({
    required this.dateText,
    required this.dateShort,
    required this.isRest,
    required this.target,
    required this.exerciseCount,
    required this.exercises,
    required this.onTapExercise,
    required this.doneIdsToday,
    required this.doneCount,
    required this.plannedCount,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final headerBg = isRest ? Colors.grey.shade50 : Colors.green.shade50;
    final badgeBg = isRest ? Colors.grey.shade200 : Colors.green.withOpacity(0.12);
    final badgeTextColor = isRest ? Colors.grey.shade800 : Colors.green.shade700;

    return Container(
      decoration: BoxDecoration(
        color: headerBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            collapsedIconColor: Colors.grey.shade700,
            iconColor: Colors.grey.shade700,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isRest ? Icons.self_improvement : Icons.fitness_center,
                        size: 16,
                        color: isRest ? Colors.grey.shade700 : Colors.green.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateShort,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: AppColors.blackColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: badgeTextColor.withOpacity(0.25)),
                            ),
                            child: Text(
                              isRest ? "REST" : "WORKOUT",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: badgeTextColor,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!isRest && target.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: Colors.black.withOpacity(0.06)),
                              ),
                              child: Text(
                                target,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (!isRest) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  minHeight: 7,
                                  value: plannedCount == 0 ? 0 : percent,
                                  backgroundColor: Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "$doneCount/$plannedCount",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                isRest ? "Nghỉ / phục hồi" : "Có $exerciseCount bài tập • $doneCount đã thực hiện",
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            children: isRest
                ? [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.spa, color: Colors.grey.shade700),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Hôm nay là ngày nghỉ. Hãy phục hồi và chuẩn bị cho buổi tập tiếp theo nhé!",
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ]
                : exercises.map((ex) {
              final exId = ex.exerciseId.toString().trim();
              final isDone = exId.isNotEmpty && doneIdsToday.contains(exId);
              final title = (ex.name ?? '').toString().trim().isEmpty ? exId : ex.name!.trim();

              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onTapExercise(exId),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isDone ? 0.6 : 1,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDone
                              ? Colors.green.withOpacity(0.25)
                              : Colors.black.withOpacity(0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDone ? Colors.green.withOpacity(0.12) : null,
                              gradient: isDone ? null : LinearGradient(colors: AppColors.primaryG),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              isDone ? Icons.check_circle : Icons.play_arrow_rounded,
                              color: isDone ? Colors.green : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.blackColor,
                                decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.chevron_right, color: Colors.grey.shade600),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
