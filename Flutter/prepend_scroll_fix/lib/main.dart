import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:prepend_scroll_fix/prepend_scroll_fixer.dart';

void main() {
  runApp(const MaterialApp(home: ManualScrollFixPage()));
}

class ManualScrollFixPage extends StatefulWidget {
  const ManualScrollFixPage({super.key});

  @override
  State<ManualScrollFixPage> createState() => _ManualScrollFixPageState();
}

class _ManualScrollFixPageState extends State<ManualScrollFixPage> {
  final ScrollController _scrollController = ScrollController();

  // 模擬資料來源
  final List<int> _items = List.generate(20, (index) => index);

  @override
  void initState() {
    super.initState();
    // 為了演示方便，初始位置設定在中間，讓你能感受到頂部插入資料的效果
    // 注意：實際專案中不要在 initState 直接 jump，這裡只是為了演示
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(500);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 核心功能：在頂部插入資料
  /// 注意：這裡只負責更新資料，滾動修正由 TopPrependScrollFixer 自動處理
  void _prependData() {
    // 更新 UI
    setState(() {
      // 模擬在頂部插入 5 個新項目
      final newItems = List.generate(5, (index) => 9000 + index); // 9000+ 代表新資料
      _items.insertAll(0, newItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("方案二：自動修正 Scroll Offset")),
      // 按鈕放在這方便操作
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _prependData,
        label: const Text("頂部插入資料"),
        icon: const Icon(Icons.vertical_align_top),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: TopPrependScrollFixer(
              scrollController: _scrollController,
              child: Column(
                children: [
                  // 標題
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.yellow[100],
                    width: double.infinity,
                    child: const Text(
                      "這是 Column 頂部\n點擊右下角按鈕插入資料\n注意觀察這裡不會被擠開",
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // 列表內容
                  ..._items.map((item) {
                    // 為了明顯區分新舊資料，新資料(>=9000)用紅色
                    final isNew = item >= 9000;
                    return Container(
                      height: 80, // 固定高度方便測試，實際動態高度也能運作
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 16),
                      color: isNew ? Colors.red[100] : Colors.blue[100],
                      alignment: Alignment.center,
                      child: Text(
                        isNew ? "新資料 Item $item" : "舊資料 Item $item",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isNew ? Colors.red : Colors.blue,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
