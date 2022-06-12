import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_localizations.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  static List<Locale> supportedLocales = [
    const Locale('zh'),
    const Locale('en'),
  ];

  @override
  bool isSupported(Locale locale) {
    return supportedLocales.contains(locale);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  /*
  Because to support dynamic changes Localization (AppLocalizations -> localizedValues)
   original:  en -> en (not need reload)
   new: en -> en (need reload)
   */
  @override
  bool shouldReload(AppLocalizationsDelegate old) => true;
}
