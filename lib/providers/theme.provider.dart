import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/legacy.dart';

// Key to store the theme preference
const String themePreferenceKey = 'theme_mode';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  // Load the saved theme from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(themePreferenceKey);

    if (themeIndex != null) {
      state = ThemeMode.values[themeIndex];
    }
  }

  // Toggle between light and dark themes
  void toggleTheme() async {
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.light;
    }
    _saveTheme();
  }

  // Set theme directly and save it
  void setTheme(ThemeMode mode) async {
    state = mode;
    _saveTheme();
  }

  // Save the current theme to SharedPreferences
  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(themePreferenceKey, state.index);
  }
}
