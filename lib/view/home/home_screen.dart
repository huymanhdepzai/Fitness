import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/activity_tracker/activity_tracker_screen.dart';
import 'package:fitnessapp/view/finish_workout/finish_workout_screen.dart';
import 'package:fitnessapp/view/home/widgets/workout_row.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

import '../../common_widgets/round_button.dart';
import '../../user/models/app_user.dart';
import '../../user/services/user_local_storage.dart';
import '../../user/services/saved_workout_plan.dart';
import '../../user/services/workout_plan_storage.dart';
import '../notification/notification_screen.dart';

// ✅ thêm: để bấm "Xem chi tiết" mở lịch sử giống ActivityTrackerScreen
import '../workour_detail_view/widgets/activity_history_screen.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/HomeScreen";

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ===== Activity chart tooltip (cũ) =====
  List<int> showingTooltipOnSpots = [0];

  // ===== Progress chart (mới) =====
  SavedWorkoutPlan? _plan;
  bool _loadingPlan = true;

  String _progressMode = "Hàng tuần"; // "Hàng tuần" | "Hàng tháng"
  List<int> _progressTooltipOnSpots = [0];

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

  // ✅ thêm: giống ActivityTrackerScreen
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

  List<FlSpot> _buildProgressSpots({
    required DateTime start,
    required DateTime end,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> historyDocs,
  }) {
    // gom history theo ngày: dateOnly -> set exerciseId đã tập
    final Map<DateTime, Set<String>> doneIdsByDay = {};

    for (final doc in historyDocs) {
      final m = doc.data();
      final ts = m['performedAt'];
      if (ts is! Timestamp) continue;

      final d = _dateOnly(ts.toDate());
      final exId = (m['exerciseId'] ?? '').toString().trim();
      if (exId.isEmpty) continue;

      doneIdsByDay.putIfAbsent(d, () => <String>{}).add(exId);
    }

    final days = end.difference(start).inDays; // end exclusive
    final List<FlSpot> spots = [];

    for (int i = 0; i < days; i++) {
      final date = _dateOnly(start.add(Duration(days: i)));
      final planDay = _findPlanDay(date);

      double percent = 0;

      if (planDay != null && planDay.type != SavedPlanDayType.rest) {
        final plannedIds = planDay.exercises.map((e) => e.exerciseId).toSet();
        final doneIds = doneIdsByDay[date] ?? <String>{};

        final planned = plannedIds.length;
        final done = plannedIds.intersection(doneIds).length;

        if (planned > 0) {
          percent = (done / planned) * 100.0;
        } else {
          percent = 0;
        }
      } else {
        // ngày nghỉ hoặc không có plan
        percent = 0;
      }

      // x-axis: 1..days
      spots.add(FlSpot((i + 1).toDouble(), percent.clamp(0, 100)));
    }

    return spots;
  }

  // ===== dữ liệu cũ =====
  List<FlSpot> get allSpots => const [
    FlSpot(0, 20),
    FlSpot(1, 25),
    FlSpot(2, 40),
    FlSpot(3, 50),
    FlSpot(4, 35),
    FlSpot(5, 40),
    FlSpot(6, 30),
    FlSpot(7, 20),
    FlSpot(8, 25),
    FlSpot(9, 40),
    FlSpot(10, 50),
    FlSpot(11, 35),
    FlSpot(12, 50),
    FlSpot(13, 60),
    FlSpot(14, 40),
    FlSpot(15, 50),
    FlSpot(16, 20),
    FlSpot(17, 25),
    FlSpot(18, 40),
    FlSpot(19, 50),
    FlSpot(20, 35),
    FlSpot(21, 80),
    FlSpot(22, 30),
    FlSpot(23, 20),
    FlSpot(24, 25),
    FlSpot(25, 40),
    FlSpot(26, 50),
    FlSpot(27, 35),
    FlSpot(28, 50),
    FlSpot(29, 60),
    FlSpot(30, 40),
  ];

  List waterArr = [
    {"title": "6am - 8am", "subtitle": "600ml"},
    {"title": "9am - 11am", "subtitle": "500ml"},
    {"title": "11am - 2pm", "subtitle": "1000ml"},
    {"title": "2pm - 4pm", "subtitle": "700ml"},
    {"title": "4pm - now", "subtitle": "900ml"}
  ];

  List<LineChartBarData> get lineBarsData1 => [
    lineChartBarData1_1,
    lineChartBarData1_2,
  ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
    isCurved: true,
    gradient: LinearGradient(colors: [
      AppColors.primaryColor2.withOpacity(0.5),
      AppColors.primaryColor1.withOpacity(0.5),
    ]),
    barWidth: 4,
    isStrokeCapRound: true,
    dotData: FlDotData(show: false),
    belowBarData: BarAreaData(show: false),
    spots: const [
      FlSpot(1, 35),
      FlSpot(2, 70),
      FlSpot(3, 40),
      FlSpot(4, 80),
      FlSpot(5, 25),
      FlSpot(6, 70),
      FlSpot(7, 35),
    ],
  );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
    isCurved: true,
    gradient: LinearGradient(colors: [
      AppColors.secondaryColor2.withOpacity(0.5),
      AppColors.secondaryColor1.withOpacity(0.5),
    ]),
    barWidth: 2,
    isStrokeCapRound: true,
    dotData: FlDotData(show: false),
    belowBarData: BarAreaData(show: false),
    spots: const [],
  );

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return FutureBuilder<AppUser?>(
      future: UserLocalStorage.getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Không tìm thấy dữ liệu người dùng.\nHãy đăng nhập lại.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final displayName = (user.displayName)?.trim();

        // Lấy weight + height để tính BMI
        final weight = double.tryParse(user.weight ?? '');
        final height = double.tryParse(user.height ?? '');

        double? bmi;
        if (weight != null && height != null && height > 0) {
          final hMeter = height > 10 ? height / 100 : height;
          bmi = weight / (hMeter * hMeter);
        }

        final bmiText = bmi != null ? bmi.toStringAsFixed(1) : '20.1';
        String bmiStatus;
        if (bmi == null) {
          bmiStatus = 'Cập nhật cân nặng và chiều cao của bạn';
        } else if (bmi < 18.5) {
          bmiStatus = 'Bạn bị thiếu cân';
        } else if (bmi < 25) {
          bmiStatus = 'Bạn có cân nặng bình thường';
        } else if (bmi < 30) {
          bmiStatus = 'Bạn thừa cân';
        } else {
          bmiStatus = 'Bạn béo phì';
        }

        // Activity line chart data (cũ)
        final lineBarsData = [
          LineChartBarData(
            showingIndicators: showingTooltipOnSpots,
            spots: allSpots,
            isCurved: false,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor2.withOpacity(0.4),
                  AppColors.primaryColor1.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            dotData: FlDotData(show: false),
            gradient: LinearGradient(
              colors: AppColors.primaryG,
            ),
          ),
        ];

        final tooltipsOnBar = lineBarsData[0];

        return Scaffold(
          backgroundColor: AppColors.whiteColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------- HEADER ----------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Xin chào,",
                              style: TextStyle(
                                color: AppColors.midGrayColor,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              displayName ?? '',
                              style: const TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 20,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          ],
                        ),
                        // IconButton(
                        //   onPressed: () {
                        //     Navigator.pushNamed(
                        //         context, NotificationScreen.routeName);
                        //   },
                        //   icon: Image.asset(
                        //     "assets/icons/notification_icon.png",
                        //     width: 25,
                        //     height: 25,
                        //     fit: BoxFit.fitHeight,
                        //   ),
                        // ),
                      ],
                    ),
                    SizedBox(height: media.width * 0.05),

                    // ---------- CARD BMI ----------
                    Container(
                      height: media.width * 0.4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.primaryG),
                        borderRadius:
                        BorderRadius.circular(media.width * 0.065),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            "assets/icons/bg_dots.png",
                            height: media.width * 0.4,
                            width: double.maxFinite,
                            fit: BoxFit.fitHeight,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 25, horizontal: 25),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "BMI (Chỉ số khối cơ thể)",
                                      style: TextStyle(
                                        color: AppColors.whiteColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      bmiStatus,
                                      style: TextStyle(
                                        color: AppColors.whiteColor
                                            .withOpacity(0.7),
                                        fontSize: 12,
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(height: media.width * 0.05),
                                    SizedBox(
                                      height: 35,
                                      width: 100,
                                      child: RoundButton(
                                        title: "Xem chi tiết",
                                        onPressed: () {},
                                      ),
                                    ),
                                  ],
                                ),
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: PieChart(
                                    PieChartData(
                                      pieTouchData: PieTouchData(
                                        touchCallback: (event, response) {},
                                      ),
                                      startDegreeOffset: 250,
                                      borderData: FlBorderData(show: false),
                                      sectionsSpace: 1,
                                      centerSpaceRadius: 0,
                                      sections: showingSections(bmiText),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ---------- Today Target ----------
                    SizedBox(height: media.width * 0.05),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor1.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Mục tiêu hôm nay",
                            style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            width: 75,
                            height: 30,
                            child: RoundButton(
                              title: "Xem",
                              type: RoundButtonType.primaryBG,
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, ActivityTrackerScreen.routeName);
                              },
                            ),
                          )
                        ],
                      ),
                    ),

                    // ---------- Sleep ----------
                    SizedBox(height: media.width * 0.05),
                    Container(
                      width: double.maxFinite,
                      height: media.width * 0.45,
                      padding: const EdgeInsets.symmetric(
                          vertical: 25, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 2)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Ngủ",
                            style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: media.width * 0.01),
                          ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: AppColors.primaryG,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ).createShader(Rect.fromLTRB(
                                  0, 0, bounds.width, bounds.height));
                            },
                            child: const Text(
                              "8h 20m",
                              style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Image.asset(
                              "assets/images/sleep_graph.png",
                              width: double.maxFinite,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ---------- Workout Progress ----------
                    SizedBox(height: media.width * 0.1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tiến độ tập luyện",
                          style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          height: 35,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: AppColors.primaryG),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              items: ["Hàng tuần", "Hàng tháng"]
                                  .map(
                                    (name) => DropdownMenuItem(
                                  value: name,
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      color: AppColors.blackColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _progressMode = value.toString());
                              },
                              icon: const Icon(Icons.expand_more,
                                  color: AppColors.whiteColor),
                              hint: Text(
                                _progressMode,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: media.width * 0.05),

                    // === CHART tiến độ: dựa vào Plan + History ===
                    Container(
                      padding: const EdgeInsets.only(left: 15),
                      height: media.width * 0.5,
                      width: double.maxFinite,
                      child: _loadingPlan
                          ? const Center(child: CircularProgressIndicator())
                          : (_plan == null)
                          ? const Center(
                        child: Text(
                          'Bạn chưa có kế hoạch tập luyện.',
                          style: TextStyle(color: AppColors.grayColor),
                        ),
                      )
                          : Builder(
                        builder: (_) {
                          final fbUser =
                              FirebaseAuth.instance.currentUser;
                          if (fbUser == null) {
                            return const Center(
                                child: Text('Chưa đăng nhập'));
                          }

                          final now = DateTime.now();
                          final today =
                          DateTime(now.year, now.month, now.day);

                          late DateTime start;
                          late DateTime end;

                          if (_progressMode == "Hàng tháng") {
                            start = DateTime(today.year, today.month, 1);
                            end = (today.month == 12)
                                ? DateTime(today.year + 1, 1, 1)
                                : DateTime(today.year, today.month + 1, 1);
                          } else {
                            // 7 ngày gần nhất (gồm hôm nay)
                            start = today.subtract(const Duration(days: 6));
                            end = today.add(const Duration(days: 1));
                          }

                          final q = FirebaseFirestore.instance
                              .collection('users')
                              .doc(fbUser.uid)
                              .collection('workout_history')
                              .where(
                            'performedAt',
                            isGreaterThanOrEqualTo:
                            Timestamp.fromDate(start),
                          )
                              .where(
                            'performedAt',
                            isLessThan: Timestamp.fromDate(end),
                          )
                              .orderBy('performedAt', descending: false);

                          return StreamBuilder<
                              QuerySnapshot<Map<String, dynamic>>>(
                            stream: q.snapshots(),
                            builder: (context, snap) {
                              if (snap.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snap.hasError) {
                                return Center(
                                    child: Text('Lỗi: ${snap.error}'));
                              }

                              final historyDocs = snap.data?.docs ?? [];

                              final spots = _buildProgressSpots(
                                start: start,
                                end: end,
                                historyDocs: historyDocs,
                              );

                              if (spots.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'Không có dữ liệu để vẽ.',
                                    style: TextStyle(
                                        color: AppColors.grayColor),
                                  ),
                                );
                              }

                              final safeTooltipIndex =
                              (_progressTooltipOnSpots.isEmpty)
                                  ? 0
                                  : _progressTooltipOnSpots.first
                                  .clamp(0, spots.length - 1);

                              final bar = LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryColor2
                                          .withOpacity(0.25),
                                      AppColors.primaryColor1
                                          .withOpacity(0.05),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                gradient: LinearGradient(
                                    colors: AppColors.primaryG),
                                showingIndicators: [safeTooltipIndex],
                              );

                              return LineChart(
                                LineChartData(
                                  lineBarsData: [bar],
                                  minY: 0,
                                  maxY: 100,
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 25,
                                    getDrawingHorizontalLine: (v) =>
                                        FlLine(
                                          color: AppColors.grayColor
                                              .withOpacity(0.15),
                                          strokeWidth: 2,
                                        ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    topTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                            showTitles: false)),
                                    leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                            showTitles: false)),
                                    rightTitles: AxisTitles(
                                        sideTitles: rightTitles),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 32,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          final i = value.toInt();
                                          if (i < 1 || i > spots.length) {
                                            return const SizedBox
                                                .shrink();
                                          }

                                          final date = start.add(
                                              Duration(days: i - 1));

                                          if (_progressMode ==
                                              "Hàng tháng") {
                                            // giảm rối: chỉ hiện vài mốc
                                            if (!(date.day == 1 ||
                                                date.day == 7 ||
                                                date.day == 14 ||
                                                date.day == 21 ||
                                                date.day == 28)) {
                                              return const SizedBox
                                                  .shrink();
                                            }
                                            return SideTitleWidget(
                                              axisSide: meta.axisSide,
                                              space: 10,
                                              child: Text(
                                                '${date.day}',
                                                style: const TextStyle(
                                                  color: AppColors
                                                      .grayColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            );
                                          }

                                          // tuần: hiện thứ theo ngày thực
                                          const wd = [
                                            'Mon',
                                            'Tue',
                                            'Wed',
                                            'Thu',
                                            'Fri',
                                            'Sat',
                                            'Sun'
                                          ];
                                          final label =
                                          wd[(date.weekday - 1) % 7];

                                          return SideTitleWidget(
                                            axisSide: meta.axisSide,
                                            space: 10,
                                            child: Text(
                                              label,
                                              style: const TextStyle(
                                                color: AppColors.grayColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  showingTooltipIndicators: [
                                    ShowingTooltipIndicators([
                                      LineBarSpot(bar, 0,
                                          spots[safeTooltipIndex]),
                                    ]),
                                  ],
                                  lineTouchData: LineTouchData(
                                    enabled: true,
                                    handleBuiltInTouches: false,
                                    touchCallback: (event, response) {
                                      if (response?.lineBarSpots ==
                                          null) return;
                                      if (event is FlTapUpEvent) {
                                        final idx = response!
                                            .lineBarSpots!.first.spotIndex;
                                        setState(() {
                                          _progressTooltipOnSpots = [idx];
                                        });
                                      }
                                    },
                                    getTouchedSpotIndicator:
                                        (barData, indexes) {
                                      return indexes.map((idx) {
                                        return TouchedSpotIndicatorData(
                                          FlLine(
                                              color: Colors.transparent),
                                          FlDotData(
                                            show: true,
                                            getDotPainter: (_, __, ___,
                                                ____) =>
                                                FlDotCirclePainter(
                                                  radius: 3,
                                                  color: Colors.white,
                                                  strokeWidth: 3,
                                                  strokeColor:
                                                  AppColors.secondaryColor1,
                                                ),
                                          ),
                                        );
                                      }).toList();
                                    },
                                    touchTooltipData:
                                    LineTouchTooltipData(
                                      getTooltipColor: (_) =>
                                      AppColors.secondaryColor1,
                                      tooltipRoundedRadius: 14,
                                      getTooltipItems: (touchedSpots) {
                                        return touchedSpots.map((s) {
                                          final date = start.add(
                                              Duration(days: s.x.toInt() - 1));
                                          return LineTooltipItem(
                                            '${_fmtDDMM(date)} • ${s.y.toStringAsFixed(0)}%',
                                            const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight:
                                              FontWeight.w800,
                                            ),
                                          );
                                        }).toList();
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // ---------- Latest Workout (GIỐNG ActivityTrackerScreen, TỐI ĐA 3 THẺ) ----------
                    SizedBox(height: media.width * 0.05),
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
                            "Xem chi tiết",
                            style: TextStyle(
                              color: AppColors.grayColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Builder(
                      builder: (_) {
                        final fbUser = FirebaseAuth.instance.currentUser;
                        if (fbUser == null) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Chưa đăng nhập.',
                              style: TextStyle(
                                color: AppColors.grayColor,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }

                        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(fbUser.uid)
                              .collection('workout_history')
                              .orderBy('performedAt', descending: true)
                              .limit(3) // ✅ tối đa 3 thẻ
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
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }

                            final docs = snap.data?.docs ?? [];
                            if (docs.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
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
                              separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                              itemBuilder: (_, i) {
                                final m = docs[i].data();

                                final name = (m['exerciseName'] ??
                                    m['workoutTitle'] ??
                                    'Workout')
                                    .toString();
                                final target =
                                (m['primaryTarget'] ?? '').toString();
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
                                      BoxShadow(
                                          color: Colors.black12, blurRadius: 2)
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor1
                                              .withOpacity(0.12),
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.history,
                                            color: AppColors.blackColor),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                        );
                      },
                    ),

                    SizedBox(height: media.width * 0.1),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ----------------- PIE CHART BMI -----------------
  List<PieChartSectionData> showingSections(String bmiText) {
    return List.generate(
      2,
          (i) {
        const color0 = AppColors.secondaryColor2;
        const color1 = AppColors.whiteColor;

        switch (i) {
          case 0:
            return PieChartSectionData(
              color: color0,
              value: 33,
              title: '',
              radius: 55,
              titlePositionPercentageOffset: 0.55,
              badgeWidget: Text(
                bmiText,
                style: const TextStyle(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            );
          case 1:
            return PieChartSectionData(
              color: color1,
              value: 75,
              title: '',
              radius: 42,
              titlePositionPercentageOffset: 0.55,
            );
          default:
            throw Error();
        }
      },
    );
  }

  // ----------------- TITLES CHART -----------------
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
      style: const TextStyle(
        color: AppColors.grayColor,
        fontSize: 12,
      ),
      textAlign: TextAlign.center,
    );
  }
}
