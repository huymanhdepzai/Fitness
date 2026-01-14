import 'package:flutter/material.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/common_widgets/round_gradient_button.dart';
import 'package:fitnessapp/view/workour_detail_view/widgets/icon_title_next_row.dart';
import 'package:fitnessapp/view/workout_schedule_view/workout_schedule_view.dart';

import '../../user/services/user_local_storage.dart';
import '../activity/exercises_by_target_view.dart'; // ✅ có ExercisesByTargetView + ExercisesByTargetBody

class WorkoutDetailView extends StatefulWidget {
  final Map dObj;

  /// dObj nên có:
  /// - title (String)
  /// - primaryTarget (String)  // lowercase/normal đều được
  /// - goal (String) optional // nếu có thì khỏi load local user
  /// - equipments (List<Map>) optional
  /// - time/exercises/calories/difficulty optional
  const WorkoutDetailView({Key? key, required this.dObj}) : super(key: key);

  @override
  State<WorkoutDetailView> createState() => _WorkoutDetailViewState();
}

class _WorkoutDetailViewState extends State<WorkoutDetailView> {
  String? _goal;
  late String _target; // lowercase
  bool _loadingGoal = true;

  @override
  void initState() {
    super.initState();

    _target = (widget.dObj['primaryTarget'] ??
        widget.dObj['target'] ??
        widget.dObj['muscle'] ??
        '')
        .toString()
        .trim()
        .toLowerCase();

    final fromMap = widget.dObj['goal']?.toString();
    if (fromMap != null && fromMap.trim().isNotEmpty) {
      _goal = fromMap.trim();
      _loadingGoal = false;
    } else {
      _loadGoalFromLocal();
    }
  }

  Future<void> _loadGoalFromLocal() async {
    final user = await UserLocalStorage.getUser();
    if (!mounted) return;
    setState(() {
      _goal = user?.goal;
      _loadingGoal = false;
    });
  }

