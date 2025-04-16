import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  List<String> _tabTitles = ['Tab 1', 'Tab 2'];

  void _addTab() {
    setState(() {
      _tabTitles = [..._tabTitles, 'New Tab ${_tabTitles.length + 1}'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(tabTitles: _tabTitles, onAddTab: _addTab),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final List<String> tabTitles;
  final VoidCallback onAddTab;

  const MyHomePage({
    super.key,
    required this.tabTitles,
    required this.onAddTab,
  });

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabTitles.length,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant MyHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabTitles != widget.tabTitles) {
      // Dispose of the old TabController
      _tabController.dispose();

      // Create a new TabController with the updated length
      _tabController = TabController(
        length: widget.tabTitles.length,
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic TabBar Example'),
        bottom: TabBar(
          controller: _tabController,
          tabs: widget.tabTitles.map((title) => Tab(text: title)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: widget.tabTitles
            .map((title) => Center(child: Text('Content for $title')))
            .toList(),
      ),
      floatingActionButton: MyFloatingActionButton(onPressed: widget.onAddTab),
    );
  }
}

class MyFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MyFloatingActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: const Icon(Icons.add),
    );
  }
}
