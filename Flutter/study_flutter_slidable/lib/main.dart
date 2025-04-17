import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidable_bookmarks/slidable_bookmark_item.dart';
import 'package:slidable_bookmarks/slidable_tutorial_player.dart';

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
    return MaterialApp(
      home: const HomePage(),
      routes: {
        '/tutorial': (context) => const TutorialPage(),
      },
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
                    return SlidableBookmarkItem(
                      index: index,
                      extentRatio: extentRatio,
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
    );
  }
}

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage>  with SingleTickerProviderStateMixin  {
    AnimationController? controller;
    Animation<double>? animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      upperBound: 1.0,
    );
    animation = Tween<double>(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(
        parent: controller!,
        curve: Curves.easeInOut,
      )
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial Page'),
      ),
      body: SlidablePlayer(
        animation: animation,
        child: ListView(
            children:  [
              SlidableBookmarkItem(
                index: 0,
                extentRatio: 0.2,
                onTap: (context) {},
                onTapTextButton: (context) {},
                showTutorial: true,
              ),
              SlidableBookmarkItem(
                index: 1,
                extentRatio: 0.2,
                onTap: (context) {},
                onTapTextButton: (context) {},
                showTutorial: true,
              ),
              SlidableBookmarkItem(
                index: 2,
                extentRatio: 0.2,
                onTap: (context) {},
                onTapTextButton: (context) {},
                showTutorial: true,
              ),
              SlidableBookmarkItem(
                index: 3,
                extentRatio: 0.2,
                onTap: (context) {},
                onTapTextButton: (context) {},
                showTutorial: false,
              ),
            ],
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (controller!.isCompleted) {
            controller!.reverse();
          } else if (controller!.isDismissed) {
            controller!.forward();
          }
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
