import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitnessapp/routes.dart';
import 'package:fitnessapp/services/notification_service.dart';
import 'package:fitnessapp/user/models/app_user.dart';
import 'package:fitnessapp/user/services/user_local_storage.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/dashboard/dashboard_screen.dart';
import 'package:fitnessapp/view/login/login_screen.dart';
import 'package:fitnessapp/view/profile/complete_profile_screen.dart';
import 'package:fitnessapp/view/welcome/welcome_screen.dart';
import 'package:fitnessapp/view/your_goal/your_goal_screen.dart';
import 'package:fitnessapp/workouts/services/exercise_bootstrapper.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ExerciseBootstrapper.ensureSeeded();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();
  await NotificationService.requestNotificationPermission();
  await _requestMediaPermissions();


  runApp(const MyApp());
}
Future<void> _requestMediaPermissions() async {
  try {
    // Xin quyền ảnh
    if (Platform.isIOS) {
      final st = await Permission.photos.request();
      if (!(st.isGranted || st.isLimited)) {
      }
    } else {
      final st = await Permission.photos.request();
      if (!st.isGranted) {
      }
    }

    final cam = await Permission.camera.request();
    if (!cam.isGranted) {
    }
  } catch (_) {
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness',
      debugShowCheckedModeBanner: false,
      routes: routes,
      theme: ThemeData(
        primaryColor: AppColors.primaryColor1,
        useMaterial3: true,
        fontFamily: "Poppins"
      ),
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;

        if (user == null) {
          // chưa login
          return const LoginScreen();
        }

        // ĐÃ LOGIN → ưu tiên đọc local user trước
        return FutureBuilder<AppUser?>(
          future: UserLocalStorage.getUser(),
          builder: (context, localSnapshot) {
            if (localSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            AppUser? localUser = localSnapshot.data;

            if (localUser != null && localUser.uid == user.uid) {
              // 🔥 ĐÃ CÓ USER LOCAL → quyết định luôn
              if (localUser.isProfileCompleted) {
                return const DashboardScreen();
              } else {
                return const CompleteProfileScreen();
              }
            }

            // ❗ Chưa có user local → fallback đọc Firestore 1 lần
            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (userSnapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Text(
                        'Error loading user data: ${userSnapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const CompleteProfileScreen();
                }

                final data = userSnapshot.data!.data() ?? {};
                data['uid'] = user.uid;
                data['email'] = user.email;

                final appUser = AppUser.fromJson(data);

                // Lưu xuống local để những lần sau dùng luôn
                UserLocalStorage.saveUser(appUser);

                if (appUser.isProfileCompleted) {
                  return const DashboardScreen();
                } else {
                  return const CompleteProfileScreen();
                }
              },
            );
          },
        );
      },
    );
  }
}
