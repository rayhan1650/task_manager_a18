import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:task_manager_app/ui/screens/auth/reset_password_screen.dart';
import 'package:task_manager_app/ui/utility/colors.dart';
import 'package:task_manager_app/ui/utility/strings.dart';
import 'package:task_manager_app/ui/widgets/background_widget.dart';
import 'package:task_manager_app/ui/widgets/custom_progress_indicator.dart';
import '../../../data/models/network_response.dart';
import '../../../data/network_caller/network_caller.dart';
import '../../../data/utilities/api_urls.dart';
import '../../widgets/snack_bar_message.dart';
import '../../widgets/title_large_text_widget.dart';
import 'sign_in_screen.dart';

class PinVerificationScreen extends StatefulWidget {
  const PinVerificationScreen({super.key, required this.email});

  final String email;

  @override
  State<PinVerificationScreen> createState() => _PinVerificationScreenState();
}

class _PinVerificationScreenState extends State<PinVerificationScreen> {
  final TextEditingController _pinTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _pinVrificationInprogress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              const TitleLargeText(titleLarge: pinVerificationScreenTitle),
              const SizedBox(height: 6),
              Text(pinVerificationScreenSubTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 16),
                PinCodeTextField(
                  length: 6,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: Colors.white,
                    selectedFillColor: Colors.white,
                    inactiveFillColor: Colors.white,
                    selectedColor: AppColors.themeColor,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  backgroundColor: Colors.transparent,
                  keyboardType: TextInputType.number,
                  enableActiveFill: true,
                  controller: _pinTEController,
                  appContext: context,
                ),
              const SizedBox(height: 16),
              Visibility(
                visible: _pinVrificationInprogress == false,
                replacement: const CustomProgressIndicator(),
                child: ElevatedButton(
                  onPressed: _onTapVarifyButton,
                  child: const Icon(Icons.arrow_circle_right_outlined),
                ),
              ),
              const SizedBox(height: 40),
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
                            style: const TextStyle(color: AppColors.themeColor),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _onTapSignInButton),
                      ]),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }

  void _onTapSignInButton() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const SignInScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> _onTapVarifyButton() async {
    final String recoveryEmail = widget.email;

    _pinVrificationInprogress = true;
    if (mounted) {
      setState(() {});
    }
    String pinCode = _pinTEController.text.trim();
    NetworkResponse response = await NetworkCaller.getRequest(
        ApiUrls.recoverVerifyOTP(recoveryEmail, pinCode));

    _pinVrificationInprogress = false;
    if (mounted) {
      setState(() {});
    }
    if (response.isSuccess && response.responseData['status'] == 'success') {
      if (mounted) {
        showSnackBarMessage(
          context,
          'Pin verification Successful!',
        );
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ResetPasswordScreen(email: recoveryEmail, oTP: pinCode,)));
      }
    } else {
      if (mounted) {
        showSnackBarMessage(
          context, 'Pin verification failed! Try again',
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _pinTEController.dispose();
  }
}
