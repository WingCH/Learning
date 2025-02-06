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
            title: const Text('Case1'),
            onTap: () {
              context.go('/case1');
            },
          ),
          ListTile(
            title: const Text('Case2'),
            onTap: () {
              context.go('/case2');
            },
          ),
        ],
      ),
    );
  }
}
