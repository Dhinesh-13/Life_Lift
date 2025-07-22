import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lift_life/data/model/food_item.dart';
import 'package:lift_life/presentation/dashboard/cubit/food_log_cubit.dart';
import 'package:lift_life/presentation/dashboard/widgets/food_conformation_screen.dart';
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
    // Load meals by time instead of just today's meals
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
    // final mockData = [
    //   {
    //     "id": "1",
    //     "name": "Chicken Breast",
    //     "calories": 165,
    //     "protein": 31,
    //     "carbs": 0,
    //     "fat": 4,
    //     "quantity": 100,
    //     "timestamp": DateTime.now().toIso8601String(),
    //   },
    //   {
    //     "id": "2",
    //     "name": "Broccoli",
    //     "calories": 34,
    //     "protein": 3,
    //     "carbs": 7,
    //     "fat": 0,
    //     "quantity": 100,
    //     "timestamp": DateTime.now().toIso8601String(),
    //   },
    //   {
    //     "id": "3",
    //     "name": "Strawberries",
    //     "calories": 32,
    //     "protein": 1,
    //     "carbs": 8,
    //     "fat": 0,
    //     "quantity": 100,
    //     "timestamp": DateTime.now().toIso8601String(),
    //   },
    //   {
    //     "id": "4",
    //     "name": "Brown Rice",
    //     "calories": 111,
    //     "protein": 2,
    //     "carbs": 24,
    //     "fat": 1,
    //     "quantity": 100,
    //     "timestamp": DateTime.now().toIso8601String(),
    //   },
    // ];

    // // Convert to List<FoodItem>
    // final mockFoods = mockData.map((json) => FoodItem.fromJson(json)).toList();

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
        result.fold((error) => _showErrorSnackbar(error), (detectedFoods) {
          detectedFoods.forEach((food) {
            print(
              'Detected food: ${food.name}, '
              'Calories: ${food.calories}, '
              'Protein: ${food.protein}, '
              'Carbs: ${food.carbs}, '
              'Fat: ${food.fat}',
            );
          });
          if (detectedFoods == null || detectedFoods.isEmpty) {
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
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MultipleFoodConfirmationScreen(
                  imageFile: _image!,
                  detectedFoods: detectedFoods,
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackbar('Failed to analyze image: $e');
    }
    // if (mounted) {
    //   if (mockFoods.isEmpty) {
    //     _showErrorSnackbar('No food detected in the image');
    //   } else if (mockFoods.length == 1) {
    //     final firstFood = mockFoods.first;
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => FoodConfirmationScreen(
    //           imageFile: _image!,
    //           detectedFoodName: firstFood.name,
    //           baseCalories: firstFood.calories,
    //           baseProtein: firstFood.protein,
    //           baseCarbs: firstFood.carbs,
    //           baseFat: firstFood.fat,
    //         ),
    //       ),
    //     );
    //   } else {
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => MultipleFoodConfirmationScreen(
    //           imageFile: _image!,
    //           detectedFoods: mockFoods,
    //         ),
    //       ),
    //     );
    //   }
    // }

    // COMMENTED CODE FOR SERVER INTEGRATION
    // ... [your commented code remains the same]
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

  // Updated method to handle meal time tap (optional - for view only)
  void _onMealTimeTap(String mealTitle, List<FoodItem> meals) {
    if (meals.length == 1) {
      // Single food - show single food screen
      final food = meals.first;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodConfirmationScreen(
            imageFile: null, // No image for existing meal
            detectedFoodName: food.name,
            baseCalories: food.calories,
            baseProtein: food.protein,
            baseCarbs: food.carbs,
            baseFat: food.fat,
          ),
        ),
      );
    } else {
      // Multiple foods - show multiple foods screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MultipleFoodConfirmationScreen(
            imageFile: null, // No image for existing meal
            detectedFoods: meals,
            isEditMode: true, // Add this parameter if you want edit mode
            existingMealTitle: mealTitle, // Pass meal title for editing
          ),
        ),
      );
    }
  }

  // Delete confirmation dialog for entire meal time
  void _showDeleteMealTimeDialog(String mealTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Meal Time'),
        content: Text(
          'Are you sure you want to delete all items from "$mealTitle"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMealTime(mealTitle);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Delete entire meal time
  void _deleteMealTime(String mealTitle) {
    context.read<FoodLogCubit>().clearMealTime(mealTitle);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All items from "$mealTitle" deleted successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Show options for meal time (View, Edit, Delete)
  void _showMealTimeOptions(String mealTitle, List<FoodItem> meals) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              mealTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          // ListTile(
          //   leading: Icon(Icons.visibility, color: Colors.blue),
          //   title: Text('View Details'),
          //   subtitle: Text('${meals.length} items'),
          //   onTap: () {
          //     Navigator.pop(context);
          //     _onMealTimeTap(mealTitle, meals);
          //   },
          // ),
          ListTile(
            leading: Icon(Icons.edit, color: Colors.orange),
            title: Text('Edit Meal'),
            subtitle: Text('Modify items and quantities'),
            onTap: () {
              Navigator.pop(context);
              _onMealTimeTap(mealTitle, meals);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Delete All Items'),
            subtitle: Text('Remove all items from this meal'),
            onTap: () {
              Navigator.pop(context);
              _showDeleteMealTimeDialog(mealTitle);
            },
          ),
          SizedBox(height: 20),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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

                        // Display meals by time instead of individual meals
                        Text(
                          'Meals by Time (${state.mealsByTime.length})',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 16),

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
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.red.shade700,
                                  ),
                                  onPressed: () {
                                    context.read<FoodLogCubit>().clearError();
                                  },
                                ),
                              ],
                            ),
                          ),

                        if (state.mealsByTime.isEmpty)
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
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: Colors.grey.shade600),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tap the camera button to add your first meal',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey.shade500),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          // Display meals grouped by time
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: state.mealsByTime.entries.length,
                            itemBuilder: (context, index) {
                              final entry = state.mealsByTime.entries.elementAt(
                                index,
                              );
                              final mealTitle =
                                  entry.key; // Breakfast, Lunch, Dinner
                              final meals = entry.value; // List<FoodItem>

                              // Calculate totals for this meal time
                              final totalCalories = meals.fold(
                                0.0,
                                (sum, meal) => sum + meal.calories,
                              );
                              final totalProtein = meals.fold(
                                0.0,
                                (sum, meal) => sum + meal.protein,
                              );
                              final totalCarbs = meals.fold(
                                0.0,
                                (sum, meal) => sum + meal.carbs,
                              );
                              final totalFat = meals.fold(
                                0.0,
                                (sum, meal) => sum + meal.fat,
                              );

                              return Card(
                                margin: EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () =>
                                      _showMealTimeOptions(mealTitle, meals),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor:
                                                  _getMealTimeColor(mealTitle),
                                              child: Icon(
                                                _getMealTimeIcon(mealTitle),
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    mealTitle,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    '${meals.length} items',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Replace arrow with delete button
                                            PopupMenuButton<String>(
                                              onSelected: (value) {
                                                if (value == 'view') {
                                                  _onMealTimeTap(
                                                    mealTitle,
                                                    meals,
                                                  );
                                                } else if (value == 'delete') {
                                                  _showDeleteMealTimeDialog(
                                                    mealTitle,
                                                  );
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  value: 'view',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.visibility,
                                                        color: Colors.blue,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text('View/Edit'),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  value: 'delete',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text('Delete All'),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                              child: Container(
                                                padding: EdgeInsets.all(4),
                                                child: Icon(
                                                  Icons.more_vert,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        // Total nutrition for this meal time
                                        Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              _buildSmallNutritionItem(
                                                'Cal',
                                                totalCalories.toStringAsFixed(
                                                  0,
                                                ),
                                                Colors.orange,
                                              ),
                                              _buildSmallNutritionItem(
                                                'Protein',
                                                '${totalProtein.toStringAsFixed(1)}g',
                                                Colors.red,
                                              ),
                                              _buildSmallNutritionItem(
                                                'Carbs',
                                                '${totalCarbs.toStringAsFixed(1)}g',
                                                Colors.blue,
                                              ),
                                              _buildSmallNutritionItem(
                                                'Fat',
                                                '${totalFat.toStringAsFixed(1)}g',
                                                Colors.green,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
            fontSize: 20,
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
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
