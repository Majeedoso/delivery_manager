import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  final SharedPreferences _sharedPreferences;
  static const String _themeKey = 'theme_mode';
  
  final StreamController<ThemeMode> _themeController = StreamController<ThemeMode>.broadcast();
  
  // Stream to listen to theme changes
  Stream<ThemeMode> get themeStream => _themeController.stream;
  
  // Current theme mode
  ThemeMode _currentTheme = ThemeMode.system;
  ThemeMode get currentTheme => _currentTheme;
  
  // Constructor that accepts SharedPreferences (same pattern as language)
  ThemeService(this._sharedPreferences);
  
  // Initialize theme service - loads saved theme from SharedPreferences
  Future<void> init() async {
    final savedTheme = _sharedPreferences.getString(_themeKey);
    
    if (savedTheme != null) {
      _currentTheme = ThemeMode.values.firstWhere(
        (mode) => mode.name == savedTheme,
        orElse: () => ThemeMode.system,
      );
    }
    
    _themeController.add(_currentTheme);
  }
  
  // Set theme mode and save to SharedPreferences (same pattern as language)
  Future<void> setTheme(ThemeMode theme) async {
    _currentTheme = theme;
    await _sharedPreferences.setString(_themeKey, theme.name);
    _themeController.add(_currentTheme);
  }
  
  // Toggle between light and dark
  Future<void> toggleTheme() async {
    if (_currentTheme == ThemeMode.light) {
      await setTheme(ThemeMode.dark);
    } else if (_currentTheme == ThemeMode.dark) {
      await setTheme(ThemeMode.light);
    } else {
      // If system, default to light
      await setTheme(ThemeMode.light);
    }
  }
  
  // Get theme mode display name (English default)
  String getThemeDisplayName(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
  
  // Get theme mode display name with localization
  String getThemeDisplayNameLocalized(ThemeMode theme, dynamic localizations) {
    switch (theme) {
      case ThemeMode.light:
        return localizations.light;
      case ThemeMode.dark:
        return localizations.dark;
      case ThemeMode.system:
        return localizations.system;
    }
  }
  
  // Get theme mode icon
  IconData getThemeIcon(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
  
  // Dispose resources
  void dispose() {
    _themeController.close();
  }
}