  List<Map<String, dynamic>> get youArr {
    final raw = widget.dObj['equipments'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  String _titleCase(String s) {
    final t = s.trim();
    if (t.isEmpty) return t;
    final words = t.split(RegExp(r'\s+'));
    return words
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.dObj["title"]?.toString() ?? "Workout";
    final exercisesLabel = widget.dObj["exercises"]?.toString() ?? "";
    final timeLabel = widget.dObj["time"]?.toString() ?? "";
    final calories = widget.dObj["calories"] ?? 320;
    final difficulty = widget.dObj["difficulty"]?.toString() ?? "Beginner";

    final media = MediaQuery.of(context).size;
    final hasGoal = (_goal ?? '').trim().isNotEmpty;
    final hasTarget = _target.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryG)),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.transparent,
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
              leading: const SizedBox.shrink(),
              expandedHeight: media.width * 0.5,
              flexibleSpace: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/images/detail_top.png",
                  width: media.width * 0.75,
                  height: media.width * 0.8,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: const BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                SingleChildScrollView(
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

                      // ===== Header info =====
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "Tổng số bài phù hợp với mục tiêu: $exercisesLabel",
                                  style: TextStyle(
                                    color: AppColors.grayColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // TextButton(
                          //   onPressed: () {},
                          //   child: Image.asset(
                          //     "assets/icons/fav_icon.png",
                          //     width: 15,
                          //     height: 15,
                          //     fit: BoxFit.contain,
                          //   ),
                          // )
                        ],
                      ),

                      // SizedBox(height: media.width * 0.05),
                      //
                      // // ===== Schedule + difficulty =====
                      // IconTitleNextRow(
                      //   icon: "assets/icons/time_icon.png",
                      //   title: "Schedule Workout",
                      //   time: "5/27, 09:00 AM",
                      //   color: AppColors.primaryColor2.withOpacity(0.3),
                      //   onPressed: () {
                      //     Navigator.pushNamed(context, WorkoutScheduleView.routeName);
                      //   },
                      // ),
                      // SizedBox(height: media.width * 0.02),
                      // IconTitleNextRow(
                      //   icon: "assets/icons/difficulity_icon.png",
                      //   title: "Difficulity",
                      //   time: difficulty,
                      //   color: AppColors.secondaryColor2.withOpacity(0.3),
                      //   onPressed: () {},
                      // ),
                      //
                      // SizedBox(height: media.width * 0.05),

                      // ===== Equipments (optional) =====
                      /*Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Bạn sẽ cần",
                            style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "${youArr.length} dụng cụ",
                              style: TextStyle(color: AppColors.grayColor, fontSize: 12),
                            ),
                          )
                        ],
                      ),*/

                      // if (youArr.isEmpty)
                      //   Padding(
                      //     padding: const EdgeInsets.symmetric(vertical: 8),
                      //     child: Text(
                      //       "Không có thông tin dụng cụ.",
                      //       style: TextStyle(color: AppColors.grayColor, fontSize: 12),
                      //     ),
                      //   )
                      // else
                      //   SizedBox(
                      //     height: media.width * 0.5,
                      //     child: ListView.builder(
                      //       padding: EdgeInsets.zero,
                      //       scrollDirection: Axis.horizontal,
                      //       shrinkWrap: true,
                      //       itemCount: youArr.length,
                      //       itemBuilder: (context, index) {
                      //         final yObj = youArr[index];
                      //         return Container(
                      //           margin: const EdgeInsets.all(8),
                      //           child: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: [
                      //               Container(
                      //                 height: media.width * 0.35,
                      //                 width: media.width * 0.35,
                      //                 decoration: BoxDecoration(
                      //                   color: AppColors.lightGrayColor,
                      //                   borderRadius: BorderRadius.circular(15),
                      //                 ),
                      //                 alignment: Alignment.center,
                      //                 child: Image.asset(
                      //                   yObj["image"].toString(),
                      //                   width: media.width * 0.2,
                      //                   height: media.width * 0.2,
                      //                   fit: BoxFit.contain,
                      //                 ),
                      //               ),
                      //               Padding(
                      //                 padding: const EdgeInsets.all(8.0),
                      //                 child: Text(
                      //                   yObj["title"].toString(),
                      //                   style: const TextStyle(
                      //                     color: AppColors.blackColor,
                      //                     fontSize: 12,
                      //                   ),
                      //                 ),
                      //               )
                      //             ],
                      //           ),
                      //         );
                      //       },
                      //     ),
                      //   ),

                      SizedBox(height: media.width * 0.05),

                      // ===== Exercises list by goal+target =====
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            hasTarget ? "Bài tập cho ${_titleCase(_target)}" : "Bài tập",
                            style: const TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (hasGoal && hasTarget)
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ExercisesByTargetView(goal: _goal!, target: _target),
                                  ),
                                );
                              },
                              child: Text(
                                "Xem tất cả",
                                style: TextStyle(color: AppColors.grayColor, fontSize: 12),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      if (_loadingGoal)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (!hasGoal)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            "Bạn chưa chọn mục tiêu (goal).",
                            style: TextStyle(color: AppColors.grayColor, fontSize: 12),
                          ),
                        )
                      else if (!hasTarget)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              "Thiếu primaryTarget để lọc bài tập.",
                              style: TextStyle(color: AppColors.grayColor, fontSize: 12),
                            ),
                          )
                        else
                        // ✅ Nhúng body list, không bị nested Scaffold
                          SizedBox(
                            height: media.height * 0.62,
                            child: ExercisesByTargetBody(
                              goal: _goal!,
                              target: _target,
                              padding: EdgeInsets.zero,
                            ),
                          ),

                      SizedBox(height: media.width * 0.18), // chừa chỗ cho nút dưới
                    ],
                  ),
                ),

                // ===== Bottom button =====
                SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      RoundGradientButton(
                        title: "Xem tất cả bài tập",
                        onPressed: () {
                          if (!hasGoal || !hasTarget) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExercisesByTargetView(goal: _goal!, target: _target),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
