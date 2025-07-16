import 'package:flutter/material.dart';
import 'package:lift_life/helper/nav_helper/nav_helper.dart';
import 'package:lift_life/presentation/onboarding/views/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
