import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  bool _isDarkMode;
  bool get isDarkMode => _isDarkMode;
  
  static const String _themeKey = 'is_dark_mode';

  ThemeController({bool initialTheme = false}) : _isDarkMode = initialTheme {
    // Load theme preference to ensure it's in sync
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getBool(_themeKey);
      if (savedTheme != null && savedTheme != _isDarkMode) {
        _isDarkMode = savedTheme;
        notifyListeners();
      }
    } catch (e) {
      // If there's an error loading, keep current state
      // This can happen during hot reload or if the plugin isn't ready
      print('Error loading theme (non-critical): $e');
    }
  }

  Future<void> _saveTheme(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDark);
    } catch (e) {
      // Silently handle save errors - theme will still work, just won't persist
      // This can happen during hot reload or if the plugin isn't ready
      print('Error saving theme (non-critical): $e');
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveTheme(_isDarkMode);
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    await _saveTheme(_isDarkMode);
    notifyListeners();
  }
}
