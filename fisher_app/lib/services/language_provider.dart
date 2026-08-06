import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void toggle() {
    _locale = _locale.languageCode == 'en' ? const Locale('sw') : const Locale('en');
    notifyListeners();
  }

  String t(String en, String sw) {
    return _locale.languageCode == 'sw' ? sw : en;
  }
}
