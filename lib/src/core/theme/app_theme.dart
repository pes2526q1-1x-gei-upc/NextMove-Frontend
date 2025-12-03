import 'package:flutter/material.dart';

class AppTheme {
  static const Color seedColor = Color(0xFF2ABB72);

  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F7),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F5F7),
      foregroundColor: Color(0xFF1A1A1A),
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: seedColor,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
    dividerColor: const Color(0xFFE0E0E0),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF333333),
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0E1116),
    cardColor: const Color(0xFF1C1F26),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0E1116),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF151821),
      selectedItemColor: seedColor,
      unselectedItemColor: Colors.white70,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
    dividerColor: const Color(0xFF2C2F36),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF2C2F36),
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(0xFF1C1F26),
    ),
    useMaterial3: true,
  );
}

