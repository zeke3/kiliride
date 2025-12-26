import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'en_US';

  /// Get the saved language code from SharedPreferences
  static Future<String> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? _defaultLanguage;
  }

  /// Save the language code to SharedPreferences
  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  /// Change the app language and update GetX locale
  static Future<void> changeLanguage(String languageCode) async {
    // Save to SharedPreferences
    await saveLanguage(languageCode);
    print("LANGUAGE CODE: $languageCode");
    // Update GetX locale
    final locale = _getLocaleFromLanguageCode(languageCode);
    Get.updateLocale(locale);
  }

  /// Convert language code to Locale object
  static Locale _getLocaleFromLanguageCode(String languageCode) {
    final parts = languageCode.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
    return const Locale('en', 'US'); // fallback
  }

  /// Get the current locale from language code
  static Locale getLocaleFromLanguageCode(String languageCode) {
    return _getLocaleFromLanguageCode(languageCode);
  }

  /// Get current language code
  static String getCurrentLanguageCode() {
    final locale = Get.locale ?? const Locale('en', 'US');
    return '${locale.languageCode}_${locale.countryCode}';
  }

  /// Initialize language on app startup
  static Future<void> initializeLanguage() async {
    final savedLanguageCode = await getSavedLanguage();
    final locale = _getLocaleFromLanguageCode(savedLanguageCode);
    Get.updateLocale(locale);
  }
}
