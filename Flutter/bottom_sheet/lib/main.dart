import 'package:flutter/material.dart';

import 'bottom_page.dart';
import 'custom_modal_bottom_sheet_route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case BottomPage.routeName:
            return BottomPage.route(settings);
          default:
            return null;
        }
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              child: const Text('showModalBottomSheet'),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  isDismissible: true,
                  useRootNavigator: true,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  builder: (context) {
                    return const BottomPage();
                  },
                );
              },
            ),
            TextButton(
              child: const Text('navigator.push'),
              onPressed: () {
                Navigator.of(context).push(
                  CustomModalBottomSheetRoute(
                    isScrollControlled: false,
                    isDismissible: true,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                    builder: (context) {
                      return const BottomPage();
                    },
                    capturedThemes: InheritedTheme.capture(from: context, to: Navigator.of(context).context),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('navigator.pushNamed'),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  BottomPage.routeName,
                  arguments: BottomPageArguments(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                    capturedThemes: InheritedTheme.capture(from: context, to: Navigator.of(context).context),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
