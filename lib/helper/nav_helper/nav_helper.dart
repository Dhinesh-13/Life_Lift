import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lift_life/helper/nav_helper/nav_observer.dart';
import 'package:lift_life/helper/routes.dart';
import 'package:lift_life/presentation/dashboard/views/active_workout_screen.dart';
import 'package:lift_life/presentation/dashboard/views/cycling_screen.dart';
import 'package:lift_life/presentation/dashboard/views/dashboard_screen.dart';
import 'package:lift_life/presentation/dashboard/views/exercise_selection_screen.dart';
import 'package:lift_life/presentation/dashboard/views/walking_screen.dart';
import 'package:lift_life/presentation/dashboard/views/workout_detail_screen.dart';

import 'package:lift_life/presentation/onboarding/views/age_screen.dart';
import 'package:lift_life/presentation/onboarding/views/fitnessGoals_screen.dart';
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
          path: Routes.getRouterPath(Routes.weightScreen),
          name: Routes.weightScreen,
          builder: (context, state) {
            return const WeightScreen();
          },
        ),
        GoRoute(
          path: Routes.getRouterPath(Routes.ageScreen),
          name: Routes.ageScreen,
          builder: (context, state) {
            return const AgeScreen();
          },
        ),
        GoRoute(
          path: Routes.getRouterPath(Routes.heightScreen),
          name: Routes.heightScreen,
          builder: (context, state) {
            return const HeightScreen();
          },
        ),
        GoRoute(
          path: Routes.getRouterPath(Routes.genderScreen),
          name: Routes.genderScreen,
          builder: (context, state) {
            return const GenderScreen();
          },
        ),
        GoRoute(
          path: Routes.getRouterPath(Routes.fitnessGoalScreen),
          name: Routes.fitnessGoalScreen,
          builder: (context, state) {
            return const FitnessGoalsScreen();
          },
        ),
        GoRoute(
          path: Routes.getRouterPath(Routes.dashboardScreen),
          name: Routes.dashboardScreen,
          builder: (context, state) {
            return const DashboardScreen();
          },
        ),
        GoRoute(
          path: Routes.getRouterPath(Routes.walkingScreen),
          name: Routes.walkingScreen,
          builder: (context, state) {
            return const WalkingScreen();
          },
        ),
        // GoRoute(
        //   path: Routes.getRouterPath(Routes.cyclingScreen),
        //   name: Routes.cyclingScreen,
        //   builder: (context, state) {
        //     return const CyclingScreen();
        //   },
        // ),
        GoRoute(
          path: Routes.getRouterPath(Routes.gymScreen),
          name: Routes.gymScreen,
          builder: (context, state) {
            return const GymScreen();
          },
        ),
        GoRoute(
          path: Routes.getRouterPath(Routes.activeWorkoutScreen),
          name: Routes.activeWorkoutScreen,
          builder: (context, state) {
            return const ActiveWorkoutScreen();
          },
        ),
        GoRoute(
          path: Routes.getRouterPath(Routes.exerciseSelectionScreen),
          name: Routes.exerciseSelectionScreen,
          builder: (context, state) {
            // Use Map<String, dynamic> instead of HashMap
            final arguments = state.extra as Map<String, dynamic>?;
            final bool isSelectingForWorkout =
                arguments?['isSelectingForWorkout'] ?? false;

            return ExerciseSelectionScreen(
              isSelectingForWorkout: isSelectingForWorkout,
            );
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
