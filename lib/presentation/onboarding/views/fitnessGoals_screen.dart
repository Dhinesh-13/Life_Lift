import 'package:flutter/material.dart';
import 'package:lift_life/generated/assets.dart';
import 'package:lift_life/helper/nav_helper/nav_helper.dart';
import 'package:lift_life/helper/routes.dart';
import 'package:lift_life/helper/sharedPreference_helper.dart';
import 'package:lift_life/presentation/onboarding/widget/onboarding_button.dart';
import 'package:lottie/lottie.dart';
import 'package:lift_life/helper/TextHelper.dart';
import 'package:lift_life/helper/ColorHelper.dart';

class FitnessGoalsScreen extends StatefulWidget {
  const FitnessGoalsScreen({super.key});

  @override
  State<FitnessGoalsScreen> createState() => _FitnessGoalsScreenState();
}

class _FitnessGoalsScreenState extends State<FitnessGoalsScreen> {
  String? selectedGoal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: ColorHelper.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha((0.1 * 255).round()),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Lottie.asset(
                          Assets
                              .fitnessGoalsImage, // You can change this to a fitness-specific image
                          height: 200,
                          width: 200,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      const Text(
                        TextHelper.selectYourFitnessGoal,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: ColorHelper.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          TextHelper.chooseYourPrimaryFitnessObjective,
                          style: TextStyle(
                            fontSize: 14,
                            color: ColorHelper.borderColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Weight Loss Option
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedGoal = TextHelper.weightLoss;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: selectedGoal == TextHelper.weightLoss
                                ? ColorHelper.accentColor.withAlpha(
                                    (0.1 * 255).round(),
                                  )
                                : ColorHelper.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedGoal == TextHelper.weightLoss
                                  ? ColorHelper.accentColor
                                  : ColorHelper.borderColor,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.trending_down,
                                color: selectedGoal == TextHelper.weightLoss
                                    ? ColorHelper.accentColor
                                    : ColorHelper.borderColor,
                                size: 28,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      TextHelper.weightLoss,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            selectedGoal ==
                                                TextHelper.weightLoss
                                            ? ColorHelper.accentColor
                                            : ColorHelper.textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      TextHelper.burnCaloriesAndLoseWeight,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (selectedGoal == TextHelper.weightLoss)
                                Icon(
                                  Icons.check_circle,
                                  color: ColorHelper.accentColor,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Weight Gain Option
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedGoal = TextHelper.weightGain;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: selectedGoal == TextHelper.weightGain
                                ? ColorHelper.secondaryColor.withAlpha(
                                    (0.1 * 255).round(),
                                  )
                                : ColorHelper.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedGoal == TextHelper.weightGain
                                  ? ColorHelper.secondaryColor
                                  : ColorHelper.borderColor,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: selectedGoal == TextHelper.weightGain
                                    ? ColorHelper.secondaryColor
                                    : ColorHelper.borderColor,
                                size: 28,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      TextHelper.weightGain,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            selectedGoal ==
                                                TextHelper.weightGain
                                            ? ColorHelper.secondaryColor
                                            : ColorHelper.textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      TextHelper.buildMuscleAndGainWeight,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (selectedGoal == TextHelper.weightGain)
                                Icon(
                                  Icons.check_circle,
                                  color: ColorHelper.secondaryColor,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Weight Maintain Option
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedGoal = TextHelper.weightMaintain;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: selectedGoal == TextHelper.weightMaintain
                                ? ColorHelper.primaryColor.withAlpha(
                                    (0.1 * 255).round(),
                                  )
                                : ColorHelper.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedGoal == TextHelper.weightMaintain
                                  ? ColorHelper.primaryColor
                                  : ColorHelper.borderColor,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.balance,
                                color: selectedGoal == TextHelper.weightMaintain
                                    ? ColorHelper.primaryColor
                                    : ColorHelper.borderColor,
                                size: 28,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      TextHelper.weightMaintain,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            selectedGoal ==
                                                TextHelper.weightMaintain
                                            ? ColorHelper.primaryColor
                                            : ColorHelper.textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      TextHelper
                                          .stayFitAndMaintainCurrentWeight,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (selectedGoal == TextHelper.weightMaintain)
                                Icon(
                                  Icons.check_circle,
                                  color: ColorHelper.primaryColor,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: onboardingButton(
                              text: TextHelper.back,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: onboardingButton(
                              text: TextHelper.next,
                              onPressed: () async {
                                if (selectedGoal != null) {
                                  // Navigate to next screen
                                  await SharedPreferenceHelper.setFitnessGoal(
                                    selectedGoal!,
                                  );
                                }
                                navigateToScreen(
                                  Routes.dashboardScreen,
                                  replaceStack: false,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
