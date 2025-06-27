import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() => runApp(const MaterialApp(home: HorizontalScrollDemo()));

class HorizontalScrollDemo extends StatelessWidget {
  const HorizontalScrollDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('水平滾動範例'),
      ),
      body: Center(
        child: Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('分享動作')),
                  );
                },
                backgroundColor: const Color(0xFF21B7CA),
                foregroundColor: Colors.white,
                icon: Icons.share,
                label: '分享',
              ),
            ],
          ),
          child: Container(
            height: 200,
            width: 200,
            color: Colors.grey[300],
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Placeholder(
                  fallbackHeight: 100,
                  fallbackWidth: 100,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(4, (index) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Placeholder(
                            fallbackWidth: 100,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
