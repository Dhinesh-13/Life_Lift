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
  Future<Either<String, void>> addMeal(FoodItem foodItem);
  Future<Either<String, List<FoodItem>>> detectMultipleFoodsFromImage(File image);
  
  // New methods for meal time specific operations
  Future<Either<String, void>> saveMealToMealTime(FoodItem meal, String mealTime);
  Future<Either<String, List<FoodItem>>> getMealsByMealTime(String mealTime);
  Future<Either<String, Map<String, List<FoodItem>>>> getAllMealsByTime();
  Future<Either<String, void>> deleteMealFromMealTime(String mealId, String mealTime);
  
  // Add these missing method declarations:
  Future<Either<String, void>> updateMealInMealTime(FoodItem meal, String mealTime);
  Future<Either<String, void>> clearMealTime(String mealTime);
  Future<Either<String, void>> clearAllMealTimes();
}


class FoodRepositoryImpl implements FoodRepository {
  final FoodService _foodService;
  static const String _mealsKey = 'saved_meals';
  static const String _mealTimesKey = 'meal_times_map'; // New key for meal times

  FoodRepositoryImpl(this._foodService);

  @override
  Future<Either<String, List<FoodItem>>> detectMultipleFoodsFromImage(File image) async {
    try {
      final result = await _foodService.detectMultipleFoodsFromImage(image);

      return result.fold(
        (error) => Left(error),
        (foodItems) async {
          // Save the detected meals automatically
          for (final foodItem in foodItems) {
            await _saveMealToStorage(foodItem);
          }
          return Right(foodItems);
        },
      );
    } catch (e) {
      return Left('Failed to detect food: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, FoodItem>> detectFoodFromImage(File image) async {
    final result = await detectMultipleFoodsFromImage(image);
    return result.fold(
      (error) => Left(error),
      (foods) {
        if (foods.isEmpty) {
          return Left('No food detected');
        }
        return Right(foods.first);
      },
    );
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

  @override
  Future<Either<String, void>> addMeal(FoodItem foodItem) async {
    try {
      await _saveMealToStorage(foodItem);
      return Right(null);
    } catch (e) {
      return Left('Failed to add meal: ${e.toString()}');
    }
  }

  // NEW MEAL TIME SPECIFIC METHODS

  @override
  Future<Either<String, void>> saveMealToMealTime(FoodItem meal, String mealTime) async {
    try {
      await _saveMealToMealTimeStorage(meal, mealTime);
      return Right(null);
    } catch (e) {
      return Left('Failed to save meal to $mealTime: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<FoodItem>>> getMealsByMealTime(String mealTime) async {
    try {
      final mealTimesMap = await _getMealTimesMap();
      final meals = mealTimesMap[mealTime] ?? [];
      
      // Filter for today's meals only
      final today = DateTime.now();
      final todaysMeals = meals.where((meal) {
        return meal.timestamp.day == today.day &&
               meal.timestamp.month == today.month &&
               meal.timestamp.year == today.year;
      }).toList();
      
      return Right(todaysMeals);
    } catch (e) {
      return Left('Failed to get meals for $mealTime: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Map<String, List<FoodItem>>>> getAllMealsByTime() async {
    try {
      final mealTimesMap = await _getMealTimesMap();
      
      // Filter each meal time list for today's meals only
      final today = DateTime.now();
      final todaysMealsByTime = <String, List<FoodItem>>{};
      
      mealTimesMap.forEach((mealTime, meals) {
        final todaysMeals = meals.where((meal) {
          return meal.timestamp.day == today.day &&
                 meal.timestamp.month == today.month &&
                 meal.timestamp.year == today.year;
        }).toList();
        
        if (todaysMeals.isNotEmpty) {
          todaysMealsByTime[mealTime] = todaysMeals;
        }
      });
      
      return Right(todaysMealsByTime);
    } catch (e) {
      return Left('Failed to get all meals by time: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> deleteMealFromMealTime(String mealId, String mealTime) async {
    try {
      final mealTimesMap = await _getMealTimesMap();
      
      if (mealTimesMap.containsKey(mealTime)) {
        mealTimesMap[mealTime]!.removeWhere((meal) => meal.id == mealId);
        await _saveMealTimesMap(mealTimesMap);
      }
      
      return Right(null);
    } catch (e) {
      return Left('Failed to delete meal from $mealTime: ${e.toString()}');
    }
  }

  // PRIVATE HELPER METHODS FOR MEAL TIMES

  Future<void> _saveMealToMealTimeStorage(FoodItem meal, String mealTime) async {
    final mealTimesMap = await _getMealTimesMap();
    
    if (mealTimesMap.containsKey(mealTime)) {
      mealTimesMap[mealTime]!.add(meal);
    } else {
      mealTimesMap[mealTime] = [meal];
    }
    
    await _saveMealTimesMap(mealTimesMap);
  }

  Future<Map<String, List<FoodItem>>> _getMealTimesMap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_mealTimesKey);
      
      if (jsonString == null) return {};
      
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final Map<String, List<FoodItem>> mealTimesMap = {};
      
      jsonData.forEach((key, value) {
        final List<FoodItem> foodList = (value as List<dynamic>)
            .map((item) => FoodItem.fromJson(item as Map<String, dynamic>))
            .toList();
        mealTimesMap[key] = foodList;
      });
      
      return mealTimesMap;
    } catch (e) {
      print('Error parsing meal times map: $e');
      return {};
    }
  }

  Future<void> _saveMealTimesMap(Map<String, List<FoodItem>> mealTimesMap) async {
    final prefs = await SharedPreferences.getInstance();
    
    final Map<String, List<Map<String, dynamic>>> jsonData = {};
    
    mealTimesMap.forEach((key, foodList) {
      jsonData[key] = foodList.map((foodItem) => foodItem.toJson()).toList();
    });
    
    final String jsonString = jsonEncode(jsonData);
    await prefs.setString(_mealTimesKey, jsonString);
  }

  // Keep the original _saveMealToStorage method for backward compatibility
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

  // UTILITY METHODS FOR MEAL TIME OPERATIONS

  Future<Either<String, void>> addMealToMealTime(FoodItem foodItem, String mealTime) async {
    try {
      await _saveMealToMealTimeStorage(foodItem, mealTime);
      return Right(null);
    } catch (e) {
      return Left('Failed to add meal to $mealTime: ${e.toString()}');
    }
  }

  Future<Either<String, void>> updateMealInMealTime(FoodItem meal, String mealTime) async {
    try {
      final mealTimesMap = await _getMealTimesMap();
      
      if (mealTimesMap.containsKey(mealTime)) {
        final mealList = mealTimesMap[mealTime]!;
        final index = mealList.indexWhere((m) => m.id == meal.id);
        
        if (index != -1) {
          mealList[index] = meal;
          await _saveMealTimesMap(mealTimesMap);
        }
      }
      
      return Right(null);
    } catch (e) {
      return Left('Failed to update meal in $mealTime: ${e.toString()}');
    }
  }

  Future<Either<String, void>> clearMealTime(String mealTime) async {
    try {
      final mealTimesMap = await _getMealTimesMap();
      mealTimesMap[mealTime] = [];
      await _saveMealTimesMap(mealTimesMap);
      return Right(null);
    } catch (e) {
      return Left('Failed to clear $mealTime: ${e.toString()}');
    }
  }

  Future<Either<String, void>> clearAllMealTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_mealTimesKey);
      return Right(null);
    } catch (e) {
      return Left('Failed to clear all meal times: ${e.toString()}');
    }
  }
}
