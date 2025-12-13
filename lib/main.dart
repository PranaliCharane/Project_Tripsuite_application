import 'package:flutter/material.dart';
import 'package:tripsuite_app_boilerplate/features/auth/login_screen.dart';
import 'package:tripsuite_app_boilerplate/features/auth/signup_screen.dart';
import 'package:tripsuite_app_boilerplate/features/splash_screen.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
      },
    );
  }
}