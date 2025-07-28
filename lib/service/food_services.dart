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
    // Validate file existence
    if (!imageFile.existsSync()) {
      return Left('File not found: ${imageFile.path}');
    }

    // Validate file size and format
    final fileSizeInBytes = await imageFile.length();
    const maxFileSize = 10 * 1024 * 1024; // 10MB limit
    if (fileSizeInBytes > maxFileSize) {
      return Left('Image file is too large. Please use an image smaller than 10MB.');
    }

    // Check file extension
    final extension = imageFile.path.toLowerCase().split('.').last;
    if (!['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return Left('Unsupported image format. Please use JPG, PNG, GIF, BMP, or WebP.');
    }

    print('Detecting food from image: ${imageFile.path}');

    // Attempt with retry logic
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // Read file bytes with error handling
        List<int> imageBytes;
        try {
          imageBytes = imageFile.readAsBytesSync();
        } catch (e) {
          return Left('Failed to read image file: ${e.toString()}');
        }

        if (imageBytes.isEmpty) {
          return Left('Image file is empty or corrupted');
        }

        final response = await Gemini.instance.textAndImage(
          text: 'You must return ONLY the following JSON format and nothing else: '
                '{"foods": [{"name": "", "calories": 0, "protein": 0, "carbs": 0, "fat": 0}]}. '
                'Do NOT include any explanation, description, code block, markdown, or formatting. '
                'Output exactly one raw JSON object. Analyse all food in the image and provide '
                'nutritional information for exactly 100 grams of each food item. Include all '
                'detected foods in the "foods" array within a single JSON response.',
          images: [imageFile.readAsBytesSync()],
        );

        // Handle null or empty response
        final output = response?.output?.trim();
        if (output == null || output.isEmpty) {
          if (attempt < maxRetries) {
            print('Empty response from Gemini API, retrying... (attempt $attempt)');
            await Future.delayed(Duration(seconds: baseDelaySeconds * attempt));
            continue;
          }
          return Left('No response received from the AI service. Please try again.');
        }

        print('Raw Gemini response: $output');

        // Extract and validate JSON
        String jsonString;
        try {
          // Try to find JSON in the response
          final match = RegExp(r'\{.*\}', dotAll: true).firstMatch(output);
          if (match == null) {
            // If no JSON braces found, check if the entire output is valid JSON
            jsonString = output;
          } else {
            jsonString = match.group(0)!;
          }
        } catch (e) {
          return Left('Failed to extract JSON from response: ${e.toString()}');
        }

        print('Extracted JSON: $jsonString');

        // Parse JSON with detailed error handling
        Map<String, dynamic> foodData;
        try {
          foodData = jsonDecode(jsonString);
        } catch (e) {
          if (attempt < maxRetries) {
            print('JSON parsing failed, retrying... (attempt $attempt): $e');
            await Future.delayed(Duration(seconds: baseDelaySeconds * attempt));
            continue;
          }
          return Left('Invalid response format from AI service. Please try again.');
        }

        // Validate JSON structure
        if (!foodData.containsKey('foods')) {
          return Left('AI response missing "foods" field. Please try again.');
        }

        final foods = foodData['foods'];
        if (foods == null) {
          return Left('No foods field found in response');
        }

        if (foods is! List) {
          return Left('Invalid foods data format in response');
        }

        if (foods.isEmpty) {
          return Left('No food items detected in the image. Please ensure the image contains recognizable food items.');
        }

        // Process detected foods with validation
        List<FoodItem> detectedFoods = [];
        for (int i = 0; i < foods.length; i++) {
          final food = foods[i];
          
          if (food is! Map<String, dynamic>) {
            print('Warning: Skipping invalid food item at index $i');
            continue;
          }

          try {
            // Validate required fields
            final name = food['name']?.toString().trim();
            if (name == null || name.isEmpty) {
              print('Warning: Skipping food item with empty name at index $i');
              continue;
            }

            // Parse nutritional values with defaults
            final calories = _parseNutritionalValue(food['calories'], 'calories');
            final protein = _parseNutritionalValue(food['protein'], 'protein');
            final carbs = _parseNutritionalValue(food['carbs'], 'carbs');
            final fat = _parseNutritionalValue(food['fat'], 'fat');

            // Validate nutritional values are reasonable
            if (calories < 0 || calories > 1000) {
              print('Warning: Unusual calorie value for $name: $calories');
            }

            final foodItem = FoodItem(
              id: '${DateTime.now().millisecondsSinceEpoch}_$i',
              name: name,
              calories: calories,
              protein: protein,
              carbs: carbs,
              fat: fat,
              quantity: 100.0,
              timestamp: DateTime.now(),
            );

            detectedFoods.add(foodItem);
          } catch (e) {
            print('Warning: Error processing food item at index $i: $e');
            continue;
          }
        }

        // Check if we have any valid food items
        if (detectedFoods.isEmpty) {
          return Left('No valid food items could be processed from the image');
        }

        print('Successfully detected ${detectedFoods.length} food items');
        return Right(detectedFoods);

      } catch (e) {
        print('Attempt $attempt failed: $e');
        
        // Handle specific error types
        final errorMessage = e.toString().toLowerCase();
        
        if (errorMessage.contains('503') || 
            errorMessage.contains('server error') ||
            errorMessage.contains('service unavailable')) {
          if (attempt < maxRetries) {
            int delaySeconds = baseDelaySeconds * attempt;
            print('Server is busy, retrying in $delaySeconds seconds...');
            await Future.delayed(Duration(seconds: delaySeconds));
            continue;
          } else {
            return Left('AI service is currently experiencing high traffic. Please try again in a few minutes.');
          }
        } else if (errorMessage.contains('timeout') || 
                   errorMessage.contains('connection')) {
          if (attempt < maxRetries) {
            int delaySeconds = baseDelaySeconds * attempt;
            print('Connection issue, retrying in $delaySeconds seconds...');
            await Future.delayed(Duration(seconds: delaySeconds));
            continue;
          } else {
            return Left('Connection timeout. Please check your internet connection and try again.');
          }
        } else if (errorMessage.contains('rate limit') || 
                   errorMessage.contains('quota')) {
          return Left('API rate limit exceeded. Please wait a moment before trying again.');
        } else if (errorMessage.contains('authentication') || 
                   errorMessage.contains('unauthorized')) {
          return Left('Authentication error. Please check your API configuration.');
        } else {
          // For unknown errors, retry if attempts remain
          if (attempt < maxRetries) {
            int delaySeconds = baseDelaySeconds * attempt;
            print('Unknown error, retrying in $delaySeconds seconds...');
            await Future.delayed(Duration(seconds: delaySeconds));
            continue;
          } else {
            return Left('AI service is currently unavailable. Please try again later.');
          }
        }
      }
    }

    // This should not be reached, but just in case
    return Left('Maximum retry attempts reached. Please try again later.');

  } catch (e) {
    print('Unexpected error in detectMultipleFoodsFromImage: $e');
    
    // Handle file system errors
    if (e.toString().contains('permission') || 
        e.toString().contains('access')) {
      return Left('Permission denied accessing the image file.');
    } else if (e.toString().contains('disk') || 
               e.toString().contains('space')) {
      return Left('Insufficient storage space to process the image.');
    } else {
      return Left('An unexpected error occurred. Please try again.');
    }
  }
}

// Helper method to safely parse nutritional values
double _parseNutritionalValue(dynamic value, String fieldName) {
  if (value == null) return 0.0;
  
  if (value is num) {
    return value.toDouble();
  }
  
  if (value is String) {
    // Remove any non-numeric characters except decimal point
    final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanValue) ?? 0.0;
  }
  
  print('Warning: Unable to parse $fieldName value: $value, defaulting to 0.0');
  return 0.0;
}
}
