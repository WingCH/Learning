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
                // Calculate the extent ratio based on screen width
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

// Tutorial page that demonstrates slidable bookmark functionality
class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> with SingleTickerProviderStateMixin {
  AnimationController? controller;
  Animation<double>? animation;
  bool tutorialCompleted = false;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      upperBound: 1.0,
    );
    // Create animation for tutorial sliding effect
    animation = Tween<double>(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(
        parent: controller!,
        curve: Curves.easeInOut,
      )
    );
    
    // Start tutorial sequence after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTutorialSequence();
    });
    
    // Update tutorial state when animation is complete
    controller?.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          tutorialCompleted = true;
        });
      }
    });
  }
  
  // Handle the tutorial animation sequence
  void _startTutorialSequence() async {
    await controller!.forward().orCancel;
    await Future.delayed(const Duration(milliseconds: 600));
    await controller?.reverse().orCancel;
  }
  
  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial Page'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            color: tutorialCompleted ? Colors.green.shade100 : Colors.blue.shade100,
            child: Text(
              tutorialCompleted ? 'Tutorial Completed' : 'Please Complete Tutorial',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: tutorialCompleted ? Colors.green.shade900 : Colors.blue.shade900,
              ),
            ),
          ),
          Expanded(
            child: SlidablePlayer(
              animation: animation,
              child: ListView(
                children: [
                  // Slidable items with tutorial highlight for the first three items
                  SlidableBookmarkItem(
                    index: 0,
                    extentRatio: 0.2,
                    onTap: (context) {},
                    onTapTextButton: (context) {
                      print('TextButton Item 0 tapped');
                    },
                    showTutorial: !tutorialCompleted,
                  ),
                  SlidableBookmarkItem(
                    index: 1,
                    extentRatio: 0.2,
                    onTap: (context) {},
                    onTapTextButton: (context) {
                      print('TextButton Item 1 tapped');
                    },
                    showTutorial: !tutorialCompleted,
                  ),
                  SlidableBookmarkItem(
                    index: 2,
                    extentRatio: 0.2,
                    onTap: (context) {},
                    onTapTextButton: (context) {
                      print('TextButton Item 2 tapped');
                    },
                    showTutorial: !tutorialCompleted,
                  ),
                  // Fourth item without tutorial highlight
                  SlidableBookmarkItem(
                    index: 3,
                    extentRatio: 0.2,
                    onTap: (context) {},
                    onTapTextButton: (context) {
                      print('TextButton Item 3 tapped');
                    },
                    showTutorial: false,
                  ),
                ],
              )
            ),
          ),
        ],
      ),
    );
  }
}
