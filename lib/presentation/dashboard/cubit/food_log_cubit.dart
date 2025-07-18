import 'dart:io';
import 'package:lift_life/data/model/food_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lift_life/domain/repo/food_repo.dart';

class FoodLogState {
  final List<FoodItem> meals;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final List<double> weeklyData;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const FoodLogState({
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

  Future<dynamic> addMealFromImage(File image) async {
    emit(state.copyWith(isLoading: true, error: null, successMessage: null));

    final result = await _repository.detectFoodFromImage(image);

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
      (meal) async {
        // Update the local state with the new meal
        final updatedMeals = List<FoodItem>.from(state.meals)..add(meal);
        final totals = _calculateTotals(updatedMeals);
        
        emit(
          state.copyWith(
            meals: updatedMeals,
            totalCalories: totals['calories']!,
            totalProtein: totals['protein']!,
            totalCarbs: totals['carbs']!,
            totalFat: totals['fat']!,
            error: null,
            successMessage: 'Food "${meal.name}" detected successfully and added to the log.',
            isLoading: false,
          ),
        );
        
        // Load weekly data after adding meal
        await loadWeeklyData();
      },
    );
    
    return result;
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
        // Don't emit error for weekly data failure, just log it
        print('Failed to load weekly data: $failure');
      },
      (weeklyData) {
        emit(state.copyWith(weeklyData: weeklyData));
      },
    );
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  void clearSuccessMessage() {
    emit(state.copyWith(successMessage: null));
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