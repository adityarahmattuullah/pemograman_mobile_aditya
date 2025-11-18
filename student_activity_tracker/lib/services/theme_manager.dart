import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  bool isDark = false;

  ThemeManager() {
    loadTheme();
  }

  void toggleTheme() {
    isDark = !isDark;
    saveTheme();
    notifyListeners();
  }

  Future<void> saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("dark_mode", isDark);
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDark = prefs.getBool("dark_mode") ?? false;
    notifyListeners();
  }
}
