import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:flutter/material.dart';

import '../../user/services/saved_workout_plan.dart';
import '../../user/services/workout_plan_storage.dart';
import '../workour_detail_view/widgets/activity_history_screen.dart';

class ActivityTrackerScreen extends StatefulWidget {
  static String routeName = "/ActivityTrackerScreen";
  const ActivityTrackerScreen({Key? key}) : super(key: key);

  @override
  State<ActivityTrackerScreen> createState() => _ActivityTrackerScreenState();
}

class _ActivityTrackerScreenState extends State<ActivityTrackerScreen> {
  SavedWorkoutPlan? _plan;
  bool _loadingPlan = true;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final p = await WorkoutPlanStorage.loadPlan();
    if (!mounted) return;
    setState(() {
      _plan = p;
      _loadingPlan = false;
    });
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  SavedPlanDay? _findPlanDay(DateTime date) {
    if (_plan == null) return null;
    final dd = _dateOnly(date);
    for (final day in _plan!.days) {
      if (_dateOnly(day.date) == dd) return day;
    }
    return null;
  }

  String _fmtDDMM(DateTime d) {
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}';
  }

  String _timeAgoFromTimestamp(Timestamp? ts) {
    if (ts == null) return '--';
    final now = DateTime.now();
    final t = ts.toDate();
    final diff = now.difference(t);

    if (diff.inSeconds < 60) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    final weeks = (diff.inDays / 7).floor();
    return '$weeks tuần trước';
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final fbUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.lightGrayColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              "assets/icons/back_icon.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text(
          "Theo dõi hoạt động",
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: fbUser == null
          ? const Center(child: Text("Chưa đăng nhập"))
          : SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Column(
            children: [
              // =========================
              // MỤC TIÊU HÔM NAY (THEO PLAN + HISTORY)
              // =========================
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppColors.primaryColor2.withOpacity(0.3),
                    AppColors.primaryColor1.withOpacity(0.3),
                  ]),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Mục tiêu hôm nay",
                          style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_loadingPlan)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_plan == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Bạn chưa có kế hoạch tập luyện.",
                          style: TextStyle(
                            color: AppColors.grayColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      Builder(
                        builder: (_) {
                          final today = _dateOnly(DateTime.now());
                          final planDay = _findPlanDay(today);

                          if (planDay == null) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                "Không có bài theo kế hoạch cho hôm nay (${_fmtDDMM(today)}).",
                                style: const TextStyle(
                                  color: AppColors.grayColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }

                          if (planDay.type == SavedPlanDayType.rest) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                "Hôm nay là ngày nghỉ (${_fmtDDMM(today)}).",
                                style: const TextStyle(
                                  color: AppColors.grayColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }

                          final exList = planDay.exercises;

                          if (exList.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                "Hôm nay chưa có bài trong kế hoạch.",
                                style: TextStyle(
                                  color: AppColors.grayColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }

                          // ==== Query lịch sử trong ngày hôm nay để biết bài nào đã tập ====
                          final startDay = today;
                          final endDay = today.add(const Duration(days: 1));

                          final historyTodayQuery = FirebaseFirestore.instance
                              .collection('users')
                              .doc(fbUser.uid)
                              .collection('workout_history')
                              .where(
                            'performedAt',
                            isGreaterThanOrEqualTo: Timestamp.fromDate(startDay),
                          )
                              .where(
                            'performedAt',
                            isLessThan: Timestamp.fromDate(endDay),
                          )
                              .orderBy('performedAt', descending: true);

                          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: historyTodayQuery.snapshots(),
                            builder: (context, hSnap) {
                              if (hSnap.connectionState == ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              if (hSnap.hasError) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    "Lỗi tải lịch sử hôm nay: ${hSnap.error}",
                                    style: const TextStyle(color: Colors.red, fontSize: 12),
                                  ),
                                );
                              }

                              final historyDocs = hSnap.data?.docs ?? [];

                              // gom các exerciseId đã tập hôm nay
                              final Set<String> doneIds = {};
                              for (final d in historyDocs) {
                                final m = d.data();
                                final exId = (m['exerciseId'] ?? '').toString().trim();
                                if (exId.isNotEmpty) doneIds.add(exId);
                              }

                              final plannedIds =
                              exList.map((e) => e.exerciseId.toString().trim()).toSet();

                              final doneCount = plannedIds.intersection(doneIds).length;
                              final plannedCount = plannedIds.length;

                              final percent = plannedCount == 0
                                  ? 0.0
                                  : (doneCount / plannedCount).clamp(0.0, 1.0);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Nhóm bài (${_fmtDDMM(today)}) • $doneCount/$plannedCount đã hoàn thành",
                                          style: const TextStyle(
                                            color: AppColors.blackColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      if (plannedCount > 0 && doneCount == plannedCount)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: const Text(
                                            "Hoàn tất",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      minHeight: 7,
                                      value: percent,
                                      backgroundColor: Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: exList.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                                    itemBuilder: (_, i) {
                                      final e = exList[i];
                                      final exId = e.exerciseId.toString().trim();

                                      final title = (e.name?.trim().isNotEmpty == true)
                                          ? e.name!.trim()
                                          : exId;

                                      final isDone = exId.isNotEmpty && doneIds.contains(exId);

                                      return AnimatedOpacity(
                                        duration: const Duration(milliseconds: 250),
                                        opacity: isDone ? 0.65 : 1,
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.7),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isDone
                                                  ? Colors.green.withOpacity(0.35)
                                                  : Colors.transparent,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 38,
                                                height: 38,
                                                decoration: BoxDecoration(
                                                  color: isDone
                                                      ? Colors.green.withOpacity(0.12)
                                                      : AppColors.primaryColor1.withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  isDone
                                                      ? Icons.check_circle
                                                      : Icons.fitness_center,
                                                  color: isDone
                                                      ? Colors.green
                                                      : AppColors.blackColor,
                                                  size: 18,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      title,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: AppColors.blackColor,
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w800,
                                                        decoration: isDone
                                                            ? TextDecoration.lineThrough
                                                            : TextDecoration.none,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      isDone
                                                          ? "Đã thực hiện hôm nay"
                                                          : "Chưa thực hiện",
                                                      style: TextStyle(
                                                        color: isDone
                                                            ? Colors.green
                                                            : AppColors.grayColor,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),

              SizedBox(height: media.width * 0.08),

              // =========================
              // TẬP LUYỆN MỚI NHẤT
              // =========================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tập luyện mới nhất",
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ActivityHistoryScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Xem thêm",
                      style: TextStyle(
                        color: AppColors.grayColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(fbUser.uid)
                    .collection('workout_history')
                    .orderBy('performedAt', descending: true)
                    .limit(5)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        "Lỗi tải lịch sử: ${snap.error}",
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    );
                  }

                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Chưa có lịch sử tập luyện.",
                        style: TextStyle(
                          color: AppColors.grayColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(top: 8),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final m = docs[i].data();
                      final name = (m['exerciseName'] ?? m['workoutTitle'] ?? 'Workout')
                          .toString();
                      final target = (m['primaryTarget'] ?? '').toString();
                      final sets = (m['sets'] ?? 0);
                      final reps = (m['reps'] ?? 0);
                      final ts = m['performedAt'] as Timestamp?;

                      final timeAgo = _timeAgoFromTimestamp(ts);

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 2)
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor1.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.history, color: AppColors.blackColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.blackColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    target.isNotEmpty
                                        ? "Nhóm: $target • $sets hiệp • $reps reps"
                                        : "$sets hiệp • $reps reps",
                                    style: const TextStyle(
                                      color: AppColors.grayColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    timeAgo,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              SizedBox(height: media.width * 0.1),
            ],
          ),
        ),
      ),
    );
  }
}
