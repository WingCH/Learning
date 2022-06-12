import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_localizations.dart';
import 'app_localizations_delegate.dart';
import 'app_setting.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    AppSetting.instance.whenLocaleChanged = () {
      setState(() {});
    };
    AppSetting.instance.whenLocalizedValuesChanged = () {
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom localizations delegate',
      locale: AppSetting.instance.locale,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizationsDelegate.supportedLocales,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom localizations delegate'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Locale: ${Localizations.localeOf(context)}'),
            Text(AppLocalizations.of(context).title),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    AppSetting.instance.changeLocale(const Locale('en'));
                  },
                  child: const Text('change to english'),
                ),
                TextButton(
                  onPressed: () {
                    AppSetting.instance.changeLocale(const Locale('zh'));
                  },
                  child: const Text('change to chinese'),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                AppSetting.instance.changeLocalizedValues();
              },
              child: const Text('change localized values'),
            ),
          ],
        ),
      ),
    );
  }
}
