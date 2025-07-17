import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lift_life/presentation/dashboard/cubit/food_log_cubit.dart';
import 'package:lift_life/helper/TextHelper.dart';
import 'package:lift_life/helper/ColorHelper.dart';

class CaloriesTrackerScreen extends StatefulWidget {
  const CaloriesTrackerScreen({super.key});

  @override
  State<CaloriesTrackerScreen> createState() => _CaloriesTrackerScreenState();
}

class _CaloriesTrackerScreenState extends State<CaloriesTrackerScreen> {
  final picker = ImagePicker();
  File? _image;

  @override
  void initState() {
    super.initState();
    // Load today's meals when the screen loads
    context.read<FoodLogCubit>().loadTodaysMeals();
  }

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, maxWidth: 600);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      scanImage();
    }
  }

  void scanImage() async {
    final result = await context.read<FoodLogCubit>().addMealFromImage(_image!);
    print("API Response: $result");
    
    // Show success or error message
    if (mounted) {
      result.fold(
        (error) => _showErrorSnackbar(error),
        (foodItem) => _showSuccessSnackbar('${foodItem.name} added successfully!'),
      );
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ColorHelper.errorColor,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ColorHelper.successColor,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Camera'),
            onTap: () {
              Navigator.pop(context);
              getImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Gallery'),
            onTap: () {
              Navigator.pop(context);
              getImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TextHelper.calorieTrackerTitle),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TextHelper.todaysTrackers,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 16),
                BlocBuilder<FoodLogCubit, FoodLogState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return Center(child: CircularProgressIndicator());
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nutrition Summary Card
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  TextHelper.dailySummary,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildNutritionItem(
                                      TextHelper.calories,
                                      '${state.totalCalories.toStringAsFixed(0)}',
                                      ColorHelper.caloriesColor,
                                    ),
                                    _buildNutritionItem(
                                      TextHelper.protein,
                                      '${state.totalProtein.toStringAsFixed(1)}g',
                                      ColorHelper.proteinColor,
                                    ),
                                    _buildNutritionItem(
                                      TextHelper.carbs,
                                      '${state.totalCarbs.toStringAsFixed(1)}g',
                                      ColorHelper.carbsColor,
                                    ),
                                    _buildNutritionItem(
                                      TextHelper.fat,
                                      '${state.totalFat.toStringAsFixed(1)}g',
                                      ColorHelper.fatColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 24),
                        
                        // Meals Section
                        Text(
                          '${TextHelper.meals} (${state.meals.length})',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 16),
                        
                        // Error Display
                        if (state.error != null)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: ColorHelper.errorColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: ColorHelper.errorColor),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error, color: ColorHelper.errorColor),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.error!,
                                    style: TextStyle(color: ColorHelper.errorColor),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: ColorHelper.errorColor),
                                  onPressed: () {
                                    context.read<FoodLogCubit>().clearError();
                                  },
                                ),
                              ],
                            ),
                          ),
                        
                        // Meals List
                        if (state.meals.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.restaurant,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  TextHelper.noMealsLogged,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  TextHelper.addFirstMealHint,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: state.meals.length,
                            itemBuilder: (context, index) {
                              final meal = state.meals[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: ColorHelper.caloriesColor,
                                    child: Icon(
                                      Icons.restaurant,
                                      color: ColorHelper.backgroundColor,
                                    ),
                                  ),
                                  title: Text(
                                    meal.name,
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    '${meal.calories.toStringAsFixed(0)} cal • P: ${meal.protein.toStringAsFixed(1)}g • C: ${meal.carbs.toStringAsFixed(1)}g • F: ${meal.fat.toStringAsFixed(1)}g',
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == TextHelper.delete) {
                                        context.read<FoodLogCubit>().deleteMeal(meal.id);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: TextHelper.delete,
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: ColorHelper.errorColor),
                                            SizedBox(width: 8),
                                            Text(TextHelper.delete),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showImageSourceActionSheet(context),
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
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
          ),
        ),
      ],
    );
  }
}