import 'package:flutter/material.dart';
import '../ColorHelper.dart';

class ThemeHelper {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: ColorHelper.primaryColor,
      scaffoldBackgroundColor: ColorHelper.backgroundColor,

      fontFamily: 'Roboto', // Change if you use a custom font
      appBarTheme: AppBarTheme(
        backgroundColor: ColorHelper.backgroundColor,
        foregroundColor: ColorHelper.textColor,
        titleTextStyle: TextStyle(
          color: ColorHelper.textColor,
          fontWeight: FontWeight.bold,
          fontSize: 24,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(color: ColorHelper.textColor),
        elevation: 0,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: ColorHelper.textColor,
          fontFamily: 'Roboto',
        ),
        bodyMedium: TextStyle(
          color: ColorHelper.textColor,
          fontFamily: 'Roboto',
        ),
        // Add more as needed
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: ColorHelper.accentColor,
        error: ColorHelper.errorColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: Colors.black),
        hintStyle: TextStyle(color: Colors.black54),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
    );
  }
}
