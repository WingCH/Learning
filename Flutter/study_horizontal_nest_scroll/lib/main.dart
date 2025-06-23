import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Horizontal Nest Scroll Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HorizontalNestScrollPage(),
    );
  }
}

class HorizontalNestScrollPage extends StatelessWidget {
  const HorizontalNestScrollPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Horizontal Nest Scroll'),
      ),
      body: const NestedHorizontalScrollView(),
    );
  }
}

class NestedHorizontalScrollView extends StatelessWidget {
  const NestedHorizontalScrollView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '外層橫向滾動，每個項目內部也有橫向滾動',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              return Container(
                width: 300,
                margin: const EdgeInsets.only(right: 16),
                child: OuterScrollItem(
                  title: '外層項目 ${index + 1}',
                  itemIndex: index,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class OuterScrollItem extends StatelessWidget {
  const OuterScrollItem({
    super.key,
    required this.title,
    required this.itemIndex,
  });

  final String title;
  final int itemIndex;

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    final primaryColor = colors[itemIndex % colors.length];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '內部橫向滾動項目：',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: InnerHorizontalScrollView(
                primaryColor: primaryColor,
                itemCount: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InnerHorizontalScrollView extends StatelessWidget {
  const InnerHorizontalScrollView({
    super.key,
    required this.primaryColor,
    required this.itemCount,
  });

  final Color primaryColor;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          width: 120,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryColor.withOpacity(0.3)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: primaryColor,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  '項目 ${index + 1}',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
