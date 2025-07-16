import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lift_life/generated/assets.dart';
import 'package:lift_life/helper/nav_helper/nav_helper.dart';
import 'package:lift_life/helper/routes.dart';

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
      navigateToNextScreen();
    });
    return Scaffold(
      body: Center(
        child: Image.asset(
          Assets.splash,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
  void navigateToNextScreen() {
   Future.delayed(
            Duration(seconds: 2),
            () => navigateToScreen(Routes.weight_screen, replaceStack: true),
          );
  } 
}
