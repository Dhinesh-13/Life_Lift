import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lift_life/generated/assets.dart';
import 'package:lift_life/helper/nav_helper/nav_helper.dart';
import 'package:lift_life/helper/routes.dart';
import 'package:lift_life/helper/ColorHelper.dart';
import 'package:lift_life/helper/sharedPreference_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await precacheImage(AssetImage(Assets.splash), context);
      await _navigateBasedOnOnboarding(context);
    });
    return Scaffold(
      backgroundColor: ColorHelper.backgroundColor,
      body: Center(child: Image.asset(Assets.splash, fit: BoxFit.cover)),
    );
  }

  Future<void> _navigateBasedOnOnboarding(BuildContext context) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      final age = await SharedPreferenceHelper.getAge();
      final gender = await SharedPreferenceHelper.getGender();
      final height = await SharedPreferenceHelper.getHeight();
      final weight = await SharedPreferenceHelper.getWeight();

      if (weight == null) {
        navigateToScreen(Routes.weightScreen, replaceStack: true);
      }else {
        navigateToScreen(Routes.dashboardScreen, replaceStack: true);
      }
    } catch (e) {
      // Handle any errors that might occur during the onboarding check
      print('Error during onboarding check: $e');
    }
  }
}
