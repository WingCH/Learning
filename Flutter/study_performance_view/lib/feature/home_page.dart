import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: const Text('Case1, Timer'),
            onTap: () {
              context.go('/case1');
            },
          ),
          ListTile(
            title: const Text('Case2, Lottie'),
            onTap: () {
              context.go('/case2');
            },
          ),
          ListTile(
            title: const Text('Case3, Video'),
            onTap: () {
              context.go('/case3');
            },
          ),
          ListTile(
            title: const Text('Case4, Rive'),
            onTap: () {
              context.go('/case4');
            },
          ),
          ListTile(
            title: const Text('Case5, Video + Lottie'),
            onTap: () {
              context.go('/case5');
            },
          ),
          ListTile(
            title: const Text('Case6, Video'),
            onTap: () {
              context.go('/case6');
            },
          ),
          ListTile(
            title: const Text('Case7, native_video_player'),
            onTap: () {
              context.go('/case7');
            },
          ),
        ],
      ),
    );
  }
}
