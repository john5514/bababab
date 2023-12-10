import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true, // Enable Material 3
  fontFamily: 'Inter',

  // Define the basic color scheme
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFFFA726), // Orange shade as primary color
    onPrimary: Colors.white, // Text on primary color
    secondary: Color(0xFF66BB6A), // Green shade as secondary color
    onSecondary: Colors.white, // Text on secondary color
    error: Color.fromARGB(255, 208, 75, 95), // Default error color
    onError: Colors.black, // Text on error color
    background: Color(0xFF22262F), // Your specific background color
    onBackground: Colors.white, // Text on background color
    surface: Color(0xFF37474F), // Surface color
    onSurface: Colors.white, // Primary variant
  ),

  // Text Selection Theme
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color(0xFFFFA726), // Using primary color for cursor
    selectionColor: Color(0xFF66BB6A),
    selectionHandleColor: Color(0xFFFFA726),
  ),

  // Text Theme
  textTheme: Typography.material2021(platform: TargetPlatform.android)
      .black
      .apply(
        displayColor: Colors.white, // White text for better contrast
        bodyColor: Colors.white,
      )
      .copyWith(
        displayLarge: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
        titleMedium: const TextStyle(
          fontSize: 12,
          color: Color.fromRGBO(
              214, 214, 214, 1), // Lighter grey for better visibility
        ),
      ),

  // Input Decoration Theme
  inputDecorationTheme: const InputDecorationTheme(
    labelStyle: TextStyle(color: Colors.white),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFFFA726)), // Primary color border
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
  ),

  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFFFA726), // Primary color background
      foregroundColor: Colors.white, // Text color on buttons
      elevation: 6.0,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
    ),
  ),

  // Scaffold Background Color
  scaffoldBackgroundColor: const Color(0xFF22262F),

  // Floating Action Button Theme
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFFFA726), // Primary color
  ),
);
