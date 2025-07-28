import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lift_life/generated/assets.dart';
import 'package:lift_life/helper/TextHelper.dart';
import 'package:lift_life/helper/nav_helper/nav_helper.dart';
import 'package:lift_life/helper/routes.dart';
import 'package:lift_life/presentation/onboarding/widget/onboarding_button.dart';
import 'package:lottie/lottie.dart';
import 'package:lift_life/helper/ColorHelper.dart';
import 'package:lift_life/helper/sharedPreference_helper.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  final TextEditingController _weightController = TextEditingController();
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
    _weightController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(Assets.weightAnimation, height: 300, width: 300),
              // const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: const Text(
                      TextHelper.enterTheWeight,
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
                      border: Border.all(color: ColorHelper.borderColor!, width: 1),
                    ),
                    child: TextField(
                      controller: _weightController,
                      focusNode: _focusNode,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: false,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: ColorHelper.textColor,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.scale,
                          color: ColorHelper.primaryColor,
                        ),
                        suffixText: TextHelper.kg,
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
              const SizedBox(height: 32),
              onboardingButton(text: TextHelper.next , onPressed: () async {
                if (_weightController.text.isNotEmpty) {
                  final weight = double.tryParse(_weightController.text);
                  if (weight != null) {
                    await SharedPreferenceHelper.saveWeight(weight);
                    
                  } 
                }
                navigateToScreen( Routes.heightScreen, replaceStack: false, arguments: {
                      TextHelper.weight: _weightController.text,
                    });
              }),
            ],
          ),
        ),
      ),
    );
  }
}