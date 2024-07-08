import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:task_manager_app/ui/screens/auth/pin_verification_screen.dart';
import 'package:task_manager_app/ui/utility/colors.dart';
import 'package:task_manager_app/ui/utility/strings.dart';
import 'package:task_manager_app/ui/widgets/background_widget.dart';
import 'package:task_manager_app/ui/widgets/custom_progress_indicator.dart';
import '../../../data/models/network_response.dart';
import '../../../data/network_caller/network_caller.dart';
import '../../../data/utilities/api_urls.dart';
import '../../widgets/snack_bar_message.dart';
import '../../widgets/title_large_text_widget.dart';
import '../../widgets/custom_textformfield.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _emailTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _emailVrificationInprogress = false;
  String? email;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 100),
                    const TitleLargeText(titleLarge: emailVerificationScreenTitle),
                    const SizedBox(height: 6),
                    Text(emailVerificationScreenSubTitle,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(controller: _emailTEController,
                      hintText: 'Email',
                      keyBoardType: TextInputType.emailAddress,
                      validatorErrorText: 'Enter Your Email',
                      regExpErrorText: 'Enter a valid email address',
                      isRegExpValidation: true,
                    ),
                    const SizedBox(height: 16),
                    Visibility(
                      visible: _emailVrificationInprogress == false,
                      replacement: const CustomProgressIndicator(),
                      child: ElevatedButton(
                        onPressed: _onTapConfirmButton,
                          child: const Icon(Icons.arrow_circle_right_outlined),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: RichText(text: TextSpan(
                        style: TextStyle(
                          color: AppColors.blackColor.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4
                        ),
                        text: "Have account? ",
                        children: [
                          TextSpan(
                            text: 'Sign in',
                            style: const TextStyle(color: AppColors.themeColor),
                            recognizer: TapGestureRecognizer()..onTap = _onTapSignInButton
                          ),
                        ]
                      ),
                      ),
                    ),

                  ],
                ),
              ),
            )
        ),
      ),
    );
  }

  void _onTapConfirmButton() async {
    if (_formKey.currentState!.validate()) {
      _onConfirmVerifyEmail();
    }
  }

  void _onTapSignInButton(){
    Navigator.pop(context);
  }

  Future<void> _onConfirmVerifyEmail() async {

      _emailVrificationInprogress = true;
      if (mounted) {
        setState(() {});
      }

      email = _emailTEController.text.trim();
      NetworkResponse response = await NetworkCaller.getRequest(
          ApiUrls.recoverVerifyEmail(email!));

      _emailVrificationInprogress = false;
      if (mounted) {
        setState(() {});
      }
      if (response.isSuccess && response.responseData['status'] == 'success') {
        if (mounted) {
          showSnackBarMessage(
            context,
            'Email verification link sent! Please check your mail.',
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>  PinVerificationScreen(email: email!),
            ),
          );
        }
      } else {
        if (mounted) {
          showSnackBarMessage(
            context,
            response.errorMessage ?? 'Email verification failed! Try again',
          );
        }
      }
    }

  @override
  void dispose() {
    super.dispose();
    _emailTEController.dispose();
  }
}


