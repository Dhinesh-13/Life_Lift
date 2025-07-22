

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lift_life/core/calorie_calculator.dart';
import 'package:lift_life/helper/sharedPreference_helper.dart';
import 'package:lift_life/presentation/dashboard/cubit/food_log_cubit.dart';
import 'package:lift_life/presentation/dashboard/widgets/Calorie_progress_widget.DART';
import 'package:lift_life/presentation/dashboard/widgets/macro_progressBar.dart';
import 'package:lift_life/helper/TextHelper.dart';
import 'package:lift_life/helper/ColorHelper.dart';

class FoodTrackerHomeScreen extends StatefulWidget {
  const FoodTrackerHomeScreen({Key? key}) : super(key: key);

  @override
  State<FoodTrackerHomeScreen> createState() => _FoodTrackerHomeScreenState();
}

class _FoodTrackerHomeScreenState extends State<FoodTrackerHomeScreen> {
  @override
  void initState() {
    super.initState();

    // Load today's meals when the screen initializes
    context.read<FoodLogCubit>().loadTodaysMeals();
  }

  Future<int> setGoalForCalories() async {
    return await context.read<FoodLogCubit>().setGoalForCalories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                TextHelper.todaysTrackers,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              // const SizedBox(height: 20),

              // // Daily Calorie Goal
              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.symmetric(
              //     vertical: 12,
              //     horizontal: 24,
              //   ),
              //   decoration: BoxDecoration(
              //     color: Colors.green[100],
              //     borderRadius: BorderRadius.circular(25),
              //   ),
              //   child: Center(
              //     child: FutureBuilder<int>(
              //       future: setGoalForCalories(),
              //       builder: (context, snapshot) {
              //         if (snapshot.connectionState == ConnectionState.waiting) {
              //           return CircularProgressIndicator();
              //         } else if (snapshot.hasError) {
              //           return Text('Error loading calories');
              //         } else {
              //           final calories = snapshot.data ?? 0;
              //           return Text(
              //             "${TextHelper.dailySummary}: $calories ${TextHelper.calories}",
              //             style: TextStyle(
              //               fontSize: 18,
              //               fontWeight: FontWeight.w600,
              //               color: Colors.black87,
              //             ),
              //           );
              //         }
              //       },
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 30),

              // Calorie Progress Circle
              BlocBuilder<FoodLogCubit, FoodLogState>(
                builder: (context, state) {
                  return FutureBuilder<int>(
                    future: setGoalForCalories(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error loading calories');
                      } else {
                        final goalCalories = snapshot.data ?? 0;
                        return CalorieProgressWidget(
                          currentCalories: state.totalCalories,
                          goalCalories: goalCalories.toDouble(),
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 30),

              // Macros Progress Bars
              BlocBuilder<FoodLogCubit, FoodLogState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      MacroProgressBar(
                        label: TextHelper.protein,
                        current: state.totalProtein,
                        goal: 141,
                        color: ColorHelper.proteinColor,
                        unit: "g",
                      ),
                      Spacer(),
                      MacroProgressBar(
                        label: TextHelper.fat,
                        current: state.totalFat,
                        goal: 63,
                        color: ColorHelper.fatColor,
                        unit: "g",
                      ),
                      Spacer(),
                      MacroProgressBar(
                        label: TextHelper.carbs,
                        current: state.totalCarbs,
                        goal: 282,
                        color: ColorHelper.carbsColor,
                        unit: "g",
                      ),
                    ],
                  );
                },
              ),
              // Meals Section Title
            ],
          ),
        ),
      ),
    );
  }
}
