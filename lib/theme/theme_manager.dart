import 'package:flutter/material.dart';

class ThemeManager extends ChangeNotifier {
  // The current theme mode (either light or dark)
  ThemeMode _themeMode;

  // Constructor to initialize the theme mode
  ThemeManager({ThemeMode initialThemeMode = ThemeMode.light})
      : _themeMode = initialThemeMode;

  // Getter for the current theme mode
  ThemeMode get themeMode => _themeMode;

  // Method to toggle between light and dark theme modes
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notify all listeners about the theme change
  }
}