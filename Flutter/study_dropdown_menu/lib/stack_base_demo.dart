import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StackBaseDemo extends StatelessWidget {
  const StackBaseDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dropdown Menu Demo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            color: Colors.red,
            child: Center(
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.filter_list),
              ),
            ),
          )
        ],
      ),
    );
  }
}
