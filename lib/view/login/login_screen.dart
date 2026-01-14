import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/signup/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';
import '../../user/models/app_user.dart';
import '../../user/services/user_local_storage.dart';
import '../profile/complete_profile_screen.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = "/LoginScreen";
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _setupGoogleSignIn();
  }
  Future<void> _setupGoogleSignIn() async {
    await GoogleSignIn.instance.initialize(
      serverClientId: '432562946797-fn46mijpn5v2aa537gk5kv732irt82qa.apps.googleusercontent.com',
    );
  }
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _afterLogin(User user) async {
    final docRef =
    FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    final doc2 = await docRef.get();
    final data = doc2.data() ?? {};
    data['uid'] = user.uid;
    data['email'] = user.email;

    final appUser = AppUser.fromJson(data);
    await UserLocalStorage.saveUser(appUser);
    _showSnack('Login success');
    Navigator.pushNamed(context, CompleteProfileScreen.routeName);
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack('Please enter email and password');
      return;
    }

    if (_loading) return;
    setState(() => _loading = true);

    try {
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = cred.user;
      if (user == null) {
        _showSnack('Login failed: user is null');
        return;
      }

      await _afterLogin(user);
    } on FirebaseAuthException catch (e) {
      debugPrint('LOGIN ERROR: code=${e.code}, msg=${e.message}');

      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Email chưa đăng ký.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-login-credentials':
          message = 'Email hoặc mật khẩu không đúng.';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ.';
          break;
        case 'user-disabled':
          message = 'Tài khoản đã bị vô hiệu hoá.';
          break;
        case 'too-many-requests':
          message = 'Thử lại sau (quá nhiều lần đăng nhập).';
          break;
        case 'network-request-failed':
          message = 'Lỗi mạng. Kiểm tra Internet.';
          break;
        default:
          message = 'Login failed: ${e.message ?? e.code}';
      }
      _showSnack(message);
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final GoogleSignInAccount googleAccount = await GoogleSignIn.instance.authenticate();
      final GoogleSignInAuthentication googleAuth = googleAccount.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCred.user;
      if (user == null) {
        _showSnack('Google login failed: user is null');
        return;
      }

      await _afterLogin(user);
    } on FirebaseAuthException catch (e) {
      _showSnack('Google login failed: ${e.code}');
    } catch (e) {
      print(e);
      _showSnack('Google login error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginWithFacebook() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      // Trigger Facebook sign-in flow :contentReference[oaicite:3]{index=3}
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: const ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success ||
          result.accessToken == null) {
        _showSnack('Facebook login cancelled/failed');
        return;
      }

      final OAuthCredential facebookCredential =
      FacebookAuthProvider.credential(result.accessToken!.tokenString);

      final userCred = await FirebaseAuth.instance
          .signInWithCredential(facebookCredential);

      final user = userCred.user;
      if (user == null) {
        _showSnack('Facebook login failed: user is null');
        return;
      }

      await _afterLogin(user);
    } on FirebaseAuthException catch (e) {
      _showSnack('Facebook login failed: ${e.code}');
    } catch (e) {
      print(e);
      _showSnack('Facebook login error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            children: [
              SizedBox(
                width: media.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: media.width * 0.03),
                    const Text(
                      "Này,",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: media.width * 0.01),
                    const Text(
                      "Chào mừng quay trở lại",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 20,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: media.width * 0.05),
              RoundTextField(
                hintText: "Email",
                icon: "assets/icons/message_icon.png",
                textInputType: TextInputType.emailAddress,
                textEditingController: _emailController,
              ),
              SizedBox(height: media.width * 0.05),
              RoundTextField(
                hintText: "Password",
                icon: "assets/icons/lock_icon.png",
                textInputType: TextInputType.text,
                isObscureText: true,
                textEditingController: _passwordController,
                rightIcon: TextButton(
                  onPressed: () {},
                  child: Container(
                    alignment: Alignment.center,
                    width: 20,
                    height: 20,
                    child: Image.asset(
                      "assets/icons/hide_pwd_icon.png",
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      color: AppColors.grayColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: media.width * 0.03),
              const Text(
                "Quên mật khẩu?",
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 10,
                ),
              ),
              const Spacer(),
              RoundGradientButton(
                title: _loading ? "Đăng nhập..." : "Đăng nhập",
                onPressed: _loading ? null : _login,
              ),
              SizedBox(height: media.width * 0.01),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      height: 1,
                      color: AppColors.grayColor.withOpacity(0.5),
                    ),
                  ),
                  const Text(
                    "  Or  ",
                    style: TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      height: 1,
                      color: AppColors.grayColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _loading ? null : _loginWithGoogle,
                    child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primaryColor1.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Image.asset(
                        "assets/icons/google_icon.png",
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                  // const SizedBox(width: 30),
                  // GestureDetector(
                  //   onTap: _loading ? null : _loginWithFacebook,
                  //   child: Container(
                  //     width: 50,
                  //     height: 50,
                  //     alignment: Alignment.center,
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(14),
                  //       border: Border.all(
                  //         color: AppColors.primaryColor1.withOpacity(0.5),
                  //         width: 1,
                  //       ),
                  //     ),
                  //     child: Image.asset(
                  //       "assets/icons/facebook_icon.png",
                  //       width: 20,
                  //       height: 20,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, SignupScreen.routeName);
                },
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(text: "Nếu chưa có tài khoản? "),
                      TextSpan(
                        text: "Đăng ký",
                        style: TextStyle(
                          color: AppColors.secondaryColor1,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
