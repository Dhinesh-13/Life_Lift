import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lift_life/presentation/dashboard/cubit/food_log_cubit.dart';
import 'package:lift_life/presentation/dashboard/widgets/MacroProgressBar.dart';
import 'package:lift_life/presentation/dashboard/widgets/calorie_progress_widget.dart';

class FoodTrackerHomeScreen extends StatefulWidget {
  const FoodTrackerHomeScreen({Key? key}) : super(key: key);

  @override
  State<FoodTrackerHomeScreen> createState() => _FoodTrackerHomeScreenState();
}

class _FoodTrackerHomeScreenState extends State<FoodTrackerHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load meals by time which will also calculate totals correctly
    context.read<FoodLogCubit>().loadAllMealsByTimeWithGoal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: BlocBuilder<FoodLogCubit, FoodLogState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.error}',
                      style: TextStyle(
                        color: Colors.red[600],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<FoodLogCubit>().loadAllMealsByTimeWithGoal();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Calculate total meals from mealsByTime for more accurate count
            final totalMealsCount = state.mealsByTime.values
                .fold(0, (sum, mealList) => sum + mealList.length);

            return RefreshIndicator(
              onRefresh: () async {
                context.read<FoodLogCubit>().loadAllMealsByTimeWithGoal();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Today's Tracker",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              _formatDate(DateTime.now()),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$totalMealsCount meals',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    
                    Center(
                      child: CalorieProgressWidget(
                        currentCalories: state.totalCalories,
                        goalCalories: state.dailyCalorieGoal ?? 2000,
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Macros Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[200]!,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.pie_chart,
                                color: Colors.blue[600],
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Macronutrients",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          MacroProgressBar(
                            label: "Protein",
                            current: state.totalProtein,
                            goal: _calculateProteinGoal(state.dailyCalorieGoal ?? 2000),
                            color: Colors.red[500]!,
                            unit: "g",
                            icon: Icons.fitness_center,
                          ),
                          const SizedBox(height: 20),
                          MacroProgressBar(
                            label: "Carbs",
                            current: state.totalCarbs,
                            goal: _calculateCarbsGoal(state.dailyCalorieGoal ?? 2000),
                            color: Colors.blue[500]!,
                            unit: "g",
                            icon: Icons.grain,
                          ),
                          const SizedBox(height: 20),
                          MacroProgressBar(
                            label: "Fats",
                            current: state.totalFat,
                            goal: _calculateFatsGoal(state.dailyCalorieGoal ?? 2000),
                            color: Colors.orange[500]!,
                            unit: "g",
                            icon: Icons.water_drop,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Current Stats Summary
                    if (state.mealsByTime.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.blue[200]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildQuickStat(
                              'Meals',
                              totalMealsCount.toString(),
                              Icons.restaurant,
                              Colors.blue[600]!,
                            ),
                            _buildQuickStat(
                              'Calories',
                              state.totalCalories.toInt().toString(),
                              Icons.local_fire_department,
                              Colors.orange[600]!,
                            ),
                            _buildQuickStat(
                              'Remaining',
                              ((state.dailyCalorieGoal ?? 2000) - state.totalCalories)
                                  .toInt()
                                  .toString(),
                              Icons.trending_up,
                              Colors.green[600]!,
                            ),
                          ],
                        ),
                      ),
                      
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  double _calculateProteinGoal(double calories) {
    return (calories * 0.25) / 4;
  }

  double _calculateCarbsGoal(double calories) {
    return (calories * 0.45) / 4;
  }

  double _calculateFatsGoal(double calories) {
    return (calories * 0.30) / 9;
  }
}

// Your existing CalorieProgressWidget and MacroProgressBar classes remain the same...

