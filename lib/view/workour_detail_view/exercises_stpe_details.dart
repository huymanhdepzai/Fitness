import 'dart:async';

import 'package:fitnessapp/common_widgets/round_gradient_button.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/workour_detail_view/widgets/step_detail_row.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import '../finish_workout/finish_workout_screen.dart';

class ExercisesStepDetails extends StatefulWidget {
  final Map eObj;

  final String sessionId;
  final String workoutId;
  final String workoutTitle;
  final int setIndex;
  final int stepIndex;
  final bool isLastStepOfWorkout;

  const ExercisesStepDetails({
    Key? key,
    required this.eObj,
    required this.sessionId,
    required this.workoutId,
    required this.workoutTitle,
    required this.setIndex,
    required this.stepIndex,
    required this.isLastStepOfWorkout,
  }) : super(key: key);


  @override
  State<ExercisesStepDetails> createState() => _ExercisesStepDetailsState();
}

class _ExercisesStepDetailsState extends State<ExercisesStepDetails> {
  /// Lấy trực tiếp steps từ Firestore (truyền qua eObj)
  List<Map<String, dynamic>> get stepArr {
    final raw = widget.eObj['steps'];

    if (raw is List) {
      return raw.map<Map<String, dynamic>>((e) {
        if (e is Map<String, dynamic>) return e;
        if (e is Map) return Map<String, dynamic>.from(e);
        return <String, dynamic>{};
      }).where((e) => e.isNotEmpty).toList();
    }

    // Không có field steps trong Firestore
    return [];
  }
  int _selectedRepeat = 1;
  Duration _remaining = Duration.zero;
  Timer? _timer;
  bool _isRunning = false;

  int get _baseMinutes {
    // TODO: tùy bạn, có thể lấy từ widget.eObj['baseMinutes']
    // hoặc một field như 'durationMinutes'. Tạm thời default 1 phút.
    return (widget.eObj['baseMinutes'] as int?) ?? 1;
  }

  int get _caloriesPerRepeat {
    // tuỳ thiết kế: nếu calories trong eObj là cho 1 lần mặc định,
    // có thể scale theo số lần. Tạm cho 10 cal / repeat nếu không có
    if (widget.eObj['caloriesPerRepeat'] != null) {
      return widget.eObj['caloriesPerRepeat'] as int;
    }
    final base = widget.eObj['calories'] as int? ?? 0;
    return base == 0 ? 10 : base;
  }

  String get _timerText {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startTimer() {
    final totalSeconds = _baseMinutes * 60 * _selectedRepeat;

    setState(() {
      _remaining = Duration(seconds: totalSeconds);
      _isRunning = true;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remaining.inSeconds <= 1) {
        timer.cancel();
        await _onTimerFinished();
      } else {
        setState(() {
          _remaining = Duration(seconds: _remaining.inSeconds - 1);
        });
      }
    });
  }

