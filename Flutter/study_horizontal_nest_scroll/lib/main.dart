import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

// 引入解決方案
import 'solution1_disable_at_edge.dart' as solution1;
import 'solution2.dart' as solution2;

void main() => runApp(const MaterialApp(home: HomePage()));

/// 首頁 - 顯示問題和解決方案列表
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('巢狀橫向滾動問題研究'),
      ),
      body: ListView(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.error_outline, color: Colors.red),
              title: const Text('原始問題展示'),
              subtitle: const Text('內層滾動到邊緣時無法觸發外層滑動'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OriginalProblemDemo(),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '解決方案',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.touch_app, color: Colors.blue),
              title: const Text('方案 1: 邊界禁用滾動'),
              subtitle: const Text('在滾動邊界時暫時禁用內層滾動'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const solution1.Solution1DisableAtEdge(),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.gesture, color: Colors.green),
              title: const Text('方案 2'),
              subtitle: const Text(''),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const solution2.Solution2(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 原始問題展示頁面
class OriginalProblemDemo extends StatelessWidget {
  const OriginalProblemDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('原始問題展示'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Slidable(
              key: const ValueKey('slidable'),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                dismissible: DismissiblePane(
                  closeOnCancel: true,
                  confirmDismiss: () async {
                    return false;
                  },
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
                height: 200,
                width: 200,
                color: Colors.grey[300],
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Placeholder(
                      fallbackHeight: 100,
                      fallbackWidth: 100,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(4, (index) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Placeholder(
                                fallbackWidth: 100,
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
