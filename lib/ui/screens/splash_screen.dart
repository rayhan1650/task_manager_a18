import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:task_manager_app/ui/controller/auth_controller.dart';
import 'package:task_manager_app/ui/screens/auth/sign_in_screen.dart';
import 'package:task_manager_app/ui/screens/main_bottom_nav_screen.dart';
import 'package:task_manager_app/ui/utility/asset_path.dart';
import 'package:task_manager_app/ui/widgets/background_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadNextScreen();
  }
  
  Future<void> _loadNextScreen()async{
   await Future.delayed(const Duration(seconds: 2));
   bool isUserLoggedIn = await AuthController.checkAuthState();
   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => isUserLoggedIn ? const MainBottomNavScreen() : const SignInScreen(),),);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BackgroundWidget(
          child: Center(
            child: SvgPicture.asset(AssetPath.appLogoSVG,
            ),
          ),),
      ),

    );
  }
}
