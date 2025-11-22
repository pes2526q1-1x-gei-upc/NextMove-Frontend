import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale; // null means use system locale

  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale != locale) {
      if (kDebugMode) {
        print('Changing locale from $_locale to $locale');
      }
      _locale = locale;
      notifyListeners();
    }
  }

  void setLocaleFromLanguage(String language) {
    Locale newLocale;
    switch (language.toLowerCase()) {
      case 'español':
        newLocale = const Locale('es');
        break;
      case 'english':
        newLocale = const Locale('en');
        break;
      case 'català':
        newLocale = const Locale('ca');
        break;
      default:
        newLocale = const Locale('es');
    }
    if (kDebugMode) {
      print('Setting locale from language: $language -> $newLocale');
    }
    setLocale(newLocale);
  }

  void setLocaleFromAPILanguage(String? apiLanguage) {
    Locale newLocale;
    switch (apiLanguage?.toUpperCase()) {
      case 'ESP':
        newLocale = const Locale('es');
        break;
      case 'ENG':
        newLocale = const Locale('en');
        break;
      case 'CAT':
        newLocale = const Locale('ca');
        break;
      default:
        newLocale = const Locale('es');
    }
    setLocale(newLocale);
  }

  void clearLocale() {
    if (_locale != null) {
      if (kDebugMode) {
        print('Clearing locale to use system default');
      }
      _locale = null;
      notifyListeners();
    }
  }
}