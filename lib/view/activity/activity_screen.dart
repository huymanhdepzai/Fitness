import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widgets/round_button.dart';
import '../../services/notification_service.dart';
import '../../user/services/user_local_storage.dart';
import '../../user/services/saved_workout_plan.dart';
import '../../user/services/workout_plan_storage.dart';
import '../../workouts/db/exercise_db_repository.dart';
import '../../workouts/db/isar_db.dart';
import '../daily_schedule_view/daily_schedule_view.dart';
import '../workour_detail_view/workour_detail_view.dart';
import 'widgets/target_group_row.dart';

// ✅ màn plan progress
// NOTE: sửa lại đúng path file của bạn
import '../workour_detail_view/widgets/workout_progress_plan_screen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late final VoidCallback _goalListener;
  final _exerciseRepo = ExerciseDbRepository(IsarDb());

  String? _userGoal;
  bool _loadingGoal = true;

  // ✅ groups by primaryTarget
  List<TargetGroup> _groups = [];
  bool _loadingGroups = false;

  // ✅ plan (để show lịch hôm nay)
  SavedWorkoutPlan? _plan;
  bool _loadingPlan = true;

  @override
  void initState() {
    super.initState();

    _goalListener = () {
      final newGoal = UserLocalStorage.goalNotifier.value;
      if (!mounted) return;

      if ((newGoal ?? '') != (_userGoal ?? '')) {
        setState(() {
          _userGoal = newGoal;
          _loadingGoal = false;
        });
        _loadTargetGroups();
      }
    };

    UserLocalStorage.goalNotifier.addListener(_goalListener);

    _loadUserGoal();
    _loadPlan(); // ✅ load plan để show lịch hôm nay
  }

  @override
  void dispose() {
    UserLocalStorage.goalNotifier.removeListener(_goalListener);
    super.dispose();
  }

  Future<void> _loadUserGoal() async {
    final localUser = await UserLocalStorage.getUser();
    if (!mounted) return;

    setState(() {
      _userGoal = localUser?.goal;
      _loadingGoal = false;
    });

    await _loadTargetGroups();
  }

  Future<void> _loadTargetGroups() async {
    final goal = _userGoal;
    if (goal == null || goal.isEmpty) return;

    setState(() {
      _loadingGroups = true;
      _groups = [];
    });

    await _exerciseRepo.init();
    final groups = await _exerciseRepo.getTargetGroupsForGoal(goal);

    if (!mounted) return;
    setState(() {
      _groups = groups;
      _loadingGroups = false;
    });
  }

  // ===== plan helpers =====
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

  String _fmtDDMM(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  String _titleCase(String s) {
    if (s.trim().isEmpty) return s;
    final words = s.trim().split(RegExp(r'\s+'));
    return words.map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }

  String _todayReminderKey(SavedPlanDay day) {
    final idStr = '${day.date.millisecondsSinceEpoch}_${(day.target ?? 't')}';
    return 'reminder_$idStr';
  }

  int _notificationIdForDay(SavedPlanDay day) {
    final idStr = '${day.date.millisecondsSinceEpoch}_${(day.target ?? 't')}';
    return idStr.hashCode;
  }

  Future<bool> _getReminderEnabled(SavedPlanDay day) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_todayReminderKey(day)) ?? true; // default ON
  }

  Future<void> _setReminderEnabled(SavedPlanDay day, bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_todayReminderKey(day), v);
  }

  // ===== UI small helpers =====
  Widget _miniChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.lightGrayColor.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.blackColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _simpleInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryColor1.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.blackColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade800,
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
  }

  Widget _todayWorkoutCard() {
    final fbUser = FirebaseAuth.instance.currentUser;
    final today = _dateOnly(DateTime.now());

    if (_loadingPlan) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_plan == null) {
      return _simpleInfoCard(
        icon: Icons.info_outline,
        title: "Chưa có kế hoạch",
        subtitle: "Bạn chưa tạo kế hoạch tập luyện. Hãy tạo plan để có lịch mỗi ngày.",
      );
    }

    final day = _findPlanDay(today);

    if (day == null) {
      return _simpleInfoCard(
        icon: Icons.event_busy,
        title: "Hôm nay (${_fmtDDMM(today)})",
        subtitle: "Không có lịch tập trong kế hoạch cho hôm nay.",
      );
    }

    if (day.type == SavedPlanDayType.rest) {
      return _simpleInfoCard(
        icon: Icons.spa_rounded,
        title: "Hôm nay (${_fmtDDMM(today)}) là ngày nghỉ",
        subtitle: "Nghỉ ngơi, phục hồi để buổi sau tập hiệu quả hơn nhé!",
      );
    }

    final exList = day.exercises;
    final target = (day.target ?? '').toString().trim();
    final plannedIds = exList
        .map((e) => e.exerciseId.toString().trim())
        .where((x) => x.isNotEmpty)
        .toSet();

    if (fbUser == null) {
      return _simpleInfoCard(
        icon: Icons.lock_outline,
        title: "Chưa đăng nhập",
        subtitle: "Đăng nhập để theo dõi tiến độ và bật ghi chú buổi tập.",
      );
    }

    final start = today;
    final end = today.add(const Duration(days: 1));

    final historyStream = FirebaseFirestore.instance
        .collection('users')
        .doc(fbUser.uid)
        .collection('workout_history')
        .where('performedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('performedAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('performedAt', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: historyStream,
      builder: (context, snap) {
        final docs = snap.data?.docs ?? [];

        final doneIds = <String>{};
        for (final d in docs) {
          final m = d.data();
          final exId = (m['exerciseId'] ?? '').toString().trim();
          if (exId.isNotEmpty) doneIds.add(exId);
        }

        final doneCount = plannedIds.intersection(doneIds).length;
        final plannedCount = plannedIds.length;
        final percent =
        plannedCount == 0 ? 0.0 : (doneCount / plannedCount).clamp(0.0, 1.0);

        final previewNames = exList.take(3).map((e) {
          final n = (e.name ?? '').toString().trim();
          return n.isEmpty ? e.exerciseId : n;
        }).toList();
        final more = (exList.length - previewNames.length).clamp(0, 999);

        return FutureBuilder<bool>(
          future: _getReminderEnabled(day),
          builder: (context, sw) {
            final enabled = sw.data ?? true;

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
                ],
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: AppColors.primaryG),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.fitness_center_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hôm nay (${_fmtDDMM(today)})",
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: AppColors.blackColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              target.isEmpty
                                  ? "${exList.length} bài • $doneCount/$plannedCount đã thực hiện"
                                  : "Nhóm: $target • ${exList.length} bài • $doneCount/$plannedCount",
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 7,
                      value: percent,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final n in previewNames) _miniChip(n),
                      if (more > 0) _miniChip("+$more bài"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrayColor.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black.withOpacity(0.04)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Ghi chú buổi tập",
                            style: TextStyle(
                              color: Colors.grey.shade900,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Switch(
                          value: enabled,
                          onChanged: (v) async {
                            await _setReminderEnabled(day, v);

                            final id = _notificationIdForDay(day);
                            if (v) {
                              // bật: schedule lại cho hôm nay lúc 18:00
                              final dt = DateTime(today.year, today.month, today.day, 18, 0);
                              final count = exList.length;
                              final title =
                                  'Workout: ${target.isEmpty ? 'Training' : target} ($count bài)';
                              final body = count > 0
                                  ? 'Bài đầu: ${previewNames.first}'
                                  : 'Đến giờ tập rồi! 💪';

                              await NotificationService.scheduleWorkoutNotification(
                                id: id,
                                dateTime: dt,
                                title: title,
                                body: body,
                              );
                            } else {
                              await NotificationService.cancelNotification(id);
                            }

                            if (!mounted) return;
                            setState(() {});
                          },
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryG)),
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              title: const Text(
                "Theo dõi tập luyện",
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                InkWell(
                  onTap: () {},
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
                      "assets/icons/more_icon.png",
                      width: 15,
                      height: 15,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              ],
            ),
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              leadingWidth: 0,
              leading: const SizedBox(),
              expandedHeight: media.height * 0.21,
              flexibleSpace: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: media.width * 0.5,
                width: double.maxFinite,
                child: LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      enabled: true,
                      handleBuiltInTouches: false,
                      touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                        if (response == null || response.lineBarSpots == null) return;
                      },
                      mouseCursorResolver: (FlTouchEvent event, LineTouchResponse? response) {
                        if (response == null || response.lineBarSpots == null) {
                          return SystemMouseCursors.basic;
                        }
                        return SystemMouseCursors.click;
                      },
                      getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                        return spotIndexes.map((index) {
                          return TouchedSpotIndicatorData(
                            const FlLine(color: Colors.transparent),
                            FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                radius: 3,
                                color: Colors.white,
                                strokeWidth: 3,
                                strokeColor: AppColors.secondaryColor1,
                              ),
                            ),
                          );
                        }).toList();
                      },
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (LineBarSpot touchedSpot) => AppColors.secondaryColor1,
                        tooltipRoundedRadius: 20,
                        getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                          return lineBarsSpot.map((lineBarSpot) {
                            return LineTooltipItem(
                              "${lineBarSpot.x.toInt()} mins ago",
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: lineBarsData1,
                    minY: -0.5,
                    maxY: 110,
                    titlesData: FlTitlesData(
                      show: true,
                      leftTitles: const AxisTitles(),
                      topTitles: const AxisTitles(),
                      bottomTitles: AxisTitles(sideTitles: bottomTitles),
                      rightTitles: AxisTitles(sideTitles: rightTitles),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      horizontalInterval: 25,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AppColors.whiteColor.withOpacity(0.15),
                          strokeWidth: 2,
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.transparent),
                    ),
                  ),
                ),
              ),
            )
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grayColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  SizedBox(height: media.width * 0.05),

                  // Lịch tập luyện
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor2.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tạo ghi chú",
                          style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          height: 25,
                          child: RoundButton(
                            title: "Xem",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DailyScheduleView(),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: media.width * 0.05),

                  // Buổi tập sắp tới (hôm nay)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Buổi tập sắp tới",
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
                            MaterialPageRoute(builder: (_) => const WorkoutProgressPlanScreen()),
                          );
                        },
                        child: Text(
                          "Xem thêm",
                          style: TextStyle(
                            color: AppColors.grayColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 10),
                  _todayWorkoutCard(),

                  SizedBox(height: media.width * 0.05),

                  // Nhóm theo target
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Bạn muốn đào tạo điều gì ?",
                        style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  if (_loadingGoal)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_userGoal == null || _userGoal!.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Bạn chưa chọn mục tiêu.',
                        style: TextStyle(color: AppColors.grayColor, fontSize: 12),
                      ),
                    )
                  else if (_loadingGroups)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_groups.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Chưa có nhóm bài tập phù hợp với mục tiêu của bạn.',
                            style: TextStyle(color: AppColors.grayColor, fontSize: 12),
                          ),
                        )
                      else
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _groups.length,
                          itemBuilder: (context, index) {
                            final g = _groups[index];
                            final title = _titleCase(g.target);

                            return TargetGroupRow(
                              title: title,
                              count: g.count,
                              previewGifUrl: g.previewGifUrl,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => WorkoutDetailView(
                                      dObj: {
                                        "id": "target_${g.target}",
                                        "title": _titleCase(g.target),
                                        "primaryTarget": g.target,
                                        "goal": _userGoal!,
                                        "exercises": "${g.count} bài tập",
                                        "time": "",
                                        "calories": 320,
                                        "difficulty": "Beginner",
                                        "equipments": const [],
                                      },
                                    ),
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
        ),
      ),
    );
  }

  // ===== chart config giữ nguyên =====

  List<LineChartBarData> get lineBarsData1 => [
    lineChartBarData1_1,
    lineChartBarData1_2,
  ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
    isCurved: true,
    color: AppColors.whiteColor,
    barWidth: 4,
    isStrokeCapRound: true,
    dotData: FlDotData(show: false),
    belowBarData: BarAreaData(show: false),
    spots: const [],
  );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
    isCurved: true,
    color: AppColors.whiteColor.withOpacity(0.5),
    barWidth: 2,
    isStrokeCapRound: true,
    dotData: FlDotData(show: false),
    belowBarData: BarAreaData(show: false),
    spots: const [],
  );

  SideTitles get rightTitles => SideTitles(
    getTitlesWidget: rightTitleWidgets,
    showTitles: true,
    interval: 20,
    reservedSize: 40,
  );

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0%';
        break;
      case 20:
        text = '20%';
        break;
      case 40:
        text = '40%';
        break;
      case 60:
        text = '60%';
        break;
      case 80:
        text = '80%';
        break;
      case 100:
        text = '100%';
        break;
      default:
        return Container();
    }

    return Text(
      text,
      style: const TextStyle(color: AppColors.whiteColor, fontSize: 12),
      textAlign: TextAlign.center,
    );
  }

  SideTitles get bottomTitles => SideTitles(
    showTitles: true,
    reservedSize: 32,
    interval: 1,
    getTitlesWidget: bottomTitleWidgets,
  );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: AppColors.whiteColor, fontSize: 12);
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = const Text('Sun', style: style);
        break;
      case 2:
        text = const Text('Mon', style: style);
        break;
      case 3:
        text = const Text('Tue', style: style);
        break;
      case 4:
        text = const Text('Wed', style: style);
        break;
      case 5:
        text = const Text('Thu', style: style);
        break;
      case 6:
        text = const Text('Fri', style: style);
        break;
      case 7:
        text = const Text('Sat', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(axisSide: meta.axisSide, space: 10, child: text);
  }
}
