import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/your_goal/your_goal_screen.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';



import '../../user/models/app_user.dart';
import '../../user/services/user_local_storage.dart';

class CompleteProfileScreen extends StatefulWidget {
  static String routeName = "/CompleteProfileScreen";
  const CompleteProfileScreen({Key? key}) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  String? _selectedGender;
  final _displayNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadLocalUser();
  }

  Future<void> _loadLocalUser() async {
    final localUser = await UserLocalStorage.getUser();
    if (!mounted || localUser == null) return;
    setState(() {
      if ((localUser.gender ?? '').isNotEmpty) {
        _selectedGender = localUser.gender;
      }
      if ((localUser.dob ?? '').isNotEmpty) {
        _dobController.text = localUser.dob!;
      }
      if ((localUser.weight ?? '').isNotEmpty) {
        _weightController.text = localUser.weight!;
      }
      if ((localUser.height ?? '').isNotEmpty) {
        _heightController.text = localUser.height!;
      }
      if ((localUser.firstName ?? '').isNotEmpty) {
        _displayNameController.text = '${localUser.firstName} ${localUser.lastName}';
      } else if ((localUser.displayName ?? '').isNotEmpty) {
        _displayNameController.text = localUser.displayName!;
      }
    });
  }

  @override
  void dispose() {
    _dobController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final gender = _selectedGender ?? '';
    final dob = _dobController.text.trim();
    final weight = _weightController.text.trim();
    final height = _heightController.text.trim();
    final displayName = _displayNameController.text.trim();


    if (gender.isEmpty || dob.isEmpty || weight.isEmpty || height.isEmpty || displayName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'gender': gender,
          'dob': dob,
          'weight': weight,
          'height': height,
          'displayName': displayName,
        },
        SetOptions(merge: true),
      );

      final currentLocal = await UserLocalStorage.getUser();

      AppUser baseUser;
      if (currentLocal != null) {
        baseUser = currentLocal;
      } else {
        final email = user.email ?? '';
        String? firstName;
        String? lastName;
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          final parts = user.displayName!.trim().split(' ');
          firstName = parts.first;
          if (parts.length > 1) {
            lastName = parts.sublist(1).join(' ');
          }
        }
        baseUser = AppUser(
          uid: user.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          displayName: displayName,
        );
      }

      final updatedUser = baseUser.copyWith(
        gender: gender,
        dob: dob,
        weight: weight,
        height: height,
        displayName: displayName,
      );

      await UserLocalStorage.saveUser(updatedUser);

      if (!mounted) return;

      Navigator.pushNamed(context, YourGoalScreen.routeName);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 15, left: 15),
            child: Column(
              children: [
                Image.asset(
                  "assets/images/complete_profile.png",
                  width: media.width,
                ),
                const SizedBox(height: 15),
                Text(
                  "Hãy hoàn thiện hồ sơ của bạn",
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Nó sẽ giúp chúng tôi hiểu rõ hơn về bạn!",
                  style: TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 12,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 25),

                // Gender
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightGrayColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Image.asset(
                          "assets/icons/gender_icon.png",
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                          color: AppColors.grayColor,
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedGender,
                            items: ["Nam", "Nữ"]
                                .map(
                                  (name) => DropdownMenuItem(
                                value: name,
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    color: AppColors.grayColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
                            isExpanded: true,
                            hint: const Text(
                              "Giới tính",
                              style: TextStyle(
                                color: AppColors.grayColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  hintText: "Fullname",
                  icon: "assets/icons/profile_icon.png",
                  textInputType: TextInputType.text,
                  textEditingController: _displayNameController,
                ),
                const SizedBox(height: 15),
                // DOB
                RoundTextField(
                  hintText: "Ngày sinh (dd/mm/yyyy)",
                  icon: "assets/icons/calendar_icon.png",
                  textInputType: TextInputType.text,
                  textEditingController: _dobController,
                ),
                const SizedBox(height: 15),

                // Weight
                RoundTextField(
                  hintText: "Cân nặng",
                  icon: "assets/icons/weight_icon.png",
                  textInputType: TextInputType.number,
                  textEditingController: _weightController,
                ),
                const SizedBox(height: 15),

                // Height
                RoundTextField(
                  hintText: "Chiều cao",
                  icon: "assets/icons/swap_icon.png",
                  textInputType: TextInputType.number,
                  textEditingController: _heightController,
                ),
                const SizedBox(height: 15),

                RoundGradientButton(
                  title: _isSaving ? "Đang lưu..." : "Tiếp >",
                  onPressed: _isSaving ? null : _saveProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
