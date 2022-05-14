import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:native_shared_preferences/native_shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String defaultLocale = Platform.localeName;
  final List<Locale> systemLocales = window.locales;
  List<String> appleLanguages = [];

  @override
  void initState() {
    super.initState();
    getAppleLanguages();
  }

  Future<void> getAppleLanguages() async {
    final prefs = await NativeSharedPreferences.getInstance();
    setState(() {
      appleLanguages = prefs.getStringList('AppleLanguages') ?? [];
    });
  }

  Future<void> setAppleLanguages() async {
    // This plugin is a copy of the shared_preferences package but without the prefix in the keys
    final prefs = await NativeSharedPreferences.getInstance();
    // https://docs.flutter.dev/development/accessibility-and-localization/internationalization#specifying-supportedlocales
    await prefs.setStringList('AppleLanguages', <String>[
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
          .toString()
    ]);

    /*
    Apple Locale format:
    zh-Hant
    flutter locale toString format:
    zh_Hant
     */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'defaultLocale',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(defaultLocale),
            Text(
              'systemLocales (PREFERRED LANGUAGE ORDER)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(systemLocales.toString()),
            Text(
              'AppleLanguages',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(appleLanguages.toString()),
            TextButton(
              onPressed: setAppleLanguages,
              child: const Text('Set AppleLanguages'),
            ),
            TextButton(
              onPressed: getAppleLanguages,
              child: const Text('Get AppleLanguages'),
            )
          ],
        ),
      ),
    );
  }
}
