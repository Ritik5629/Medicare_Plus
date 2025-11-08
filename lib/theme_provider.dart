import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = ThemeData.light();
  bool _isDarkMode = false;

  ThemeData getTheme() => _themeData;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    if (_isDarkMode) {
      _themeData = ThemeData.dark().copyWith(
        primaryColor: Colors.blue.shade800,
        scaffoldBackgroundColor: Colors.grey.shade900,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade800,
          elevation: 0,
        ),
        cardTheme: CardThemeData( // Fixed: Changed to CardThemeData
          color: Colors.grey.shade800,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
    } else {
      _themeData = ThemeData.light().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade100,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          elevation: 0,
        ),
        cardTheme: CardThemeData( // Fixed: Changed to CardThemeData
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
    }
    _saveTheme();
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    // Load the theme preference from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;

    if (_isDarkMode) {
      _themeData = ThemeData.dark().copyWith(
        primaryColor: Colors.blue.shade800,
        scaffoldBackgroundColor: Colors.grey.shade900,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade800,
          elevation: 0,
        ),
        cardTheme: CardThemeData( // Fixed: Changed to CardThemeData
          color: Colors.grey.shade800,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
    } else {
      _themeData = ThemeData.light().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade100,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          elevation: 0,
        ),
        cardTheme: CardThemeData( // Fixed: Changed to CardThemeData
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
    }
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    // Save the theme preference to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
}