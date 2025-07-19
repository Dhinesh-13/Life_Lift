import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:lift_life/data/model/food_item.dart';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:lift_life/data/model/food_item.dart';
import 'package:lift_life/domain/repo/food_repo.dart';
import 'package:lift_life/service/food_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
abstract class FoodRepository {
  Future<Either<String, FoodItem>> detectFoodFromImage(File image);
  Future<Either<String, List<FoodItem>>> getTodaysMeals();
  Future<Either<String, void>> saveMeal(FoodItem meal);
  Future<Either<String, void>> deleteMeal(String mealId);
  Future<Either<String, void>> updateMeal(FoodItem meal);
  Future<Either<String, List<double>>> getWeeklyCalorieData();
}

// data/repository/food_repository_impl.dart


class FoodRepositoryImpl implements FoodRepository {
  final FoodService _foodService;
  static const String _mealsKey = 'saved_meals';

  FoodRepositoryImpl(this._foodService);

  @override
  Future<Either<String, FoodItem>> detectFoodFromImage(File image) async {
    try {
      final result = await _foodService.detectFoodAndCalories(image);

      return result.fold(
        (error) => Left(error),
        (foodItem) async {
          // Save the detected meal automatically
          await _saveMealToStorage(foodItem);
          return Right(foodItem);
        },
      );
    } catch (e) {
      return Left('Failed to detect food: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<FoodItem>>> getTodaysMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = prefs.getString(_mealsKey);
      
      if (mealsJson == null) {
        return Right([]);
      }
      
      final List<dynamic> mealsList = jsonDecode(mealsJson);
      final meals = mealsList.map((json) => FoodItem.fromJson(json)).toList();
      
      // Filter meals for today
      final today = DateTime.now();
      final todaysMeals = meals.where((meal) {
        return meal.timestamp.day == today.day &&
               meal.timestamp.month == today.month &&
               meal.timestamp.year == today.year;
      }).toList();
      
      return Right(todaysMeals);
    } catch (e) {
      return Left('Failed to load meals: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> saveMeal(FoodItem meal) async {
    try {
      await _saveMealToStorage(meal);
      return Right(null);
    } catch (e) {
      return Left('Failed to save meal: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> deleteMeal(String mealId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = prefs.getString(_mealsKey);
      
      if (mealsJson != null) {
        final List<dynamic> mealsList = jsonDecode(mealsJson);
        final meals = mealsList.map((json) => FoodItem.fromJson(json)).toList();
        
        meals.removeWhere((meal) => meal.id == mealId);
        
        final updatedJson = jsonEncode(meals.map((meal) => meal.toJson()).toList());
        await prefs.setString(_mealsKey, updatedJson);
      }
      
      return Right(null);
    } catch (e) {
      return Left('Failed to delete meal: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> updateMeal(FoodItem meal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = prefs.getString(_mealsKey);
      
      if (mealsJson != null) {
        final List<dynamic> mealsList = jsonDecode(mealsJson);
        final meals = mealsList.map((json) => FoodItem.fromJson(json)).toList();
        
        final index = meals.indexWhere((m) => m.id == meal.id);
        if (index != -1) {
          meals[index] = meal;
          final updatedJson = jsonEncode(meals.map((m) => m.toJson()).toList());
          await prefs.setString(_mealsKey, updatedJson);
        }
      }
      
      return Right(null);
    } catch (e) {
      return Left('Failed to update meal: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<double>>> getWeeklyCalorieData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = prefs.getString(_mealsKey);
      
      if (mealsJson == null) {
        return Right(List.filled(7, 0.0));
      }
      
      final List<dynamic> mealsList = jsonDecode(mealsJson);
      final meals = mealsList.map((json) => FoodItem.fromJson(json)).toList();
      
      final now = DateTime.now();
      final List<double> weeklyData = List.filled(7, 0.0);
      
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: 6 - i));
        final dayCalories = meals
            .where((meal) =>
                meal.timestamp.day == date.day &&
                meal.timestamp.month == date.month &&
                meal.timestamp.year == date.year)
            .fold(0.0, (sum, meal) => sum + meal.calories);
        weeklyData[i] = dayCalories;
      }
      
      return Right(weeklyData);
    } catch (e) {
      return Left('Failed to load weekly data: ${e.toString()}');
    }
  }

  Future<void> _saveMealToStorage(FoodItem meal) async {
    final prefs = await SharedPreferences.getInstance();
    final mealsJson = prefs.getString(_mealsKey);
    
    List<FoodItem> meals = [];
    if (mealsJson != null) {
      final List<dynamic> mealsList = jsonDecode(mealsJson);
      meals = mealsList.map((json) => FoodItem.fromJson(json)).toList();
    }
    
    meals.add(meal);
    
    final updatedJson = jsonEncode(meals.map((meal) => meal.toJson()).toList());
    await prefs.setString(_mealsKey, updatedJson);
  }
}