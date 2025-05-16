import 'package:flutter/material.dart';
import 'efficient_item.dart';
import 'inefficient_item.dart';

class PerformanceComparisonApp extends StatelessWidget {
  final List<String> items;

  const PerformanceComparisonApp({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Performance Comparison',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: PerformanceComparisonPage(items: items),
    );
  }
}

class PerformanceComparisonPage extends StatefulWidget {
  final List<String> items;

  const PerformanceComparisonPage({super.key, required this.items});

  @override
  State<PerformanceComparisonPage> createState() => _PerformanceComparisonPageState();
}

class _PerformanceComparisonPageState extends State<PerformanceComparisonPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('效能比較測試'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '低效能版本'),
            Tab(text: '優化版本'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 低效能版本
          ListView.builder(
            key: const ValueKey('inefficient_list'),
            itemCount: widget.items.length > 100 ? 100 : widget.items.length, // 限制項目數量以避免內存問題
            itemBuilder: (context, index) {
              return InefficientListItem(
                key: ValueKey('inefficient_item_${index}_text'),
                text: widget.items[index],
              );
            },
          ),
          
          // 優化版本
          ListView.builder(
            key: const ValueKey('efficient_list'),
            itemCount: widget.items.length > 100 ? 100 : widget.items.length,
            itemBuilder: (context, index) {
              return EfficientListItem(
                key: ValueKey('efficient_item_${index}_text'),
                text: widget.items[index],
              );
            },
          ),
        ],
      ),
    );
  }
} 