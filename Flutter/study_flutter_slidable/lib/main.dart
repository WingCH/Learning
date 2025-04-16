import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
        child: SizedBox(
          height: 100,
          child: Center(
            child: Text(
              'Item $index',
            ),
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.red,
      ),
      clipBehavior: Clip.hardEdge,
      child: Center(
        child: Text(
          '${progress.toStringAsFixed(2)}',
        ),
      ),
    );
  }
}
