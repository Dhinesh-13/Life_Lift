import 'package:flutter/material.dart';
import 'package:lift_life/generated/assets.dart';
import 'package:lift_life/helper/TextHelper.dart';
import 'package:lift_life/helper/nav_helper/nav_helper.dart';
import 'package:lift_life/helper/routes.dart';
import 'package:lift_life/helper/sharedPreference_helper.dart';
import 'package:lift_life/presentation/onboarding/widget/onboarding_button.dart';
import 'package:lottie/lottie.dart';
import 'package:lift_life/helper/ColorHelper.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorHelper.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                Assets.genderAnimation, // You can change this to a gender-specific image
                height: 200, 
                width: 350,
                fit: BoxFit.fitWidth,
              ),
              const SizedBox(height: 24),
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
                      child: const Text(
                        TextHelper.selectYourGender,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: ColorHelper.textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Male Option
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGender = TextHelper.male;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedGender == TextHelper.male 
                              ? ColorHelper.primaryColor.withAlpha((0.1 * 255).round())
                              : ColorHelper.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedGender == TextHelper.male 
                                ? ColorHelper.primaryColor 
                                : ColorHelper.borderColor,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.male,
                              color: selectedGender == TextHelper.male 
                                  ? ColorHelper.primaryColor 
                                  : ColorHelper.borderColor,
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              TextHelper.male,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: selectedGender == TextHelper.male 
                                    ? ColorHelper.primaryColor 
                                    : ColorHelper.textColor,
                              ),
                            ),
                            const Spacer(),
                            if (selectedGender == TextHelper.male)
                              Icon(
                                Icons.check_circle,
                                color: ColorHelper.primaryColor,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Female Option
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGender = TextHelper.female;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedGender == TextHelper.female 
                              ? ColorHelper.accentColor.withAlpha((0.1 * 255).round())
                              : ColorHelper.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedGender == TextHelper.female 
                                ? ColorHelper.accentColor 
                                : ColorHelper.borderColor,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.female,
                              color: selectedGender == TextHelper.female 
                                  ? ColorHelper.accentColor 
                                  : ColorHelper.borderColor,
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              TextHelper.female,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: selectedGender == TextHelper.female 
                                    ? ColorHelper.accentColor 
                                    : ColorHelper.textColor,
                              ),
                            ),
                            const Spacer(),
                            if (selectedGender == TextHelper.female)
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
                    
                    // Other Option
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGender = TextHelper.other;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedGender == TextHelper.other 
                              ? Colors.purple.withAlpha((0.1 * 255).round())
                              : ColorHelper.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedGender == TextHelper.other 
                                ? Colors.purple 
                                : ColorHelper.borderColor,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: selectedGender == TextHelper.other 
                                  ? Colors.purple 
                                  : ColorHelper.borderColor,
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              TextHelper.other,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: selectedGender == TextHelper.other 
                                    ? Colors.purple 
                                    : ColorHelper.textColor,
                              ),
                            ),
                            const Spacer(),
                            if (selectedGender == TextHelper.other)
                              Icon(
                                Icons.check_circle,
                                color: Colors.purple,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
                        if (selectedGender != null) {
                          // Save the selected gender
                          await SharedPreferenceHelper.saveGender(selectedGender!);
                        }
                        navigateToScreen(Routes.fitnessGoalScreen, replaceStack: false);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}