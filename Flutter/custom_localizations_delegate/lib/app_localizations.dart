import 'package:flutter/material.dart';

import 'app_setting.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  final Map<String, Map<String, String>> _localizedValues =
      AppSetting.instance.localizedValues;

  String get title {
    return _localizedValues[locale.languageCode]?['title'] ?? 'title';
  }
}
