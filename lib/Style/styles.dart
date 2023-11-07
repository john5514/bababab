import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  fontFamily: 'Inter',
  primaryColor: Colors.black,
  secondaryHeaderColor: Colors.white,
  hintColor: Colors.orange,
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.white,
  ),
  textTheme: Typography.material2021().black.copyWith(
        displayLarge: const TextStyle(
          fontSize: 24, // Reduced from 32
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: const TextStyle(
          fontSize: 14, // Reduced from 18
          color: Colors.white,
        ),
        //make gray color
        titleMedium: const TextStyle(
          fontSize: 12, // Reduced from 18
          color: Colors.grey,
        ),
      ),
  inputDecorationTheme: const InputDecorationTheme(
    labelStyle: TextStyle(color: Colors.white),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.orange),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orange,
      elevation: 6.0,
      disabledForegroundColor: Colors.grey,
      disabledBackgroundColor: Colors.grey,
      enabledMouseCursor: SystemMouseCursors.click,
      disabledMouseCursor: SystemMouseCursors.forbidden,
      padding: const EdgeInsets.symmetric(
          vertical: 12.0, horizontal: 20.0), // Added padding
    ),
  ),
  scaffoldBackgroundColor: const Color(0xFF22262F),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.orange,
  ),
);
