import 'package:flutter/material.dart';
import 'package:tripsuite_app_boilerplate/features/onboarding/screens/onboarding_screen1.dart';
import 'package:tripsuite_app_boilerplate/features/onboarding/screens/onboarding_screen2.dart';
import 'package:tripsuite_app_boilerplate/features/onboarding/screens/onboarding_screen3.dart';

class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: const [
        OnboardingScreen1(),
        OnboardingScreen2(),
        OnboardingScreen3(),
      ],
    );
  }
}
