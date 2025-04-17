import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_flutter_slidable/bookmark_list_item.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final extentRatio = 80 / constraints.maxWidth;
                return ListView.builder(
                  itemCount: 100,
                  itemBuilder: (context, index) {
                    return BookmarkListItem(index: index, extentRatio: extentRatio);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
