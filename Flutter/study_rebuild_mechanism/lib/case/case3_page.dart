import 'package:flutter/material.dart';

class Case3Page extends StatefulWidget {
  const Case3Page({super.key});

  @override
  State<Case3Page> createState() => _Case3PageState();
}

// 建立一個簡單的InheritedWidget
class MyInheritedWidget extends InheritedWidget {
  final String data;

  const MyInheritedWidget({
    super.key,
    required this.data,
    required super.child,
  });

  static MyInheritedWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyInheritedWidget>();
  }

  @override
  bool updateShouldNotify(MyInheritedWidget oldWidget) => data != oldWidget.data;
}

// 建立兩個獨立的subtree
class MySubTree extends StatelessWidget {
  final String label;

  const MySubTree({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final inherited = MyInheritedWidget.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Text(inherited?.data ?? '未找到InheritedWidget ($label)'),
    );
  }
}

class _Case3PageState extends State<Case3Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InheritedWidget 測試')),
      body: Column(
        children: [
          // 第一個subtree (有InheritedWidget)
          const MyInheritedWidget(
            data: '來自InheritedWidget 的data',
            child: MySubTree(label: 'SubTree 1'),
          ),
          
          const SizedBox(height: 20),
          // 第二個subtree (獨立結構)
          const MySubTree(label: 'SubTree 2'),
          
          // 第三個subtree (嵌套在不同層級)
          Container(
            padding: const EdgeInsets.all(16),
            child: const MySubTree(label: 'SubTree 3'),
          ),
        ],
      ),
    );
  }
}
  