import 'package:flutter/material.dart';

class AppSetting {
  // just to ease the demonstration
  // should be avoided use singleton
  static final AppSetting _singleton = AppSetting._internal();

  static AppSetting get instance => _singleton;

  factory AppSetting() {
    return _singleton;
  }

  AppSetting._internal() : locale = const Locale('en');

  Locale locale;
  VoidCallback? whenLocaleChanged;
  VoidCallback? whenLocalizedValuesChanged;
  Map<String, Map<String, String>> localizedValues = {
    'en': {
      'title': 'Hello World',
    },
    'zh': {
      'title': '你好',
    },
  };

  void changeLocale(Locale locale) {
    this.locale = locale;
    whenLocaleChanged?.call();
  }

  void changeLocalizedValues() {
    localizedValues = {
      'en': {
        'title': 'Hong Kong',
      },
      'zh': {
        'title': '香港',
      },
    };
    whenLocalizedValuesChanged?.call();
  }
}
