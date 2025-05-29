import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_riverpod_provider_scope_overrides/mock_sports_service.dart';
import 'package:study_riverpod_provider_scope_overrides/other_service.dart';
import 'package:study_riverpod_provider_scope_overrides/sports_service.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Riverpod Override Example',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sportsData = ref.watch(sportsServiceProvider);
    final otherData = ref.watch(otherServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Override Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Other Value: ${otherData.value}',
              textAlign: TextAlign.center,
            ),
            Text(
              'Sport: ${sportsData.sport}',
            ),
            Text(
              'Description: ${sportsData.description}',
              textAlign: TextAlign.center,
            ),
            Text(
              'Other Value: ${sportsData.otherValue}',
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProviderScope(
                      overrides: [
                        sportsServiceProvider.overrideWith(MockSportsService.new)
                      ],
                      child: const SecondPage(),
                    ),
                  ),
                );
              },
              child: const Text('Go to Second Page with Override'),
            ),
            ElevatedButton(
                onPressed: () {
                  ref.read(otherServiceProvider.notifier).updateValue('New Value');
                },
                child: const Text('Update Other Value'))
          ],
        ),
      ),
    );
  }
}

class SecondPage extends ConsumerWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sportsData = ref.watch(sportsServiceProvider);
    final otherData = ref.watch(otherServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sport: ${sportsData.sport}',
            ),
            Text(
              'Description: ${sportsData.description}',
              textAlign: TextAlign.center,
            ),
            Text(
              'Other Value: ${sportsData.otherValue}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
