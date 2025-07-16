import 'package:flutter/material.dart';
import 'package:lift_life/generated/assets.dart';
import 'package:lift_life/presentation/onboarding/widget/onboarding_button.dart';
import 'package:lottie/lottie.dart';

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
      backgroundColor: Color(0xFFF7F7F7),
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
                      color: Colors.grey.withOpacity(0.1),
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
                        'Select Your Gender',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Male Option
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGender = 'Male';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedGender == 'Male' 
                              ? Colors.blue[50] 
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedGender == 'Male' 
                                ? Colors.blue[600]! 
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.male,
                              color: selectedGender == 'Male' 
                                  ? Colors.blue[600] 
                                  : Colors.grey[600],
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Male',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: selectedGender == 'Male' 
                                    ? Colors.blue[600] 
                                    : Colors.grey[700],
                              ),
                            ),
                            const Spacer(),
                            if (selectedGender == 'Male')
                              Icon(
                                Icons.check_circle,
                                color: Colors.blue[600],
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
                          selectedGender = 'Female';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedGender == 'Female' 
                              ? Colors.pink[50] 
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedGender == 'Female' 
                                ? Colors.pink[400]! 
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.female,
                              color: selectedGender == 'Female' 
                                  ? Colors.pink[400] 
                                  : Colors.grey[600],
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Female',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: selectedGender == 'Female' 
                                    ? Colors.pink[400] 
                                    : Colors.grey[700],
                              ),
                            ),
                            const Spacer(),
                            if (selectedGender == 'Female')
                              Icon(
                                Icons.check_circle,
                                color: Colors.pink[400],
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
                          selectedGender = 'Other';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedGender == 'Other' 
                              ? Colors.purple[50] 
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedGender == 'Other' 
                                ? Colors.purple[400]! 
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: selectedGender == 'Other' 
                                  ? Colors.purple[400] 
                                  : Colors.grey[600],
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Other',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: selectedGender == 'Other' 
                                    ? Colors.purple[400] 
                                    : Colors.grey[700],
                              ),
                            ),
                            const Spacer(),
                            if (selectedGender == 'Other')
                              Icon(
                                Icons.check_circle,
                                color: Colors.purple[400],
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
                      text: 'Back',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: onboardingButton(
                      text: 'Next',
                      onPressed: () {
                        
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