import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static const String _keyAge = 'user_age';
  static const String _keyGender = 'user_gender';
  static const String _keyHeight = 'user_height';
  static const String _keyWeight = 'user_weight';
  static const String _keyFitnessGoal = 'user_fitness_goal';
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
  static Future<void> setFitnessGoal(String goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFitnessGoal, goal);
  }
}
