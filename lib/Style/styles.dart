import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: Colors.black,
  hintColor: Colors.orange,
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.white,
  ),
  textTheme: Typography.material2021().black.copyWith(
        displayLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: const TextStyle(
          fontSize: 18,
          color: Colors.white,
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
      shadowColor: Colors.red,
      enabledMouseCursor: SystemMouseCursors.click,
      disabledMouseCursor: SystemMouseCursors.forbidden,
    ),
  ),
  scaffoldBackgroundColor: Colors.black,
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.orange,
  ),
);
