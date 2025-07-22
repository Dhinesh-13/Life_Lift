// food_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:lift_life/data/model/food_item.dart';

class FoodService {
  final String _model = 'gemini-1.5-pro';
  static const int maxRetries = 3;
  static const int baseDelaySeconds = 2;

  FoodService() {
    // Gemini should already be initialized in main.dart
    // Just verify it's available
    if (!_isGeminiInitialized()) {
      throw Exception('Gemini not initialized. Please initialize in main.dart');
    }
  }

  bool _isGeminiInitialized() {
    try {
      // Try to access instance to check if it's initialized
      Gemini.instance;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Either<String, List<FoodItem>>> detectMultipleFoodsFromImage(File imageFile) async {
    try {
      if (!imageFile.existsSync()) {
        return Left('File not found: ${imageFile.path}');
      }

      print('Detecting food from image: ${imageFile.path}');

      // Attempt with retry logic
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          final response = await Gemini.instance.textAndImage(
            text:
                'You must return ONLY the following JSON format and nothing else: {"foods": [{"name": '
                '"", "calories": 0, "protein": 0, "carbs": 0, "fat": 0}]}. Do NOT include any  '
                'explanation, description, code block, markdown, or formatting. Output exactly one '
                'raw JSON object. Analyse all food in the image and provide nutritional information '
                ' for exactly 100 grams of each food item. Include all detected foods in the "foods" array within a single JSON response.',
            images: [imageFile.readAsBytesSync()],
          );

          final output = response?.output;
          if (output == null || output.isEmpty) {
            return Left('No response output from Gemini API');
          }

          // print('Raw Gemini response: $output');

          // Extract JSON from the response
          final match = RegExp(r'\{.*\}').firstMatch(output);
          if (match == null) {
            return Left('No valid JSON found in output: $output');
          }

          final jsonString = match.group(0)!;
          print('Extracted JSON: $jsonString');

          final foodData = jsonDecode(jsonString);
          final foods = foodData['foods'];
          if (foods == null || foods is! List || foods.isEmpty) {
            return Left('No foods detected');
          }
          final detectedFoods = foods.map<FoodItem>((food) => FoodItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: food['name'].toString(),
            calories: (food['calories'] ?? 0).toDouble(),
            protein: (food['protein'] ?? 0).toDouble(),
            carbs: (food['carbs'] ?? 0).toDouble(),
            fat: (food['fat'] ?? 0).toDouble(),
            quantity: 100.0,
            timestamp: DateTime.now(),
          )).toList();

          return Right(detectedFoods);
        } catch (e) {
          print('Attempt $attempt failed: $e');

          // Check if it's a 503 error
          if (e.toString().contains('503') ||
              e.toString().contains('Server error')) {
            if (attempt < maxRetries) {
              int delaySeconds = baseDelaySeconds * attempt;
              print('Server is busy, retrying in $delaySeconds seconds...');
              await Future.delayed(Duration(seconds: delaySeconds));
              continue;
            } else {
              // All retries exhausted for 503 error
              return Left(
                'Server is currently busy. Please try again in a few minutes. The AI service is experiencing high traffic.',
              );
            }
          } else {
            // Non-503 error, don't retry
            return Left('Server is currently busy. Please try again in a few minutes. The AI service is experiencing high traffic.');
          }
        }
      }

      // This should not be reached, but just in case
      return Left('Server is currently busy. Please try again in a few minutes. The AI service is experiencing high traffic.');
    } catch (e) {
      print('Error in detectFoodAndCalories: $e');
      return Left('Server is currently busy. Please try again in a few minutes. The AI service is experiencing high traffic.');
    }
  }
}
