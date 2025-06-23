import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_riverpod_provider_scope_overrides/mock_sports_service.dart';
import 'package:study_riverpod_provider_scope_overrides/child_service.dart';
import 'package:study_riverpod_provider_scope_overrides/root_service.dart';

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
    final rootData = ref.watch(rootServiceProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Override Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Root Value: ${rootData.value}',
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProviderScope(
                      parent: ProviderScope.containerOf(context),
                      overrides: [
                        rootServiceProvider
                            .overrideWith(MockRootService.new)
                      ],
                      child: const SecondPage(),
                    ),
                  ),
                );
              },
              child: const Text('Go to Second Page with Override'),
            ),
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
    final rootData = ref.watch(rootServiceProvider);
    final childData = ref.watch(childServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Root Value: ${rootData.value}',
            ),
            Text(
              'Child Value: ${childData.value}',
            ),
          ],
        ),
      ),
    );
  }
}
