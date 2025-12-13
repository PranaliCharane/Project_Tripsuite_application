
import 'package:flutter/material.dart';
import 'package:tripsuite_app_boilerplate/features/onboarding/screens/onboarding_screen1.dart';



class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key});


  @override

  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>{

  @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen1()),
      );
    });
  });
}

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Image.asset("assets/images/splash_screen_logo.png",
        height: 200,
        width: 200,
        ),
      ),
    );
  }
}