  Future<void> _onTimerFinished() async {
    setState(() {
      _isRunning = false;
      _remaining = Duration.zero;
    });

    final burnedCalories = _caloriesPerRepeat * _selectedRepeat;

    int nextSetIndex = widget.setIndex;
    int nextStepIndex = widget.stepIndex + 1;

    final isFinishedWorkout = widget.isLastStepOfWorkout;
    if (isFinishedWorkout) {
      nextSetIndex = widget.setIndex;
      nextStepIndex = widget.stepIndex;
    }

    // try {
    //   await WorkoutProgressService.updateAfterStepDone(
    //     sessionId: widget.sessionId,
    //     workoutId: widget.workoutId,
    //     workoutTitle: widget.workoutTitle,
    //     prevSetIndex: widget.setIndex,
    //     prevStepIndex: widget.stepIndex,
    //     nextSetIndex: nextSetIndex,
    //     nextStepIndex: nextStepIndex,
    //     addCalories: burnedCalories,
    //     isFinishedWorkout: isFinishedWorkout,
    //   );
    // } catch (e, st) {
    //   // log ra console cho dễ trace
    //   // ignore: avoid_print
    //   print('🔥 updateAfterStepDone error: $e');
    //   print(st);
    //
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Lỗi lưu tiến độ: $e')),
    //     );
    //   }
    //   return; // đừng navigate nữa nếu Firestore lỗi
    // }

    if (!mounted) return;

    if (isFinishedWorkout) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        FinishWorkoutScreen.routeName,
            (route) => false,
        arguments: {
          'workoutId': widget.workoutId,
          'title': widget.workoutTitle,
        },
      );
    } else {
      Navigator.pop(context);
    }
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final difficulty = widget.eObj['difficulty']?.toString() ?? 'Easy';
    final calories = widget.eObj['calories'] ?? 390;
    final description = widget.eObj['description']?.toString() ??
        'No description yet for this exercise.';

    var media = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
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
              "assets/icons/closed_btn.png",
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
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video / thumbnail
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: media.width,
                    height: media.width * 0.43,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: AppColors.primaryG),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.asset(
                      "assets/images/video_temp.png",
                      width: media.width,
                      height: media.width * 0.43,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Container(
                    width: media.width,
                    height: media.width * 0.43,
                    decoration: BoxDecoration(
                      color: AppColors.blackColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: nếu sau này có videoUrl trong eObj thì mở video ở đây
                    },
                    icon: Image.asset(
                      "assets/icons/play_icon.png",
                      width: 30,
                      height: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Title
              Text(
                widget.eObj["title"].toString(),
                style: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),

              // Difficulty + calories
              Text(
                "$difficulty | Đốt $calories Calories",
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 15),

              // Description
              Text(
                "Mô tả",
                style: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              ReadMoreText(
                description,
                trimLines: 4,
                colorClickableText: AppColors.blackColor,
                trimMode: TrimMode.Line,
                trimCollapsedText: ' Read More ...',
                trimExpandedText: ' Read Less',
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 12,
                ),
                moreStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 15),

              // Steps
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Cách thực hiện",
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "${stepArr.length} bước",
                      style: TextStyle(
                        color: AppColors.grayColor,
                        fontSize: 12,
                      ),
                    ),
                  )
                ],
              ),

              if (stepArr.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    "No step-by-step instructions yet.",
                    style: TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: stepArr.length,
                  itemBuilder: (context, index) {
                    final sObj = stepArr[index];
                    return StepDetailRow(
                      sObj: sObj,
                      isLast: index == stepArr.length - 1,
                    );
                  },
                ),

              // Custom Repetitions (giữ nguyên, chưa gắn vào Firestore)
              Text(
                "Sự lặp lại (tùy chỉnh)",
                style: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 150,
                child: CupertinoPicker.builder(
                  itemExtent: 40,
                  selectionOverlay: Container(
                    width: double.maxFinite,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppColors.grayColor.withOpacity(0.2),
                          width: 1,
                        ),
                        bottom: BorderSide(
                          color: AppColors.grayColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedRepeat = index + 1;
                    });
                  },
                  childCount: 60,
                  itemBuilder: (context, index) {
                    final repeat = index + 1;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/burn_icon.png",
                          width: 15,
                          height: 15,
                          fit: BoxFit.contain,
                        ),
                        Text(
                          " Đốt ${_caloriesPerRepeat * repeat} Calories",
                          style: TextStyle(
                            color: AppColors.grayColor,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          " $repeat ",
                          style: TextStyle(
                            color: AppColors.grayColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          " lần",
                          style: TextStyle(
                            color: AppColors.grayColor,
                            fontSize: 16,
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),

              // Đồng hồ đếm ngược
              if (_isRunning || _remaining > Duration.zero)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      _timerText,
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Thời gian còn lại",
                      style: TextStyle(
                        color: AppColors.grayColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),

              RoundGradientButton(
                title: _isRunning ? "Đang luyện tập..." : "Bắt đầu set này",
                onPressed: _isRunning ? null : _startTimer,
              ),
              const SizedBox(height: 15),

            ],
          ),
        ),
      ),
    );
  }
}
