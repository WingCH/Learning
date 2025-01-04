import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DemoList extends StatelessWidget {
  const DemoList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dropdown Menu Demo'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Stack Base Demo'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.go('/stack-base');
            },
          ),
        ],
      ),
    );
  }
}
