import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MainApp());
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
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return ListItem(index: index, extentRatio: extentRatio);
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

class ListItem extends StatelessWidget {
  final int index;
  final double extentRatio;

  const ListItem({
    super.key,
    required this.index,
    required this.extentRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(index),
      endActionPane: ActionPane(
        extentRatio: extentRatio,
        motion: const StretchMotion(),
        children: const [
          Expanded(
            child: ActionButton(),
          ),
        ],
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          print('Item $index tapped');
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Item $index',
              ),
              GestureDetector(
                onHorizontalDragCancel: () {},
                onHorizontalDragStart: (details) {},
                onHorizontalDragUpdate: (details) {},
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    print('TextButton Item $index tapped');
                  },
                  child: const Text('Tap me'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void doNothing(BuildContext context) {
    print('doNothing');
  }
}

class ActionButton extends StatefulWidget {
  const ActionButton({super.key});

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  late final slidable = Slidable.of(context)!;
  Animation<double> get animation => slidable.animation;
  double get maxValue => slidable.endActionPaneExtentRatio;
  double progress = 0;

  
  @override
  void initState() {
    super.initState();
    animation.addListener(handleValueChanged);
    animation.addStatusListener(handleStatusChanged);

    print('maxValue $maxValue');
  }

  @override
  void dispose() {
    super.dispose();
    animation.removeListener(handleValueChanged);
    animation.removeStatusListener(handleStatusChanged);
  }

  void handleValueChanged() {
    if (mounted) {
      setState(() {
        progress = animation.value / maxValue;
      });
    }
  }

  void handleStatusChanged(AnimationStatus status) {
    print('handleStatusChanged $status');
  }

  @override
  Widget build(BuildContext context) {
    
    // 計算透明度:
    // 前10%: 完全透明 (opacity = 0.0)
    // 10-30%: 從透明逐漸顯現 (opacity 從 0.0 變為 1.0)
    // 超過30%: 保持完全可見 (opacity = 1.0)
    double opacity;
    if (progress < 0.1) {
      // 前10%保持完全透明
      opacity = 0.0;
    } else if (progress <= 0.3) {
      // 10-30%從透明逐漸顯現
      opacity = (progress - 0.1) / 0.2;  // 將0.1-0.3的範圍映射到0.0-1.0
    } else {
      // 超過30%保持完全可見
      opacity = 1.0;
    }

    
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF3F5F7),
      ),
      child: Center(
        child: Opacity(
          opacity: opacity,
          child: SvgPicture.asset(
            'assets/bookmark_non_filled.svg',
            width: 14,
            height: 14,
            fit: BoxFit.none,
            clipBehavior: Clip.hardEdge,
          ),
        ),
      ),
    );
  }
}
