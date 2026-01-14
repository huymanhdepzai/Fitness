import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/profile/widgets/setting_row.dart';
import 'package:fitnessapp/view/profile/widgets/title_subtitle_cell.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../common_widgets/round_button.dart';
import '../workour_detail_view/widgets/activity_history_screen.dart';
import '../workour_detail_view/widgets/workout_progress_plan_screen.dart';
import 'complete_profile_screen.dart';
import '../login/login_screen.dart';
import '../../user/services/user_local_storage.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> with WidgetsBindingObserver {
  bool positive = false;
  bool _loadingNotifPermission = true;

  List accountArr = [
    {"image": "assets/icons/p_activity.png", "name": "Lịch sử tập luyện", "tag": "3"},
    {"image": "assets/icons/p_workout.png", "name": "Tiến trình tập luyện", "tag": "4"}
  ];

  // 🔹 HÀM TÍNH TUỔI
  int? _calculateAge(String? dobStr) {
    if (dobStr == null || dobStr.trim().isEmpty) return null;

    DateTime? dob = DateTime.tryParse(dobStr.trim());

    if (dob == null) {
      final regex = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
      final match = regex.firstMatch(dobStr.trim());
      if (match != null) {
        final d = int.tryParse(match.group(1)!);
        final m = int.tryParse(match.group(2)!);
        final y = int.tryParse(match.group(3)!);
        if (d != null && m != null && y != null) {
          dob = DateTime(y, m, d);
        }
      }
    }

    if (dob == null) return null;

    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  // ✅ check quyền notification của hệ điều hành
  Future<void> _refreshNotificationPermission() async {
    setState(() => _loadingNotifPermission = true);

    // permission_handler dùng Permission.notification cho iOS + Android 13+
    final status = await Permission.notification.status;
    final enabled = status.isGranted;

    if (!mounted) return;
    setState(() {
      positive = enabled;
      _loadingNotifPermission = false;
    });
  }

  Future<void> _onToggleNotificationPermission(bool desired) async {
    if (desired) {
      final req = await Permission.notification.request();
      if (req.isGranted) {
        await _refreshNotificationPermission();
        return;
      }
      await openAppSettings();
      return;
    }


    await openAppSettings();
  }

  // 🔹 HÀM ĐĂNG XUẤT
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await UserLocalStorage.clearUser();

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        LoginScreen.routeName,
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshNotificationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ✅ khi user từ Settings quay lại app, refresh lại trạng thái permission
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshNotificationPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    String _goalKeyFromTitle(String title) {
      switch (title) {
        case 'improve_shape':
          return 'Cải thiện hình dáng';
        case 'lean_tone':
          return 'Thon gọn & săn chắc';
        case 'lose_fat':
          return 'Giảm cân';
        default:
          return '(chưa rõ)';
      }
    }

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          backgroundColor: AppColors.whiteColor,
          centerTitle: true,
          elevation: 0,
          title: const Text(
            "Tài khoản",
            style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: const Center(child: Text("No user logged in")),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.whiteColor,
            appBar: AppBar(
              backgroundColor: AppColors.whiteColor,
              centerTitle: true,
              elevation: 0,
              title: const Text(
                "Tài khoản",
                style: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.whiteColor,
            appBar: AppBar(
              backgroundColor: AppColors.whiteColor,
              centerTitle: true,
              elevation: 0,
              title: const Text(
                "Tải khoản",
                style: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: Center(
              child: Text(
                'Error loading profile: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: AppColors.whiteColor,
            appBar: AppBar(
              backgroundColor: AppColors.whiteColor,
              centerTitle: true,
              elevation: 0,
              title: const Text(
                "Tài khoản",
                style: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: const Center(child: Text('User profile not found')),
          );
        }

        final data = snapshot.data!.data()!;
        final firstName = (data['firstName'] ?? '').toString();
        final lastName = (data['lastName'] ?? '').toString();
        final displayName = (data['displayName'] ?? 'Username').toString();
        final fullName = (firstName + ' ' + lastName).trim().isEmpty ? displayName : (firstName + ' ' + lastName).trim();

        final goal = (data['goal'] ?? '').toString();
        final programConvert = _goalKeyFromTitle(goal);
        final programText = 'Mục tiêu $programConvert';

        final heightStr = data['height']?.toString();
        final weightStr = data['weight']?.toString();
        final dobStr = data['dob']?.toString();

        final heightDisplay = (heightStr == null || heightStr.isEmpty) ? '--' : '${heightStr}cm';
        final weightDisplay = (weightStr == null || weightStr.isEmpty) ? '--' : '${weightStr}kg';

        final age = _calculateAge(dobStr);
        final ageDisplay = age == null ? '--' : '$age';

        return Scaffold(
          backgroundColor: AppColors.whiteColor,
          appBar: AppBar(
            backgroundColor: AppColors.whiteColor,
            centerTitle: true,
            elevation: 0,
            title: const Text(
              "Tài khoản",
              style: TextStyle(
                color: AppColors.blackColor,
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
                    width: 12,
                    height: 12,
                    fit: BoxFit.contain,
                  ),
                ),
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          "assets/images/user.png",
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              style: const TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              programText,
                              style: const TextStyle(
                                color: AppColors.grayColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        height: 25,
                        child: RoundButton(
                          title: "Sửa",
                          type: RoundButtonType.primaryBG,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Height / Weight / Age
                  Row(
                    children: [
                      Expanded(child: TitleSubtitleCell(title: heightDisplay, subtitle: "Chiều cao")),
                      const SizedBox(width: 15),
                      Expanded(child: TitleSubtitleCell(title: weightDisplay, subtitle: "Cân nặng")),
                      const SizedBox(width: 15),
                      Expanded(child: TitleSubtitleCell(title: ageDisplay, subtitle: "Tuổi")),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Account
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Tài khoản",
                          style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: accountArr.length,
                          itemBuilder: (context, index) {
                            var iObj = accountArr[index] as Map? ?? {};
                            return SettingRow(
                              icon: iObj["image"].toString(),
                              title: iObj["name"].toString(),
                              onPressed: () {
                                final tag = iObj["tag"].toString();
                                if (tag == "4") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const WorkoutProgressPlanScreen()),
                                  );
                                } else if (tag == "3") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ActivityHistoryScreen()),
                                  );
                                }
                              },
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // ✅ Notification Permission
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Thông báo",
                          style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 30,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/icons/p_notification.png",
                                height: 15,
                                width: 15,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 15),
                              const Expanded(
                                child: Text(
                                  "Bật thông báo",
                                  style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (_loadingNotifPermission)
                                const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              else
                                CustomAnimatedToggleSwitch<bool>(
                                  current: positive,
                                  values: const [false, true],
                                  dif: 0.0,
                                  indicatorSize: const Size.square(30.0),
                                  animationDuration: const Duration(milliseconds: 200),
                                  animationCurve: Curves.linear,
                                  onChanged: (b) async {
                                    // ❗ không setState ngay, vì quyền phải do hệ thống quyết định
                                    await _onToggleNotificationPermission(b);
                                  },
                                  iconBuilder: (context, local, global) => const SizedBox(),
                                  defaultCursor: SystemMouseCursors.click,
                                  onTap: () async => await _onToggleNotificationPermission(!positive),
                                  iconsTappable: false,
                                  wrapperBuilder: (context, global, child) {
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Positioned(
                                          left: 10.0,
                                          right: 10.0,
                                          height: 30.0,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(colors: AppColors.secondaryG),
                                              borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                                            ),
                                          ),
                                        ),
                                        child,
                                      ],
                                    );
                                  },
                                  foregroundIndicatorBuilder: (context, global) {
                                    return SizedBox.fromSize(
                                      size: const Size(10, 10),
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: AppColors.whiteColor,
                                          borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black38,
                                              spreadRadius: 0.05,
                                              blurRadius: 1.1,
                                              offset: Offset(0.0, 0.8),
                                            ),
                                          ],
                                        ),
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
                  const SizedBox(height: 25),

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: RoundButton(
                      title: "Đăng xuất",
                      type: RoundButtonType.primaryBG,
                      onPressed: _logout,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
