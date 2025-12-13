
import 'package:flutter/material.dart';

class OnboardingScreen3 extends StatelessWidget{
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 175, 215, 234),
     body:SafeArea(
      child:Column(
        children: [
          const Spacer(),

          SizedBox(
            height: 280,
            child: Image.asset("assets/images/onboarding_screen_3_logo.png",
            fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 40),

          //Title

          const Text("Explore Destinations",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          ),

          const SizedBox(height: 16),

          //subtitle

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text("Find incredible places to visit",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            ),
            ),

            const Spacer(),

            //Pagination Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(isActive:false),
                   _dot(isActive:false),
                      _dot(isActive:true),
              ],
            ),

            SizedBox(height: 30),
        ],
      )
     )
    );
  }

  //Dot widget
  static Widget _dot({required bool isActive}){
return Container(
  margin: const EdgeInsets.symmetric(horizontal: 6),
  width: isActive ? 12 : 8,
  height: 8,
  decoration: BoxDecoration(
    color: isActive ? Colors.black :Colors.grey.shade400,
    borderRadius: BorderRadius.circular(4),
  ),
);
  }
}