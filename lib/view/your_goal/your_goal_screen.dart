import 'package:carousel_slider/carousel_slider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/welcome/welcome_screen.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../user/services/user_local_storage.dart';
import 'goal_duration_screen.dart';

class YourGoalScreen extends StatefulWidget {
  static String routeName = "/YourGoalScreen";

  const YourGoalScreen({Key? key}) : super(key: key);

  @override
  State<YourGoalScreen> createState() => _YourGoalScreenState();
}

class _YourGoalScreenState extends State<YourGoalScreen> {
  List<Map<String, String>> pageList = [
    {
      "title": "Cải thiện hình dáng",
      "subtitle":
      "Tôi có lượng mỡ cơ thể thấp và muốn tăng thêm cơ bắp",
      "image": "assets/images/goal_1.png"
    },
    {
      "title": "Thon gọn & săn chắc",
      "subtitle":
      "Tôi trông gầy nhưng không có vóc dáng.Tôi muốn bổ sung thêm cơ bắp theo đúng cách.",
      "image": "assets/images/goal_2.png"
    },
    {
      "title": "Giảm cân",
      "subtitle":
      "Tôi cần giảm hơn 20 pound. Tôi muốn giảm hết mỡ thừa và tăng cơ.",
      "image": "assets/images/goal_3.png"
    }
  ];

  CarouselSliderController carouselController = CarouselSliderController();
  int _currentIndex = 0;

  String _goalKeyFromTitle(String title) {
    switch (title) {
      case 'Cải thiện hình dáng':
        return 'improve_shape';
      case 'Thon gọn & săn chắc':
        return 'lean_tone';
      case 'Giảm cân':
        return 'lose_fat';
      default:
        return 'unknown';
    }
  }


  Future<void> _saveGoalAndGoWelcome() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Người dùng chưa đăng nhập')),
      );
      return;
    }

    final selectedGoal = _goalKeyFromTitle(pageList[_currentIndex]["title"]!);

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'goal': selectedGoal,
    });
    final local = await UserLocalStorage.getUser();
    if (local != null) {
      final updated = local.copyWith(goal: selectedGoal);
      await UserLocalStorage.saveUser(updated);
    }
    Navigator.pushNamed(
      context,
      GoalDurationScreen.routeName,
      arguments: selectedGoal, // truyền goal sang
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: CarouselSlider(
                items: pageList
                    .map((obj) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                        colors: AppColors.primaryG,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                  ),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(
                      vertical: media.width * 0.01, horizontal: 25),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          obj["image"]!,
                          width: media.width * 0.5,
                          fit: BoxFit.fitWidth,
                        ),
                        SizedBox(height: media.width * 0.02),
                        Text(
                          obj["title"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: media.width * 0.01),
                        Container(
                          width: 50,
                          height: 1,
                          color: AppColors.lightGrayColor,
                        ),
                        SizedBox(height: media.width * 0.02),
                        Text(
                          obj["subtitle"]!,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 3,
                          style: const TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 12,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
                    .toList(),
                carouselController: carouselController,
                options: CarouselOptions(
                  autoPlay: false,
                  enlargeCenterPage: true,
                  viewportFraction: 0.7,
                  aspectRatio: 0.74,
                  initialPage: 0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SizedBox(
                width: media.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      "Mục tiêu của bạn là gì ?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Nó sẽ giúp chúng tôi chọn chương trình \n tốt nhất cho bạn",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.grayColor,
                        fontSize: 12,
                        fontFamily: "Poppins",
                      ),
                    ),
                    const Spacer(),
                    SizedBox(height: media.width * 0.05),
                    RoundGradientButton(
                      title: "Xác nhận",
                      onPressed: _saveGoalAndGoWelcome,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
