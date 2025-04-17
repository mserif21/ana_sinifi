import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  final String key = "theme";
  late SharedPreferences prefs;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadFromPrefs();
  }

  _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();
    _isDarkMode = prefs.getBool(key) ?? false;
    notifyListeners();
  }

  _saveToPrefs() async {
    await _initPrefs();
    prefs.setBool(key, _isDarkMode);
  }

  toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveToPrefs();
    notifyListeners();
  }

  ThemeData get themeData => _isDarkMode ? darkTheme : lightTheme;

  static final lightTheme = ThemeData(
    primaryColor: Color(0xFF2E3061),
    scaffoldBackgroundColor: Color(0xFFFEE9CE),
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xFF2E3061),
      iconTheme: IconThemeData(color: Color(0xFFFEE9CE)),
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Color(0xFFFEE9CE),
    ),
    iconTheme: IconThemeData(
      color: Color(0xFF2E3061),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF28293D)),
      bodyMedium: TextStyle(color: Color(0xFF28293D)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(color: Color(0xFF2E3061)),
      hintStyle: TextStyle(color: Color(0xFF28293D).withOpacity(0.5)),
      prefixIconColor: Color(0xFF2E3061),
    ),
  );

  static final darkTheme = ThemeData(
    primaryColor: Color(0xFF555184),
    scaffoldBackgroundColor: Color(0xFF28293D),
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xFF28293D),
      iconTheme: IconThemeData(color: Color(0xFFFEE9CE)),
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Color(0xFF2E3061),
    ),
    iconTheme: IconThemeData(
      color: Color(0xFFFEE9CE),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFFEE9CE)),
      bodyMedium: TextStyle(color: Color(0xFFFEE9CE)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Color(0xFF555184),
      labelStyle: TextStyle(color: Color(0xFFFEE9CE)),
      hintStyle: TextStyle(color: Color(0xFFFEE9CE).withOpacity(0.5)),
      prefixIconColor: Color(0xFFFEE9CE),
    ),
  );
} 