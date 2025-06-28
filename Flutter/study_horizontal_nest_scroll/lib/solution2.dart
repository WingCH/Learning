import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'widgets/slidable_nested_scroll_view.dart';

class Solution2 extends StatefulWidget {
  const Solution2({super.key});

  @override
  State<Solution2> createState() => _Solution2State();
}

class _Solution2State extends State<Solution2>
    with SingleTickerProviderStateMixin {
  late SlidableController _slidableController;

  @override
  void initState() {
    super.initState();
    _slidableController = SlidableController(this);
  }

  @override
  void dispose() {
    _slidableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solution 2 - 使用封裝 Widget'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Slidable(
                  controller: _slidableController,
                  key: const ValueKey('slidable'),
                  endActionPane: ActionPane(
                    extentRatio: 0.5,
                    motion: const DrawerMotion(),
                    dismissible: DismissiblePane(
                      closeOnCancel: true,
                      confirmDismiss: () async => false,
                      onDismissed: () {},
                      dismissThreshold: 0.5,
                    ),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('分享動作')),
                          );
                        },
                        backgroundColor: const Color(0xFF21B7CA),
                        foregroundColor: Colors.white,
                        icon: Icons.share,
                        label: '分享',
                      ),
                    ],
                  ),
                  child: Container(
                    height: 300,
                    width: 300,
                    color: Colors.grey[300],
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 80,
                          color: Colors.grey[400],
                          child: const Center(
                            child: Text(
                              '頂部區域\n(向左滑動查看項目)',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 使用封裝的 Widget
                        SizedBox(
                          height: 150,
                          child: SlidableNestedScrollView(
                            slidableController: _slidableController,
                            scrollContentBuilder: (context, controller) {
                              return Row(
                                children: List.generate(6, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 150,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.green[
                                                ((index + 1) * 100) % 900] ??
                                            Colors.green,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Item ${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 使用說明
            Container(
              width: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '使用 SlidableNestedScrollView',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '這個範例展示如何使用封裝好的 Widget 來解決\n'
                    'Slidable 與水平滾動的嵌套衝突問題。\n\n'
                    '特點：\n'
                    '• 自動處理邊界滾動邏輯\n'
                    '• 支援 debug 模式顯示狀態\n'
                    '• 可重複使用於不同場景',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}