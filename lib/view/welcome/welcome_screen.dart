import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/dashboard/dashboard_screen.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../user/services/user_local_storage.dart';
import '../../user/models/app_user.dart';

class WelcomeScreen extends StatefulWidget {
  static String routeName = "/WelcomeScreen";

  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _displayName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final AppUser? localUser = await UserLocalStorage.getUser();

    String name = '';

    if (localUser != null) {
      final first = (localUser.firstName ?? '').trim();
      final last = (localUser.lastName ?? '').trim();
      final displayname = localUser.displayName?.trim();
      if (first.isNotEmpty || last.isNotEmpty) {
        name = displayname ?? [first, last].where((e) => e.isNotEmpty).join(' ');
      }
    }

    if (name.isEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if ((user.displayName ?? '').trim().isNotEmpty) {
          name = user.displayName!.trim();
        } else if ((user.email ?? '').isNotEmpty) {
          name = user.email!.split('@').first;
        }
      }
    }

    // 3. Fallback cuối cùng
    if (name.isEmpty) {
      name = 'bạn';
    }

    if (!mounted) return;
    setState(() {
      _displayName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset(
                "assets/images/welcome_promo.png",
                width: media.width * 0.75,
                fit: BoxFit.fitWidth,
              ),
              SizedBox(height: media.width * 0.05),
              Text(
                "Xin chào, ${_displayName.isEmpty ? '...' : _displayName}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: media.width * 0.01),
              const Text(
                "Bạn đã sẵn sàng rồi, hãy cùng chúng tôi\n đạt được mục tiêu của bạn",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 12,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              RoundGradientButton(
                title: "Đi đến Trang chủ",
                onPressed: () {
                  Navigator.pushNamed(context, DashboardScreen.routeName);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
