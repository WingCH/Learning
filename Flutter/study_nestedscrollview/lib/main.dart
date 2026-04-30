import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(const NestedScrollExampleApp());
}

class NestedScrollExampleApp extends StatelessWidget {
  const NestedScrollExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NestedScrollView Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const NestedScrollDemoPage(),
    );
  }
}

enum HeaderMode { pinned, floating }

class NestedScrollDemoPage extends StatefulWidget {
  const NestedScrollDemoPage({super.key});

  @override
  State<NestedScrollDemoPage> createState() => _NestedScrollDemoPageState();
}

class _NestedScrollDemoPageState extends State<NestedScrollDemoPage>
    with SingleTickerProviderStateMixin {
  HeaderMode _headerMode = HeaderMode.pinned;

  bool get _isPinned => _headerMode == HeaderMode.pinned;

  bool get _isFloating => _headerMode == HeaderMode.floating;

  void _setHeaderMode(HeaderMode mode) {
    setState(() {
      _headerMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          key: const ValueKey<String>('demo-nested-scroll-view'),
          floatHeaderSlivers: true,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
                sliver: SliverPersistentHeader(
                  key: const ValueKey<String>('demo-persistent-header'),
                  pinned: false,
                  floating: true,
                  delegate: _SimpleSliverPersistentHeaderDelegate(
                    height: 72,
                    mode: _headerMode,
                    vsync: this,
                    child: HeaderSurface(
                      mode: _headerMode,
                      innerBoxIsScrolled: innerBoxIsScrolled,
                      onModeChanged: _setHeaderMode,
                    ),
                  ),
                ),
              ),
            ];
          },
          body: ListView.builder(
            itemCount: 32,
            itemBuilder: (BuildContext context, int index) {
              return DemoListItem(index: index);
            },
          ),
        ),
      ),
    );
  }
}

class _SimpleSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  const _SimpleSliverPersistentHeaderDelegate({
    required this.child,
    required this.height,
    required this.mode,
    required this.vsync,
  });

  final double height;
  final Widget child;
  final HeaderMode mode;
  @override
  final TickerProvider vsync;

  // @override
  // FloatingHeaderSnapConfiguration? get snapConfiguration {
  //   return switch (mode) {
  //     HeaderMode.pinned => null,
  //     HeaderMode.floating => FloatingHeaderSnapConfiguration(
  //       curve: Curves.easeOutCubic,
  //       duration: const Duration(milliseconds: 180),
  //     ),
  //   };
  // }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(_SimpleSliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate.height != height ||
        oldDelegate.child != child ||
        oldDelegate.mode != mode ||
        oldDelegate.vsync != vsync;
  }
}

class HeaderSurface extends StatelessWidget {
  const HeaderSurface({
    super.key,
    required this.mode,
    required this.innerBoxIsScrolled,
    required this.onModeChanged,
  });

  final HeaderMode mode;
  final bool innerBoxIsScrolled;
  final ValueChanged<HeaderMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: innerBoxIsScrolled ? 4 : 0,
      color: colorScheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[colorScheme.primaryContainer, colorScheme.surface],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: HeaderModeSelector(
            mode: mode,
            progress: 0,
            onModeChanged: onModeChanged,
          ),
        ),
      ),
    );
  }
}

class HeaderModeSelector extends StatelessWidget {
  const HeaderModeSelector({
    super.key,
    required this.mode,
    required this.progress,
    required this.onModeChanged,
  });

  final HeaderMode mode;
  final double progress;
  final ValueChanged<HeaderMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: SegmentedButton<HeaderMode>(
            segments: const <ButtonSegment<HeaderMode>>[
              ButtonSegment<HeaderMode>(
                value: HeaderMode.pinned,
                label: Text('pinned'),
                icon: Icon(Icons.vertical_align_top),
              ),
              ButtonSegment<HeaderMode>(
                value: HeaderMode.floating,
                label: Text('floating'),
                icon: Icon(Icons.swap_vert),
              ),
            ],
            selected: <HeaderMode>{mode},
            onSelectionChanged: (Set<HeaderMode> selection) {
              onModeChanged(selection.first);
            },
          ),
        ),
        const SizedBox(width: 12),
        Text('${(progress * 100).round()}%'),
      ],
    );
  }
}

class DemoListItem extends StatelessWidget {
  const DemoListItem({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: index.isEven
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text('Inner scroll item ${index + 1}'),
          subtitle: const Text('CustomScrollView body with overlap injector'),
        ),
      ),
    );
  }
}
