// lib/providers/locale_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('en'); // Default to English

  LocaleProvider() {
    _loadLocale(); // Load saved preference on initialization
  }

  Locale get currentLocale => _currentLocale;

  // Method to change the locale and notify listeners
  Future<void> changeLocale(Locale newLocale) async {
    if (_currentLocale == newLocale) return; // Avoid unnecessary changes

    _currentLocale = newLocale;
    notifyListeners(); // This triggers rebuilds in widgets listening

    // Save the preference
    await _saveLocalePreference(newLocale.languageCode);
  }

  // --- Persistence using Shared Preferences ---

  Future<void> _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Get saved language code, default to 'en' if none is saved
    String languageCode = prefs.getString('languageCode') ?? 'en';
    _currentLocale = Locale(languageCode);
    // No need to notifyListeners here initially, as it's set before first build
  }

  Future<void> _saveLocalePreference(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
  }

  loadLocale() {}

  void setLocale(Locale langCode) {}
}