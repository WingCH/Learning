import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidable_bookmarks/slidable_bookmark_item.dart';
import 'package:slidable_bookmarks/slidable_tutorial_player.dart';

// Entry point of the application
void main() {
  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

// Main application widget
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      routes: {
        '/tutorial': (context) => const TutorialPage(),
      },
    );
  }
}

// Home page containing a list of slidable bookmark items
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
                return ListView.builder(
                  itemCount: 100,
                  itemBuilder: (context, index) {
                    return SlidableBookmarkItem(
                      index: index,
                      minWidth: 80,
                      onTap: (context) {
                        Navigator.pushNamed(context, '/tutorial');
                      },
                      onTapTextButton: (context) {
                        print('TextButton Item $index tapped');
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/tutorial');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Tutorial page that demonstrates slidable bookmark functionality
class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial Page'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SlidablePlayer(
              tutorialCount: 3,
              enableTutorial: true,
              child: ListView.builder(
                itemCount: 100,
                itemBuilder: (context, index) {
                  return SlidableBookmarkItem(
                      index: index,
                      minWidth: 80,
                      onTap: (context) {},
                      onTapTextButton: (context) {
                        print('TextButton Item $index tapped');
                      },
                    );
                  },
                ),
              ),
          ),
        ],
      ),
    );
  }
}
