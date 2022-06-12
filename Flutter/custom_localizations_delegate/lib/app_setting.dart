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

  void changeLocale(Locale locale) {
    this.locale = locale;
    whenLocaleChanged?.call();
  }
}
