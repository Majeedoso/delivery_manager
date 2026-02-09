import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/features/localization/domain/entities/language.dart';
import 'dart:ui' as ui;

abstract class BaseLocalizationLocalDataSource {
  Future<Language> getCurrentLanguage();
  Future<void> setLanguage(Language language);
  Future<List<Language>> getSupportedLanguages();

  /// Check if this is the first time the app is run (no language saved yet)
  Future<bool> isFirstRun();
}

class LocalizationLocalDataSource implements BaseLocalizationLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _languageKey = 'selected_language';

  const LocalizationLocalDataSource({required this.sharedPreferences});

  /// Get the device's default locale language code
  /// Returns the language code from the device's system locale
  String _getDeviceLanguageCode() {
    final deviceLocale = ui.PlatformDispatcher.instance.locale;
    return deviceLocale.languageCode.toLowerCase();
  }

  /// Detect language based on device locale
  ///
  /// If device language is Arabic, English, or French, use it.
  /// Otherwise, default to Arabic.
  Language _detectDeviceLanguage() {
    final deviceLanguageCode = _getDeviceLanguageCode();

    // Map device language to supported language, default to Arabic
    String selectedLanguageCode = 'ar'; // Default to Arabic

    // Check if device language is one of the supported languages (ar, en, fr)
    final supportedCodes = Language.supportedLanguages
        .map((lang) => lang.code)
        .toList();
    if (supportedCodes.contains(deviceLanguageCode)) {
      selectedLanguageCode = deviceLanguageCode;
    }

    // Find the language object
    final language = Language.supportedLanguages.firstWhere(
      (lang) => lang.code == selectedLanguageCode,
      orElse: () =>
          Language.supportedLanguages.first, // Fallback (shouldn't happen)
    );

    return language;
  }

  @override
  Future<bool> isFirstRun() async {
    try {
      final languageCode = sharedPreferences.getString(_languageKey);
      return languageCode == null;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<Language> getCurrentLanguage() async {
    try {
      final languageCode = sharedPreferences.getString(_languageKey);

      // If no language is saved, it's the first launch
      // Detect device language but DON'T save - user will be prompted to choose
      if (languageCode == null) {
        return _detectDeviceLanguage();
      }

      // Language is already set, return it
      final language = Language.supportedLanguages.firstWhere(
        (lang) => lang.code == languageCode,
        orElse: () => Language.supportedLanguages.first,
      );
      return language;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> setLanguage(Language language) async {
    try {
      await sharedPreferences.setString(_languageKey, language.code);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<Language>> getSupportedLanguages() async {
    try {
      return Language.supportedLanguages;
    } catch (e) {
      throw CacheException();
    }
  }
}
