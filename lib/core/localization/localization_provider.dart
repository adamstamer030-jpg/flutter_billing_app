import 'package:flutter/material.dart';

class LocalizationProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');
  
  Locale get locale => _locale;
  
  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
  
  void toggleLanguage() {
    _locale = _locale.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    notifyListeners();
  }
}
