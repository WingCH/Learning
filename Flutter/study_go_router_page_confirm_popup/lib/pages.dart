import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The home screen
class HomeScreen extends StatelessWidget {
  /// Constructs a [HomeScreen]
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                final pageAResult = await context.push('/pageA');
                print('[HomeScreen] pageAResult: $pageAResult');
              },
              child: const Text('Push to the PageA screen'),
            ),
          ],
        ),
      ),
    );
  }
}

class PageA extends StatelessWidget {
  const PageA({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PageA Screen')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final pageBResult = await context.push('/pageB');
                print('[PageA] pageBResult: $pageBResult');
              },
              child: const Text('Push to the PageB screen'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.pop('this is a result from PageA'),
              child: const Text('Pop'),
            ),
          ],
        ),
      ),
    );
  }
}

class PageB extends StatelessWidget {
  const PageB({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PageB Screen')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.pop('This is a result from PageB'),
              child: const Text('Pop'),
            ),
          ],
        ),
      ),
    );
  }
}
