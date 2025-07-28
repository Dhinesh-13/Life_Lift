import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lift_life/data/model/food_item.dart';
import 'package:lift_life/presentation/dashboard/cubit/food_log_cubit.dart';
import 'package:lift_life/presentation/dashboard/widgets/FoodConfirmationScreen.dart';
import 'package:lift_life/presentation/dashboard/widgets/multiple_food_confirmation_screen.dart';

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
    context.read<FoodLogCubit>().loadAllMealsByTime();
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
      final result = await context
          .read<FoodLogCubit>()
          .detectMultipleFoodsFromImage(_image!);
      Navigator.pop(context);
      
      if (mounted) {
        result.fold(
          (error) => _showErrorSnackbar(error),
          (detectedFoods) {
            if (detectedFoods.isEmpty) {
              _showErrorSnackbar('No food detected in the image');
            } else if (detectedFoods.length == 1) {
              final firstFood = detectedFoods.first;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodConfirmationScreen(
                    imageFile: _image!,
                    detectedFoodName: firstFood.name,
                    baseCalories: firstFood.calories,
                    baseProtein: firstFood.protein,
                    baseCarbs: firstFood.carbs,
                    baseFat: firstFood.fat,
                  ),
                ),
              ).then((_) {
                // Refresh data when coming back from confirmation screen
                context.read<FoodLogCubit>().loadAllMealsByTime();
              });
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MultipleFoodConfirmationScreen(
                    imageFile: _image!,
                    detectedFoods: detectedFoods,
                  ),
                ),
              ).then((_) {
                // Refresh data when coming back from confirmation screen
                context.read<FoodLogCubit>().loadAllMealsByTime();
              });
            }
          },
        );
      }
    } catch (e) {
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

  void _showDeleteDialog(BuildContext context, FoodItem meal, String mealTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Meal'),
        content: Text('Are you sure you want to delete "${meal.name}" from $mealTitle?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<FoodLogCubit>().deleteMealFromMealTime(meal.id, mealTitle);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Meal deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
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

  // Calculate totals for a specific meal time
  Map<String, double> _calculateMealTimeTotals(List<FoodItem> meals) {
    double totalCalories = 0.0;
    double totalProtein = 0.0;
    double totalCarbs = 0.0;
    double totalFat = 0.0;

    for (final meal in meals) {
      totalCalories += meal.calories;
      totalProtein += meal.protein;
      totalCarbs += meal.carbs;
      totalFat += meal.fat;
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calorie Tracker'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<FoodLogCubit>().loadAllMealsByTime();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<FoodLogCubit, FoodLogState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // Header and Summary - Fixed at top
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's trackers",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 16),
                      
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
                      SizedBox(height: 16),
                      
                      Text(
                        'Meals by Time (${state.mealsByTime.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                
                // Meals List - Expandable
                Expanded(
                  child: state.mealsByTime.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No meals saved yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap the camera button to add your first meal',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.mealsByTime.entries.length,
                          itemBuilder: (context, index) {
                            final entry = state.mealsByTime.entries.elementAt(index);
                            final mealTitle = entry.key;
                            final meals = entry.value;
                            
                            // Calculate totals for this meal time
                            final mealTimeTotals = _calculateMealTimeTotals(meals);

                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              child: ExpansionTile(
                                title: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: _getMealTimeColor(mealTitle),
                                      child: Icon(
                                        _getMealTimeIcon(mealTitle),
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mealTitle,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            '${meals.length} items • ${mealTimeTotals['calories']!.toStringAsFixed(0)} cal',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                // Add meal time summary before individual items
                                children: [
                                  // Meal Time Total Summary
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _getMealTimeColor(mealTitle).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _getMealTimeColor(mealTitle).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$mealTitle Total',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: _getMealTimeColor(mealTitle),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            _buildSmallNutritionItem(
                                              'Cal',
                                              mealTimeTotals['calories']!.toStringAsFixed(0),
                                              Colors.orange,
                                            ),
                                            _buildSmallNutritionItem(
                                              'Protein',
                                              '${mealTimeTotals['protein']!.toStringAsFixed(1)}g',
                                              Colors.red,
                                            ),
                                            _buildSmallNutritionItem(
                                              'Carbs',
                                              '${mealTimeTotals['carbs']!.toStringAsFixed(1)}g',
                                              Colors.blue,
                                            ),
                                            _buildSmallNutritionItem(
                                              'Fat',
                                              '${mealTimeTotals['fat']!.toStringAsFixed(1)}g',
                                              Colors.green,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(height: 1),
                                  // Individual meal items
                                  ...meals.map(
                                    (meal) => ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.orange.shade100,
                                        radius: 20,
                                        child: Icon(
                                          Icons.restaurant,
                                          color: Colors.orange.shade700,
                                          size: 16,
                                        ),
                                      ),
                                      title: Text(
                                        meal.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${meal.calories.toStringAsFixed(0)} cal',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.orange[700],
                                            ),
                                          ),
                                          Text(
                                            'P: ${meal.protein.toStringAsFixed(1)}g • C: ${meal.carbs.toStringAsFixed(1)}g • F: ${meal.fat.toStringAsFixed(1)}g',
                                            style: TextStyle(fontSize: 11),
                                          ),
                                          if (meal.quantity != null && meal.quantity! > 0)
                                            Text(
                                              'Weight: ${meal.quantity!.toStringAsFixed(0)}g',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                        ],
                                      ),
                                      trailing: PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'delete') {
                                            _showDeleteDialog(
                                              context,
                                              meal,
                                              mealTitle,
                                            );
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
                                  ).toList(),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () => showImageSourceActionSheet(context),
        child: Icon(Icons.add_a_photo, color: Colors.black,),
      ),
    );
  }

  // Helper methods for meal time styling
  Color _getMealTimeColor(String mealTitle) {
    switch (mealTitle.toLowerCase()) {
      case 'breakfast':
        return Colors.orange.shade600;
      case 'lunch':
        return Colors.green.shade600;
      case 'dinner':
        return Colors.blue.shade600;
      default:
        return Colors.purple.shade600;
    }
  }

  IconData _getMealTimeIcon(String mealTitle) {
    switch (mealTitle.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }

  Widget _buildNutritionItem(String label, String value, Color color) {
    return Column(
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
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildSmallNutritionItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}