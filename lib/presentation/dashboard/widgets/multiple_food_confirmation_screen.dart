import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lift_life/helper/ColorHelper.dart';
import 'package:lift_life/presentation/dashboard/cubit/food_log_cubit.dart';
import 'package:lift_life/data/model/food_item.dart';

class MultipleFoodConfirmationScreen extends StatefulWidget {
  final File? imageFile;
  final List<FoodItem> detectedFoods;

  const MultipleFoodConfirmationScreen({
    Key? key,
    required this.imageFile,
    required this.detectedFoods,
  }) : super(key: key);

  @override
  State<MultipleFoodConfirmationScreen> createState() => _MultipleFoodConfirmationScreenState();
}

class _MultipleFoodConfirmationScreenState extends State<MultipleFoodConfirmationScreen> {
  List<FoodItemWithController> foodItemsWithControllers = [];
  final TextEditingController _mealTitleController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each detected food
    foodItemsWithControllers = widget.detectedFoods.map((food) {
      return FoodItemWithController(
        foodItem: food,
        weightController: TextEditingController(text: '100'),
        isSelected: true,
      );
    }).toList();

    // Add listeners to all controllers
    for (var item in foodItemsWithControllers) {
      item.weightController.addListener(() => _recalculateNutrition(item));
    }

    // Initial calculation
    _recalculateAllNutrition();
    
