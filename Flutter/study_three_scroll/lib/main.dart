import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _rootScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _rootScrollController,
        physics: ClampingScrollPhysics(),
        slivers: [
          PinnedHeaderSliver(
            child: Section(
              name: 'Navigation Bar',
              height: 100,
              color: Colors.red,
            ),
          ),
          SliverToBoxAdapter(
            child: Section(name: 'Scoreboard', height: 100, color: Colors.blue),
          ),
          SliverToBoxAdapter(
            child: Section(
              name: 'Video',
              height: MediaQuery.sizeOf(context).width * 9 / 16,
              color: Colors.green,
            ),
          ),
          MultiScrollBodySliver(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _rootScrollController,
                    padding: EdgeInsets.zero,
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Section(
                        name: 'Item $index',
                        height: 100,
                        color: Colors.primaries[index % Colors.primaries.length],
                      );
                    },
                  ),
                ),
                Container(
                  width: 16,
                  color: Colors.red,
                  child: Text('Left'),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _rootScrollController,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return Section(
                        name: 'Item $index',
                        height: 100,
                        color: Colors.primaries[index % Colors.primaries.length],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Debug',
        child: const Icon(Icons.bug_report),
      ),
    );
  }
}

class MultiScrollBodySliver extends SingleChildRenderObjectWidget {
  const MultiScrollBodySliver({required super.child, super.key});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMultiScrollBodySliver();
}

class _RenderMultiScrollBodySliver extends RenderSliverSingleBoxAdapter {
  double _obstructionBefore(RenderSliver sliver) {
    RenderObject child = sliver;
    while (child.parent != null && child.parent is! RenderViewportBase) {
      child = child.parent!;
    }
    final parentData = child.parentData;
    if (parentData is! ContainerParentDataMixin<RenderSliver>) {
      return 0.0;
    }
    var total = 0.0;
    RenderSliver? previous = parentData.previousSibling;
    while (previous != null) {
      total += previous.geometry?.maxScrollObstructionExtent ?? 0.0;
      previous =
          (previous.parentData! as ContainerParentDataMixin<RenderSliver>)
              .previousSibling;
    }
    return total;
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    final constraints = this.constraints;
    final double extent = math.max(
      0.0,
      constraints.viewportMainAxisExtent - _obstructionBefore(this),
    );
    child.layout(
      constraints.asBoxConstraints(minExtent: extent, maxExtent: extent),
      parentUsesSize: true,
    );
    final double paintedExtent = calculatePaintOffset(
      constraints,
      from: 0.0,
      to: extent,
    );
    geometry = SliverGeometry(
      scrollExtent: extent,
      paintExtent: paintedExtent,
      cacheExtent: calculateCacheOffset(constraints, from: 0.0, to: extent),
      maxPaintExtent: extent,
      hitTestExtent: paintedExtent,
      hasVisualOverflow:
          extent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0.0,
    );
    setChildParentData(child, constraints, geometry!);
  }
}

class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.name,
    required this.height,
    required this.color,
  });

  final String name;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: color,
      child: Center(child: Text(name)),
    );
  }
}
