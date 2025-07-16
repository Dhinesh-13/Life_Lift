import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lift_life/helper/nav_helper/nav_observer.dart';
import 'package:lift_life/helper/routes.dart';
import 'package:lift_life/presentation/onboarding/views/age_screen.dart';
import 'package:lift_life/presentation/onboarding/views/gender_screen.dart';
import 'package:lift_life/presentation/onboarding/views/height_screen.dart';
import 'package:lift_life/presentation/onboarding/views/splash_screen.dart';
import 'package:lift_life/presentation/onboarding/views/weight_screen.dart';  



class AppRouter {
  static GoRouter? _router;
  static GoRouter get router {
    _router ??= createRoutes();
    return _router!;
  }

  static GoRouter createRoutes() {
    return GoRouter(
     
          initialLocation: Routes.initialLocation,
          navigatorKey: NavObserver.navKey,
          observers: [NavObserver.instance],
          routes: [
            GoRoute(
              path: Routes.initialLocation,
              name: Routes.initialLocation,
              builder: (context, state) {   
                return const SplashScreen();
              },
            ),
            GoRoute(
              path: Routes.getRouterPath(Routes.weight_screen),
              name: Routes.weight_screen,
              builder: (context, state) {
                return const WeightScreen();
              },
            ),
            GoRoute(
              path: Routes.getRouterPath(Routes.age_screen),
              name: Routes.age_screen,
              builder: (context, state) {
                return const AgeScreen();
              },
            ),
            GoRoute(
              path: Routes.getRouterPath(Routes.height_screen),
              name: Routes.height_screen,
              builder: (context, state) {
                return const HeightScreen();
              },
            ),
            GoRoute(
              path: Routes.getRouterPath(Routes.gender_screen),
              name: Routes.gender_screen,
              builder: (context, state) {
                return const GenderScreen();
              },
            ),
          ],
        );
  }
}
void navigateToScreen(
  String routeName, {
  bool replaceStack = false,
  Map<String, dynamic>? arguments,
}) {
  final context = NavObserver.getContext();
  if (context == null) {
    debugPrint(routeName + " context is null");
    return;
  }

  if (replaceStack) {
    context.goNamed(routeName, extra: arguments); // Replaces the stack
  } else {
    context.pushNamed(routeName, extra: arguments); // Adds to the stack
  }
}