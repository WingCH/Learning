import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_go_router_page_confirm_popup/build_context_ext.dart';
import 'package:study_go_router_page_confirm_popup/ios_swiper_gesture_detector.dart';

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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        print('[PageA] onPopInvokedWithResult: $didPop, $result');
        if (didPop) {
          return;
        }
        context.showNavigationConfirmDialog(
          title: '確認',
          content: '是否要離開此頁面？ trigger by onPopInvokedWithResult',
          onConfirm: () {
            Navigator.of(context).pop();
          },
          onCancel: () {},
        );
      },
      child: IOSSwiperGestureDetector(
        onSwipe: () {
          context.showNavigationConfirmDialog(
            title: '確認',
            content: '是否要離開此頁面？ trigger by onPopInvokedWithResult',
            onConfirm: () {
              Navigator.of(context).pop();
            },
            onCancel: () {},
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
                  onPressed: () async {
                    final pageAResult = await context.push('/pageA');
                    print('[PageA] pageAResult: $pageAResult');
                  },
                  child: const Text('Push to the PageA screen'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final pageBResult = await context.push('/pageB');
                    print('[PageA] pageBResult: $pageBResult');
                  },
                  child: const Text('Push to the PageB screen'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    context.pushReplacement('/pageA');
                  },
                  child: const Text('GoRouter pushReplacement'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    context.pop('this is a result from PageA');
                  },
                  child: const Text('GoRouter pop'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .maybePop('this is a result from PageA');
                  },
                  child: const Text('Navigator maybePop'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop('this is a result from PageA');
                  },
                  child: const Text(
                      'Navigator pop (cannot intercept by GoRouter and PopScope)'),
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
              onPressed: () => context.pop('This is a result from PageB'),
              child: const Text('Pop'),
            ),
          ],
        ),
      ),
    );
  }
}
