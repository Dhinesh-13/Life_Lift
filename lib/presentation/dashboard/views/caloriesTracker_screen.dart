import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lift_life/presentation/dashboard/cubit/food_log_cubit.dart';
import 'package:lift_life/presentation/dashboard/widgets/food_conformation_screen.dart';

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
      await scanImage();
    }
  }

  Future<void> scanImage() async {
    if (_image == null) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Analyzing image...'),
          ],
        ),
      ),
    );

    try {
      final result = await context.read<FoodLogCubit>().detectFoodFromImage(_image!);
      
      // Close loading dialog
      Navigator.pop(context);
      
      if (mounted) {
        result.fold(
          (error) => _showErrorSnackbar(error),
          (detectedFood) {
            // Navigate to confirmation screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodConfirmationScreen(
                  imageFile: _image!,
                  detectedFoodName: detectedFood.name,
                  baseCalories: detectedFood.calories,
                  baseProtein: detectedFood.protein,
                  baseCarbs: detectedFood.carbs,
                  baseFat: detectedFood.fat,
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      _showErrorSnackbar('Failed to analyze image: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select Image Source',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
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
          SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calorie Tracker'),
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
                  "Today's trackers",
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
                                  'Daily Summary',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildNutritionItem(
                                      'Calories',
                                      '${state.totalCalories.toStringAsFixed(0)}',
                                      Colors.orange,
                                    ),
                                    _buildNutritionItem(
                                      'Protein',
                                      '${state.totalProtein.toStringAsFixed(1)}g',
                                      Colors.red,
                                    ),
                                    _buildNutritionItem(
                                      'Carbs',
                                      '${state.totalCarbs.toStringAsFixed(1)}g',
                                      Colors.blue,
                                    ),
                                    _buildNutritionItem(
                                      'Fat',
                                      '${state.totalFat.toStringAsFixed(1)}g',
                                      Colors.green,
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
                          'Meals (${state.meals.length})',
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
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error, color: Colors.red.shade700),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.error!,
                                    style: TextStyle(color: Colors.red.shade700),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.red.shade700),
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
                                  'No meals logged today',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tap the camera button to add your first meal',
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
                                    backgroundColor: Colors.orange.shade100,
                                    child: Icon(
                                      Icons.restaurant,
                                      color: Colors.orange.shade700,
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
                                      if (value == 'delete') {
                                        context.read<FoodLogCubit>().deleteMeal(meal.id);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Delete'),
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