import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lift_life/generated/assets.dart';
import 'package:lift_life/helper/TextHelper.dart';
import 'package:lift_life/helper/nav_helper/nav_helper.dart';
import 'package:lift_life/helper/routes.dart';
import 'package:lift_life/presentation/onboarding/widget/onboarding_button.dart';
import 'package:lift_life/helper/ColorHelper.dart';
import 'package:lift_life/helper/sharedPreference_helper.dart';

class AgeScreen extends StatefulWidget {
  const AgeScreen({super.key});

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  final TextEditingController _ageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _ageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorHelper.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 60), // Add some top space if needed
            Image.asset(Assets.ageImage, height: 300, width: 300),
            // const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((0.5 * 255).round()),
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
                      TextHelper.enterYourAge,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: ColorHelper.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColorHelper.borderColor, width: 1),
                    ),
                    child: TextField(
                      controller: _ageController,
                      focusNode: _focusNode,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: false,
                        signed: false,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: ColorHelper.textColor,
                      ),
                      decoration: InputDecoration(
                       
                        prefixIcon: Icon(Icons.cake, color: ColorHelper.primaryColor),
                        suffixText: TextHelper.years,
                        suffixStyle: TextStyle(
                          color: ColorHelper.borderColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
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
                      if (_ageController.text.isNotEmpty) {
                        final age = int.tryParse(_ageController.text);
                        if (age != null) {
                          await SharedPreferenceHelper.saveAge(age);
                         
                        } 
                      } 
                      navigateToScreen(
                            Routes.genderScreen,
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
    );
  }
}
