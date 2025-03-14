import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_go_router_page_confirm_popup/build_context_ext.dart';

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
              onPressed: () => context.push('/pageA'),
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
    // TODO: Only for iOS is ok, android can ignore this
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        //set the sensitivity for your ios gesture anywhere between 10-50 is good
        int sensitivity = 20;
        // print(details.delta.dx);

        if (details.delta.dx > sensitivity) {
          context.showNavigationConfirmDialog(
            title: '確認返回',
            content: '你確定要離開當前頁面嗎？\nTrigger by PopScope.onPopInvokedWithResult',
            onConfirm: () => Navigator.pop(
                context), // don't use context.pop(), because it will trigger GoRouter.pop
          );
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          debugPrint('onPopInvokedWithResult: $didPop, $result');
          if (didPop) {
            return;
          }
          context.showNavigationConfirmDialog(
            title: '確認返回',
            content: '你確定要離開當前頁面嗎？\nTrigger by PopScope.onPopInvokedWithResult',
            onConfirm: () => Navigator.pop(
                context), // don't use context.pop(), because it will trigger GoRouter.pop
          );
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('PageA Screen')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context.push('/pageB'),
                  child: const Text('Push to the PageB screen'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Pop'),
                ),
              ],
            ),
          ),
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
              onPressed: () => context.pop('/'),
              child: const Text('Pop'),
            ),
          ],
        ),
      ),
    );
  }
}
