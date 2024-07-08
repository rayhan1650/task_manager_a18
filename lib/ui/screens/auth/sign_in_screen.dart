import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:task_manager_app/data/models/login_model.dart';
import 'package:task_manager_app/data/models/network_response.dart';
import 'package:task_manager_app/data/network_caller/network_caller.dart';
import 'package:task_manager_app/data/utilities/api_urls.dart';
import 'package:task_manager_app/ui/controller/auth_controller.dart';
import 'package:task_manager_app/ui/screens/auth/email_verification_screen.dart';
import 'package:task_manager_app/ui/screens/main_bottom_nav_screen.dart';
import 'package:task_manager_app/ui/utility/colors.dart';
import 'package:task_manager_app/ui/utility/strings.dart';
import 'package:task_manager_app/ui/widgets/background_widget.dart';
import 'package:task_manager_app/ui/widgets/snack_bar_message.dart';
import '../../widgets/title_large_text_widget.dart';
import '../../widgets/custom_textformfield.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailTEController = TextEditingController();
  final TextEditingController _passwordTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _showPassword = true;
  bool _signInApiInProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                const TitleLargeText(titleLarge: signInScreenTitle),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: _emailTEController,
                  hintText: 'Email',
                  keyBoardType: TextInputType.emailAddress,
                  validatorErrorText: 'Enter Your Email',
                  regExpErrorText: 'Enter a valid email address',
                  isRegExpValidation: true,
                ),
                const SizedBox(height: 8),
                CustomTextFormField(
                  controller: _passwordTEController,
                  hintText: 'Password',
                  icon: IconButton(
                    onPressed: () {
                      _showPassword = !_showPassword;
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    icon: _showPassword
                        ? const Icon(Icons.visibility_off)
                        : const Icon(Icons.visibility),
                  ),
                  validatorErrorText: 'Enter Your Password',
                  obscureText: _showPassword,
                ),
                const SizedBox(height: 16),
                Visibility(
                  visible: _signInApiInProgress == false,
                  replacement: const Center(child: CircularProgressIndicator()),
                  child: ElevatedButton(
                    onPressed: _onTapSignInButton,
                    child: const Icon(Icons.arrow_circle_right_outlined),
                  ),
                ),
                const SizedBox(height: 35),
                Center(
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: _onTapForgotPasswordButton,
                        child: const Text('Forgot password'),
                      ),
                      RichText(
                        text: TextSpan(
                            style: TextStyle(
                                color: AppColors.blackColor.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4),
                            text: "Don't have an account? ",
                            children: [
                              TextSpan(
                                  text: 'Sign up',
                                  style: const TextStyle(
                                      color: AppColors.themeColor),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = _onTapSignUpButton),
                            ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }

  void _onTapSignInButton() async {
    if (_formKey.currentState!.validate()) {
      _signIn();
    }
  }

  Future<void> _signIn() async {
    _signInApiInProgress = true;
    if (mounted) {
      setState(() {});
    }
    Map<String, dynamic> logInDtata = {
      'email': _emailTEController.text.trim(),
      'password': _passwordTEController.text,
    };
    final NetworkResponse response =
        await NetworkCaller.postRequest(ApiUrls.logIn, body: logInDtata);
    _signInApiInProgress = false;
    if (mounted) {
      setState(() {});
    }
    if (response.isSuccess) {
      LoginModel loginModel = LoginModel.fromJson(response.responseData);
      await AuthController.saveUserAccessToken(loginModel.token!);
      await AuthController.saveUserData(loginModel.userModel!);
      if(mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainBottomNavScreen(),
          ),
        );
      }
    } else {
      if (mounted) {
        showSnackBarMessage(context,
            response.errorMessage ?? 'Incorrect Email or Password! Try Again');
      }
    }
  }

  void _onTapForgotPasswordButton() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const EmailVerificationScreen()));
  }

  void _onTapSignUpButton() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
  }

  @override
  void dispose() {
    super.dispose();
    _emailTEController.dispose();
    _passwordTEController.dispose();
  }
}
