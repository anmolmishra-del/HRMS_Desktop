import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hrms_desktop/generated/l10n/app_localizations.dart' as gen;

// Expose the generated localization types so they can be used, but NOT the nullable 'AppLocalizations' class directly.
// This allows us to provide a custom non-nullable `AppLocalizations.of(context)` helper!
export 'package:hrms_desktop/generated/l10n/app_localizations.dart' show AppLocalizationsEn, AppLocalizationsHi, AppLocalizationsTe;

class AppLocalizations {
  /// Custom non-nullable helper for getting localized strings.
  static gen.AppLocalizations of(BuildContext context) {
    return gen.AppLocalizations.of(context)!;
  }

  static List<Locale> get supportedLocales => gen.AppLocalizations.supportedLocales;

  static List<LocalizationsDelegate<dynamic>> get localizationsDelegates => gen.AppLocalizations.localizationsDelegates;

  static LocalizationsDelegate<gen.AppLocalizations> get delegate => gen.AppLocalizations.delegate;
}

class AppLocalization extends ChangeNotifier {
  static final AppLocalization _instance = AppLocalization._internal();
  factory AppLocalization() => _instance;
  AppLocalization._internal();

  static List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  static List<LocalizationsDelegate<dynamic>> get localizationsDelegates => AppLocalizations.localizationsDelegates;

  Locale _currentLocale = const Locale('en');
  bool _isInitialized = false;

  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;

  static const String _localeKey = 'app_locale';

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString(_localeKey);
      
      if (savedLanguageCode != null) {
        final supportedLocale = supportedLocales.firstWhere(
          (locale) => locale.languageCode == savedLanguageCode,
          orElse: () => supportedLocales.first,
        );
        _currentLocale = supportedLocale;
      }
      _isInitialized = true;
    } catch (e) {
      _isInitialized = true;
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.any((l) => l.languageCode == locale.languageCode)) return;
    if (_currentLocale.languageCode == locale.languageCode) return;
    
    _currentLocale = locale;
    await _saveLocale();
    notifyListeners();
  }

  Future<void> setLocaleByLanguageCode(String languageCode) async {
    final locale = Locale(languageCode);
    await setLocale(locale);
  }

  Future<void> _saveLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, _currentLocale.languageCode);
    } catch (e) {
      // Handle error silently
    }
  }

  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'Hindi';
      case 'te':
        return 'Telugu';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  String getLanguageNativeName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिन्दी';
      case 'te':
        return 'తెలుగు';
      default:
        return locale.languageCode.toUpperCase();
    }
  }
}
