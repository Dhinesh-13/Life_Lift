import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:lift_life/core/calorie_calculator.dart';
import 'package:lift_life/data/model/food_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lift_life/domain/repo/food_repo.dart';
import 'package:lift_life/helper/sharedPreference_helper.dart';

class FoodLogState {
  final Map<String, List<FoodItem>> mealsByTime; // Changed to support meal times
  final List<FoodItem> meals; // Keep for backward compatibility
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final List<double> weeklyData;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const FoodLogState({
    this.mealsByTime = const {},
    this.meals = const [],
    this.totalCalories = 0,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFat = 0,
    this.weeklyData = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  FoodLogState copyWith({
    Map<String, List<FoodItem>>? mealsByTime,
    List<FoodItem>? meals,
    double? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    List<double>? weeklyData,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return FoodLogState(
      mealsByTime: mealsByTime ?? this.mealsByTime,
      meals: meals ?? this.meals,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      weeklyData: weeklyData ?? this.weeklyData,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class FoodLogCubit extends Cubit<FoodLogState> {
  final FoodRepository _repository;
  
  FoodLogCubit(this._repository) : super(FoodLogState());

  Future<Either<String, FoodItem>> detectFoodFromImage(File image) async {
    // Only detect, do not add to meals list or storage!
    return await _repository.detectFoodFromImage(image);
  }

  Future<Either<String, List<FoodItem>>> detectMultipleFoodsFromImage(File image) async {
    return await _repository.detectMultipleFoodsFromImage(image);
  }

  // NEW MEAL TIME SPECIFIC METHODS

  Future<void> addMealToMealTime(FoodItem foodItem, String mealTime) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));

    final result = await _repository.saveMealToMealTime(foodItem, mealTime);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            error: failure,
            successMessage: null,
            isLoading: false,
          ),
        );
      },
      (_) async {
        // Update the local state with the new meal
        final updatedMealsByTime = Map<String, List<FoodItem>>.from(state.mealsByTime);
        
        if (updatedMealsByTime.containsKey(mealTime)) {
          updatedMealsByTime[mealTime] = List<FoodItem>.from(updatedMealsByTime[mealTime]!)..add(foodItem);
        } else {
          updatedMealsByTime[mealTime] = [foodItem];
        }

        // Update total meals list
        final allMeals = _getAllMealsFromMealsByTime(updatedMealsByTime);
        final totals = _calculateTotals(allMeals);
        
        emit(
          state.copyWith(
            mealsByTime: updatedMealsByTime,
            meals: allMeals,
            totalCalories: totals['calories']!,
            totalProtein: totals['protein']!,
            totalCarbs: totals['carbs']!,
            totalFat: totals['fat']!,
            error: null,
            successMessage: 'Food "${foodItem.name}" added successfully to $mealTime.',
            isLoading: false,
          ),
        );
        
        // Load weekly data after adding meal
        await loadWeeklyData();
      },
    );
  }

  Future<void> loadMealsByMealTime(String mealTime) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    
    final result = await _repository.getMealsByMealTime(mealTime);
    
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            error: failure,
            isLoading: false,
          ),
        );
      },
      (meals) {
        final updatedMealsByTime = Map<String, List<FoodItem>>.from(state.mealsByTime);
        updatedMealsByTime[mealTime] = meals;
        
        final allMeals = _getAllMealsFromMealsByTime(updatedMealsByTime);
        final totals = _calculateTotals(allMeals);
        
        emit(
          state.copyWith(
            mealsByTime: updatedMealsByTime,
            meals: allMeals,
            totalCalories: totals['calories']!,
            totalProtein: totals['protein']!,
            totalCarbs: totals['carbs']!,
            totalFat: totals['fat']!,
            isLoading: false,
            error: null,
          ),
        );
      },
    );
  }

  Future<void> loadAllMealsByTime() async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    
    final result = await _repository.getAllMealsByTime();
    
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            error: failure,
            isLoading: false,
          ),
        );
      },
      (mealsByTime) {
        final allMeals = _getAllMealsFromMealsByTime(mealsByTime);
        final totals = _calculateTotals(allMeals);
        
        emit(
          state.copyWith(
            mealsByTime: mealsByTime,
            meals: allMeals,
            totalCalories: totals['calories']!,
            totalProtein: totals['protein']!,
            totalCarbs: totals['carbs']!,
            totalFat: totals['fat']!,
            isLoading: false,
            error: null,
          ),
        );
      },
    );
  }

  Future<void> deleteMealFromMealTime(String mealId, String mealTime) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    
    final result = await _repository.deleteMealFromMealTime(mealId, mealTime);
    
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            error: failure,
            isLoading: false,
          ),
        );
      },
      (_) {
        // Update local state by removing the meal from specific meal time
        final updatedMealsByTime = Map<String, List<FoodItem>>.from(state.mealsByTime);
        
        if (updatedMealsByTime.containsKey(mealTime)) {
          updatedMealsByTime[mealTime] = updatedMealsByTime[mealTime]!
              .where((meal) => meal.id != mealId)
              .toList();
              
          if (updatedMealsByTime[mealTime]!.isEmpty) {
            updatedMealsByTime.remove(mealTime);
          }
        }
        
        final allMeals = _getAllMealsFromMealsByTime(updatedMealsByTime);
        final totals = _calculateTotals(allMeals);
        
        emit(
          state.copyWith(
            mealsByTime: updatedMealsByTime,
            meals: allMeals,
            totalCalories: totals['calories']!,
            totalProtein: totals['protein']!,
            totalCarbs: totals['carbs']!,
            totalFat: totals['fat']!,
            isLoading: false,
            successMessage: 'Meal deleted successfully from $mealTime',
          ),
        );
      },
    );
  }

  Future<void> updateMealInMealTime(FoodItem meal, String mealTime) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    
    final result = await _repository.updateMealInMealTime(meal, mealTime);
    
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            error: failure,
            isLoading: false,
          ),
        );
      },
      (_) {
        // Update local state
        final updatedMealsByTime = Map<String, List<FoodItem>>.from(state.mealsByTime);
        
        if (updatedMealsByTime.containsKey(mealTime)) {
          updatedMealsByTime[mealTime] = updatedMealsByTime[mealTime]!
              .map((m) => m.id == meal.id ? meal : m)
              .toList();
        }
        
        final allMeals = _getAllMealsFromMealsByTime(updatedMealsByTime);
        final totals = _calculateTotals(allMeals);
        
        emit(
          state.copyWith(
            mealsByTime: updatedMealsByTime,
            meals: allMeals,
            totalCalories: totals['calories']!,
            totalProtein: totals['protein']!,
            totalCarbs: totals['carbs']!,
            totalFat: totals['fat']!,
            isLoading: false,
            successMessage: 'Meal updated successfully in $mealTime',
          ),
        );
      },
    );
  }

  Future<void> clearMealTime(String mealTime) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    
    final result = await _repository.clearMealTime(mealTime);
    
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            error: failure,
            isLoading: false,
          ),
        );
      },
      (_) {
        final updatedMealsByTime = Map<String, List<FoodItem>>.from(state.mealsByTime);
        updatedMealsByTime.remove(mealTime);
        
        final allMeals = _getAllMealsFromMealsByTime(updatedMealsByTime);
        final totals = _calculateTotals(allMeals);
        
        emit(
          state.copyWith(
            mealsByTime: updatedMealsByTime,
            meals: allMeals,
            totalCalories: totals['calories']!,
            totalProtein: totals['protein']!,
            totalCarbs: totals['carbs']!,
            totalFat: totals['fat']!,
            isLoading: false,
            successMessage: '$mealTime cleared successfully',
          ),
        );
      },
    );
  }

  Future<void> clearAllMealTimes() async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    
    final result = await _repository.clearAllMealTimes();
    
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            error: failure,
            isLoading: false,
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(
            mealsByTime: {},
            meals: [],
            totalCalories: 0,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0,
            isLoading: false,
            successMessage: 'All meals cleared successfully',
          ),
        );
      },
    );
  }

  // EXISTING METHODS (kept for backward compatibility)

  Future<void> addMealFromConfirmedData(FoodItem foodItem) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));

    final result = await _repository.addMeal(foodItem);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            error: failure,
            successMessage: null,
            isLoading: false,
          ),
        );
      },
      (_) async {
        // Update the local state with the new meal
        final updatedMeals = List<FoodItem>.from(state.meals)..add(foodItem);
        final totals = _calculateTotals(updatedMeals);
        
        emit(
          state.copyWith(
            meals: updatedMeals,
            totalCalories: totals['calories']!,
            totalProtein: totals['protein']!,
            totalCarbs: totals['carbs']!,
            totalFat: totals['fat']!,
            error: null,
            successMessage: 'Food "${foodItem.name}" added successfully to the log.',
            isLoading: false,
          ),
        );
        
        // Load weekly data after adding meal
        await loadWeeklyData();
      },
    );
  }

  Future<int> setGoalForCalories() async {
    final age = (await SharedPreferenceHelper.getAge()) ?? 25;
    final weight = (await SharedPreferenceHelper.getWeight()) ?? 70.0;
    final height = (await SharedPreferenceHelper.getHeight()) ?? 170.0;
    final gender = (await SharedPreferenceHelper.getGender()) ?? 'Male';
    final activityLevel = 'Moderate'; // Or get from user/settings

    int maintenanceCalories = CalorieCalculator.fallbackEstimateCalories(
      weight: weight,
      height: height,
      age: age,
      activityLevel: activityLevel,
      gender: gender,
    );
    return maintenanceCalories;
  }

  Future<void> loadTodaysMeals() async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    
    final result = await _repository.getTodaysMeals();
    
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            error: failure,
            isLoading: false,
          ),
        );
      },
      (meals) {
        final totals = _calculateTotals(meals);
        emit(
          state.copyWith(
            meals: meals,
            totalCalories: totals['calories']!,
            totalProtein: totals['protein']!,
            totalCarbs: totals['carbs']!,
            totalFat: totals['fat']!,
            isLoading: false,
            error: null,
          ),
        );
      },
    );
  }

  Future<void> deleteMeal(String mealId) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    
    final result = await _repository.deleteMeal(mealId);
    
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            error: failure,
            isLoading: false,
          ),
        );
      },
      (_) {
        // Update local state by removing the meal
        final updatedMeals = state.meals.where((meal) => meal.id != mealId).toList();
        final totals = _calculateTotals(updatedMeals);
        
        emit(
          state.copyWith(
            meals: updatedMeals,
            totalCalories: totals['calories']!,
            totalProtein: totals['protein']!,
            totalCarbs: totals['carbs']!,
            totalFat: totals['fat']!,
            isLoading: false,
            successMessage: 'Meal deleted successfully',
          ),
        );
      },
    );
  }

  Future<void> updateMeal(FoodItem meal) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));
    
    final result = await _repository.updateMeal(meal);
    
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            error: failure,
            isLoading: false,
          ),
        );
      },
      (_) {
        // Update local state
        final updatedMeals = state.meals.map((m) => m.id == meal.id ? meal : m).toList();
        final totals = _calculateTotals(updatedMeals);
        
        emit(
          state.copyWith(
            meals: updatedMeals,
            totalCalories: totals['calories']!,
            totalProtein: totals['protein']!,
            totalCarbs: totals['carbs']!,
            totalFat: totals['fat']!,
            isLoading: false,
            successMessage: 'Meal updated successfully',
          ),
        );
      },
    );
  }

  Future<void> loadWeeklyData() async {
    final result = await _repository.getWeeklyCalorieData();
    
    result.fold(
      (failure) {
        print('Failed to load weekly data: $failure');
      },
      (weeklyData) {
        emit(state.copyWith(weeklyData: weeklyData));
      },
    );
  }

  // UTILITY METHODS

  void clearError() {
    emit(state.copyWith(error: null));
  }

  void clearSuccessMessage() {
    emit(state.copyWith(successMessage: null));
  }

  // Get meals for a specific meal time from current state
  List<FoodItem> getMealsForMealTime(String mealTime) {
    return state.mealsByTime[mealTime] ?? [];
  }

  // Get all available meal times from current state
  List<String> getAvailableMealTimes() {
    return state.mealsByTime.keys.toList();
  }

  // Helper method to flatten mealsByTime to a single list
  List<FoodItem> _getAllMealsFromMealsByTime(Map<String, List<FoodItem>> mealsByTime) {
    final List<FoodItem> allMeals = [];
    mealsByTime.values.forEach((mealList) {
      allMeals.addAll(mealList);
    });
    return allMeals;
  }

  Map<String, double> _calculateTotals(List<FoodItem> meals) {
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
}
