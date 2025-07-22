
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lift_life/helper/ColorHelper.dart';
import 'package:lift_life/presentation/dashboard/cubit/food_log_cubit.dart';
import 'package:lift_life/data/model/food_item.dart';

class FoodConfirmationScreen extends StatefulWidget {
  final File? imageFile;
  final String detectedFoodName;
  final double baseCalories;
  final double baseProtein;
  final double baseCarbs;
  final double baseFat;
  final bool isEnable;
  const FoodConfirmationScreen({
    Key? key,
    required this.imageFile,
    required this.detectedFoodName,
    required this.baseCalories,
    required this.baseProtein,
    required this.baseCarbs,
    required this.baseFat,
    this.isEnable = true,
  }) : super(key: key);

  @override
  State<FoodConfirmationScreen> createState() => _FoodConfirmationScreenState();
}

class _FoodConfirmationScreenState extends State<FoodConfirmationScreen> {
  final TextEditingController _weightController = TextEditingController(
    text: '100',
  );
  double _calculatedCalories = 0;
  double _calculatedProtein = 0;
  double _calculatedCarbs = 0;
  double _calculatedFat = 0;

  @override
  void initState() {
    super.initState();
    _calculateNutrition();
    _weightController.addListener(_calculateNutrition);
  }

  void _calculateNutrition() {
    final weight = double.tryParse(_weightController.text) ?? 100;
    final multiplier = weight / 100; // Assuming base values are per 100g

    setState(() {
      _calculatedCalories = widget.baseCalories * multiplier;
      _calculatedProtein = widget.baseProtein * multiplier;
      _calculatedCarbs = widget.baseCarbs * multiplier;
      _calculatedFat = widget.baseFat * multiplier;

      // Update the food item with the new quantity
      // final foodLogCubit = context.read<FoodLogCubit>();
      // foodLogCubit.updateMeal(
      //   FoodItem(
      //     id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate unique ID
      //     name: widget.detectedFoodName,
      //     calories: _calculatedCalories,
      //     protein: _calculatedProtein,
      //     carbs: _calculatedCarbs,
      //     fat: _calculatedFat,
      //     quantity: weight, // <-- ADD THIS
      //     timestamp: DateTime.now(), // <-- ADD THIS
      //   ),
      // );
    });
  }

  void _confirmAndAddMeal() async {
    final weight = double.tryParse(_weightController.text) ?? 100;

    // Create a FoodItem with calculated values
    final foodItem = FoodItem(
      id: DateTime.now().millisecondsSinceEpoch
          .toString(), // Generate unique ID
      name: widget.detectedFoodName,
      calories: _calculatedCalories,
      protein: _calculatedProtein,
      carbs: _calculatedCarbs,
      fat: _calculatedFat,
      quantity: weight, // <-- ADD THIS
      timestamp: DateTime.now(), // <-- ADD THIS
    );
    final cubit = context.read<FoodLogCubit>();
    // Validate weight input
    await cubit.addMealToMealTime(foodItem, foodItem.name);
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Adding meal...'),
          ],
        ),
      ),
    );

    // Add to food log through cubit
    await context.read<FoodLogCubit>().addMealFromConfirmedData(foodItem);

    // Close loading dialog
    if (mounted) Navigator.pop(context);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.detectedFoodName} added successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Food Item'),
        actions: [
          TextButton(
            onPressed: widget.isEnable ? _confirmAndAddMeal : null,
            child: Text(
              widget.isEnable ? 'Add' : 'End',
              style: TextStyle(
                color: ColorHelper.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Display
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: widget.imageFile != null
                      ? FileImage(widget.imageFile!)
                      : AssetImage('assets/placeholder.png') as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: 20),

            // Detected Food Name
            Text(
              'Detected Food:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
            SizedBox(height: 4),
            Text(
              widget.detectedFoodName,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 24),

            // Weight Input
            Text(
              'Enter Weight (grams):',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter weight in grams',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixText: 'g',
                prefixIcon: Icon(Icons.scale),
              ),
            ),

            SizedBox(height: 24),

            // Nutrition Information Card
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nutrition Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),

                    // Nutrition Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildNutritionCard(
                            'Calories',
                            _calculatedCalories.toStringAsFixed(0),
                            'kcal',
                            Colors.orange,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _buildNutritionCard(
                            'Protein',
                            _calculatedProtein.toStringAsFixed(1),
                            'g',
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNutritionCard(
                            'Carbs',
                            _calculatedCarbs.toStringAsFixed(1),
                            'g',
                            Colors.blue,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _buildNutritionCard(
                            'Fat',
                            _calculatedFat.toStringAsFixed(1),
                            'g',
                            Colors.green,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Base values info
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Base Values (per 100g):',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Calories: ${widget.baseCalories.toStringAsFixed(0)} • '
                            'Protein: ${widget.baseProtein.toStringAsFixed(1)}g • '
                            'Carbs: ${widget.baseCarbs.toStringAsFixed(1)}g • '
                            'Fat: ${widget.baseFat.toStringAsFixed(1)}g',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmAndAddMeal,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Add to Food Log',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard(
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            unit,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