    // Set default meal title
    _mealTitleController.text = _generateDefaultMealTitle();
  }

  String _generateDefaultMealTitle() {
    final now = DateTime.now();
    final hour = now.hour;
    
    if (hour < 12) {
      return "Breakfast";
    } else if (hour < 17) {
      return "Lunch";
    } else {
      return "Dinner";
    }
  }

  void _recalculateNutrition(FoodItemWithController item) {
    final weight = double.tryParse(item.weightController.text) ?? 100;
    final multiplier = weight / 100; // Assuming base values are per 100g
    
    setState(() {
      item.calculatedFood = FoodItem(
        id: item.foodItem.id,
        name: item.foodItem.name,
        calories: item.foodItem.calories * multiplier,
        protein: item.foodItem.protein * multiplier,
        carbs: item.foodItem.carbs * multiplier,
        fat: item.foodItem.fat * multiplier,
        quantity: weight,
        timestamp: DateTime.now(),
      );
    });
  }

  void _recalculateAllNutrition() {
    for (var item in foodItemsWithControllers) {
      _recalculateNutrition(item);
    }
  }

  void _showMealTitleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Save Meal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _mealTitleController,
              decoration: InputDecoration(
                labelText: 'Meal Title',
                hintText: 'Enter meal name (e.g. Breakfast, Lunch)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.restaurant),
              ),
              autofocus: true,
            ),
            SizedBox(height: 16),
            Text(
              'Selected ${foodItemsWithControllers.where((item) => item.isSelected).length} food items will be saved.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (_mealTitleController.text.trim().isNotEmpty) {
                _confirmAndAddMeals();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a meal title'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: Text('Save Meal'),
          ),
        ],
      ),
    );
  }

  void _confirmAndAddMeals() async {
    if (_isLoading) return; // Prevent double submission
    
    // Get only selected foods with their calculated values
    final selectedFoods = foodItemsWithControllers
        .where((item) => item.isSelected && item.calculatedFood != null)
        .map((item) => item.calculatedFood!)
        .toList();
  
    if (selectedFoods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one food item'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final mealTitle = _mealTitleController.text.trim();

    setState(() {
      _isLoading = true;
    });

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Saving meal...'),
          ],
        ),
      ),
    );

    try {
      final cubit = context.read<FoodLogCubit>();
      
      // Save each selected food item to the specific meal title
      for (final foodItem in selectedFoods) {
        // Update the food item with unique ID
        final updatedFoodItem = FoodItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '_${selectedFoods.indexOf(foodItem)}',
          name: foodItem.name,
          calories: foodItem.calories,
          protein: foodItem.protein,
          carbs: foodItem.carbs,
          fat: foodItem.fat,
          quantity: foodItem.quantity,
          timestamp: DateTime.now(),
        );
        
        // Save to specific meal title using the new method
        await cubit.addMealToMealTime(updatedFoodItem, mealTitle);
      }

      // Also create a combined meal entry if there are multiple items
      if (selectedFoods.length > 1) {
        final combinedMeal = FoodItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '_combined',
          name: '$mealTitle - Combined',
          calories: _totalCalories,
          protein: _totalProtein,
          carbs: _totalCarbs,
          fat: _totalFat,
          quantity: selectedFoods.fold(0.0, (sum, item) => sum + (item.quantity ?? 0)),
          timestamp: DateTime.now(),
        );

        // Save combined meal to the traditional storage for backward compatibility
        await cubit.addMealFromConfirmedData(combinedMeal);
      }
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedFoods.length} items saved to "$mealTitle"!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // Navigate back to main screen
        Navigator.pop(context);
      }
    } catch (error) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving meal: $error'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToSavedMeals() {
    // Navigate to a screen that shows all saved meals
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavedMealsScreen(),
      ),
    );
  }

  double get _totalCalories {
    return foodItemsWithControllers
        .where((item) => item.isSelected && item.calculatedFood != null)
        .fold(0.0, (sum, item) => sum + item.calculatedFood!.calories);
  }

  double get _totalProtein {
    return foodItemsWithControllers
        .where((item) => item.isSelected && item.calculatedFood != null)
        .fold(0.0, (sum, item) => sum + item.calculatedFood!.protein);
  }

  double get _totalCarbs {
    return foodItemsWithControllers
        .where((item) => item.isSelected && item.calculatedFood != null)
        .fold(0.0, (sum, item) => sum + item.calculatedFood!.carbs);
  }

  double get _totalFat {
    return foodItemsWithControllers
        .where((item) => item.isSelected && item.calculatedFood != null)
        .fold(0.0, (sum, item) => sum + item.calculatedFood!.fat);
  }

  @override
  void dispose() {
    for (var item in foodItemsWithControllers) {
      item.weightController.dispose();
    }
    _mealTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Food Items'),
        actions: [
          // View saved meals button
          IconButton(
            icon: Icon(Icons.restaurant_menu),
            onPressed: _navigateToSavedMeals,
            tooltip: 'View Saved Meals',
          ),
        ],
      ),
      body: Column(
        children: [
          // Meal Title Input Card
          Container(
            margin: EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meal Title',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _mealTitleController,
                      decoration: InputDecoration(
                        hintText: 'Enter meal name (e.g. Breakfast, Lunch, Dinner)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.restaurant),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Food Items List - Expanded
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: foodItemsWithControllers.length,
              itemBuilder: (context, index) {
                final item = foodItemsWithControllers[index];
                return _buildFoodItemCard(item, index);
              },
            ),
          ),

          // Total Summary Card - Fixed at bottom
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Summary',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (_mealTitleController.text.trim().isNotEmpty)
                          Chip(
                            label: Text(_mealTitleController.text.trim()),
                            backgroundColor: Colors.blue.shade100,
                          ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTotalNutritionItem(
                          'Calories',
                          _totalCalories.toStringAsFixed(0),
                          Colors.orange,
                        ),
                        _buildTotalNutritionItem(
                          'Protein',  
                          '${_totalProtein.toStringAsFixed(1)}g',
                          Colors.red,
                        ),
                        _buildTotalNutritionItem(
                          'Carbs',
                          '${_totalCarbs.toStringAsFixed(1)}g',
                          Colors.blue,
                        ),
                        _buildTotalNutritionItem(
                          'Fat',
                          '${_totalFat.toStringAsFixed(1)}g',
                          Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Save Button
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _showMealTitleDialog,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Saving...'),
                      ],
                    )
                  : Text(
                      'Save ${foodItemsWithControllers.where((item) => item.isSelected).length} Items as Meal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItemCard(FoodItemWithController item, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with checkbox and food name
            Row(
              children: [
                Checkbox(
                  value: item.isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      item.isSelected = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    item.foodItem.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: item.isSelected ? null : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            
            if (item.isSelected) ...[
              SizedBox(height: 16),
              
              // Weight Input
              Row(
                children: [
                  Text('Weight: ', style: TextStyle(fontWeight: FontWeight.w500)),
                  Expanded(
                    child: TextField(
                      controller: item.weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '100',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixText: 'g',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Nutrition Display
              if (item.calculatedFood != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSmallNutritionItem(
                      'Cal',
                      item.calculatedFood!.calories.toStringAsFixed(0),
                      Colors.orange,
                    ),
                    _buildSmallNutritionItem(
                      'Protein',
                      '${item.calculatedFood!.protein.toStringAsFixed(1)}g',
                      Colors.red,
                    ),
                    _buildSmallNutritionItem(
                      'Carbs',
                      '${item.calculatedFood!.carbs.toStringAsFixed(1)}g',
                      Colors.blue,
                    ),
                    _buildSmallNutritionItem(
                      'Fat',
                      '${item.calculatedFood!.fat.toStringAsFixed(1)}g',
                      Colors.green,
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTotalNutritionItem(String label, String value, Color color) {
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
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

class FoodItemWithController {
  final FoodItem foodItem;
  final TextEditingController weightController;
  bool isSelected;
  FoodItem? calculatedFood;

  FoodItemWithController({
    required this.foodItem,
    required this.weightController,
    required this.isSelected,
    this.calculatedFood,
  });
}

// Enhanced SavedMealsScreen to show meals by title
class SavedMealsScreen extends StatefulWidget {
  @override
  State<SavedMealsScreen> createState() => _SavedMealsScreenState();
}

class _SavedMealsScreenState extends State<SavedMealsScreen> {
  @override
  void initState() {
    super.initState();
    // Load all meals by time when screen opens
    context.read<FoodLogCubit>().loadAllMealsByTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Meals'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<FoodLogCubit>().loadAllMealsByTime();
            },
          ),
        ],
      ),
      body: BlocBuilder<FoodLogCubit, FoodLogState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state.mealsByTime.isEmpty) {
            return Center(
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.all(16),
            children: state.mealsByTime.entries.map((entry) {
              final mealTitle = entry.key;
              final meals = entry.value;
              
              return Card(
                margin: EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text(
                    mealTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text('${meals.length} items'),
                  children: meals.map((meal) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: Icon(
                        Icons.restaurant,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    title: Text(
                      meal.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${meal.calories.toStringAsFixed(0)} cal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange[700],
                          ),
                        ),
                        Text(
                          'P: ${meal.protein.toStringAsFixed(1)}g • C: ${meal.carbs.toStringAsFixed(1)}g • F: ${meal.fat.toStringAsFixed(1)}g',
                          style: TextStyle(fontSize: 12),
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
                          _showDeleteDialog(context, meal, mealTitle);
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
                  )).toList(),
                ),
              );
            }).toList(),
          );
        },
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
}
