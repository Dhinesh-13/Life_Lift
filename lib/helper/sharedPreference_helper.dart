import 'dart:convert';

import 'package:lift_life/data/model/food_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static const String _keyAge = 'user_age';
  static const String _keyGender = 'user_gender';
  static const String _keyHeight = 'user_height';
  static const String _keyWeight = 'user_weight';
  static const String _keyFitnessGoal = 'user_fitness_goal';
  static const String _keyFoodItems = 'food_items_map'; // New key for food items

  // Save methods
  static Future<void> saveAge(int age) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAge, age);
  }

  static Future<void> saveGender(String gender) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGender, gender);
  }

  static Future<void> saveHeight(double height) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyHeight, height);
  }

  static Future<void> saveWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyWeight, weight);
  }

  static Future<void> setFitnessGoal(String goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFitnessGoal, goal);
  }

  // New method to save Map<String, List<FoodItem>>
  static Future<void> saveFoodItemsMap(Map<String, List<FoodItem>> foodItemsMap) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Convert Map<String, List<FoodItem>> to JSON string
    Map<String, List<Map<String, dynamic>>> jsonData = {};
    
    foodItemsMap.forEach((key, foodList) {
      jsonData[key] = foodList.map((foodItem) => foodItem.toJson()).toList();
    });
    
    String jsonString = jsonEncode(jsonData);
    await prefs.setString(_keyFoodItems, jsonString);
  }

  // Get methods
  static Future<int?> getAge() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAge);
  }

  static Future<String?> getGender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyGender);
  }

  static Future<double?> getHeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyHeight);
  }

  static Future<double?> getWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyWeight);
  }

  static Future<String?> getFitnessGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFitnessGoal);
  }

  // New method to get Map<String, List<FoodItem>>
  static Future<Map<String, List<FoodItem>>?> getFoodItemsMap() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_keyFoodItems);
    
    if (jsonString == null) return null;
    
    try {
      // Decode JSON string back to Map<String, List<FoodItem>>
      Map<String, dynamic> jsonData = jsonDecode(jsonString);
      
      Map<String, List<FoodItem>> foodItemsMap = {};
      
      jsonData.forEach((key, value) {
        List<FoodItem> foodList = (value as List<dynamic>)
            .map((item) => FoodItem.fromJson(item as Map<String, dynamic>))
            .toList();
        foodItemsMap[key] = foodList;
      });
      
      return foodItemsMap;
    } catch (e) {
      print('Error parsing food items map: $e');
      return null;
    }
  }

  // Optional: Method to clear food items map
  static Future<void> clearFoodItemsMap() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFoodItems);
  }

  // Optional: Method to add food items to a specific meal time
  static Future<void> addFoodItemsToMeal(String mealTime, List<FoodItem> foodItems) async {
    Map<String, List<FoodItem>> currentMap = await getFoodItemsMap() ?? {};
    
    if (currentMap.containsKey(mealTime)) {
      currentMap[mealTime]!.addAll(foodItems);
    } else {
      currentMap[mealTime] = foodItems;
    }
    
    await saveFoodItemsMap(currentMap);
  }

  // Optional: Method to get food items for a specific meal time
  static Future<List<FoodItem>?> getFoodItemsForMeal(String mealTime) async {
    Map<String, List<FoodItem>>? foodMap = await getFoodItemsMap();
    return foodMap?[mealTime];
  }
}