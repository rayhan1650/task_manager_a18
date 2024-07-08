import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:task_manager_app/data/models/network_response.dart';
import 'package:task_manager_app/data/network_caller/network_caller.dart';
import 'package:task_manager_app/data/utilities/api_urls.dart';
import 'package:task_manager_app/ui/utility/strings.dart';
import 'package:task_manager_app/ui/widgets/background_widget.dart';
import 'package:task_manager_app/ui/widgets/snack_bar_message.dart';
import '../../utility/colors.dart';
import '../../widgets/custom_textformfield.dart';
import '../../widgets/title_large_text_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailTEController = TextEditingController();
  final TextEditingController _passwordTEController = TextEditingController();
  final TextEditingController _firstNameTEController = TextEditingController();
  final TextEditingController _lastNameTEController = TextEditingController();
  final TextEditingController _mobileNumberTEController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _showPassword = true;
  bool _registrationInProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: SingleChildScrollView(
              child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    const TitleLargeText(titleLarge: signUpScreenTitle),
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
                      controller: _firstNameTEController,
                      hintText: 'First Name',
                      validatorErrorText: 'Enter Your First Name',
                    ),
                    const SizedBox(height: 8),
                    CustomTextFormField(
                      controller: _lastNameTEController,
                      hintText: 'Last Name',
                      validatorErrorText: 'Enter Your Last Name',
                    ),
                    const SizedBox(height: 8),
                    CustomTextFormField(
                      controller: _mobileNumberTEController,
                      keyBoardType: TextInputType.number,
                      hintText: 'Mobile',
                      validatorErrorText: 'Enter Your Mobile',
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
                      visible: _registrationInProgress == false,
                      replacement: const Center(child: CircularProgressIndicator()),
                      child: ElevatedButton(
                        onPressed: _registerUser,
                        child: const Icon(Icons.arrow_circle_right_outlined),
                      ),
                    ),
                    const SizedBox(height: 36),
                    Center(
                      child: RichText(
                        text: TextSpan(
                            style: TextStyle(
                                color: AppColors.blackColor.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4),
                            text: "Have account? ",
                            children: [
                              TextSpan(
                                  text: 'Sign in',
                                  style: const TextStyle(
                                      color: AppColors.themeColor),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = _onTapSignInButton),
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
        ),
      ),
    );
  }

  void _registerUser() async {
    if(_formKey.currentState!.validate()){
      _registrationInProgress = true;
      if (mounted) {
        setState(() {});
      }

      Map<String, dynamic> requestUserRegistration = {
        "email" : _emailTEController.text.trim(),
        "firstName" : _firstNameTEController.text.trim(),
        "lastName" : _lastNameTEController.text.trim(),
        "mobile" : _mobileNumberTEController.text.trim(),
        "password" : _passwordTEController.text,
        "photo" : ""
      };

      NetworkResponse response = await NetworkCaller.postRequest(ApiUrls.registration, body: requestUserRegistration);

      _registrationInProgress = false;
      if (mounted) {
        setState(() {});
      }

      if (response.isSuccess){
        _clearTextField();
        if(mounted){
          showSnackBarMessage(context, 'Registration Success');
        }
      } else {
        if(mounted){
          showSnackBarMessage(context, response.errorMessage ?? 'Registration failed! Try again');
        }
      }
    }
  }

  void _onTapSignInButton() {
    Navigator.pop(context);
  }

  void _clearTextField(){
    _emailTEController.clear();
    _firstNameTEController.clear();
    _lastNameTEController.clear();
    _mobileNumberTEController.clear();
    _passwordTEController.clear();
  }

  @override
  void dispose() {
    super.dispose();
    _emailTEController.dispose();
    _firstNameTEController.dispose();
    _lastNameTEController.dispose();
    _mobileNumberTEController.dispose();
    _passwordTEController.dispose();
  }
}
