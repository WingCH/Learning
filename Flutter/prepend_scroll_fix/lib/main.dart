import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(MaterialApp(home: ManualScrollFixPage()));
}

class ManualScrollFixPage extends StatefulWidget {
  @override
  _ManualScrollFixPageState createState() => _ManualScrollFixPageState();
}

class _ManualScrollFixPageState extends State<ManualScrollFixPage> {
  final ScrollController _scrollController = ScrollController();

  // 我們需要一個 GlobalKey 來獲取 Column 的真實渲染高度
  final GlobalKey _columnKey = GlobalKey();

  // 模擬資料源
  final List<int> _items = List.generate(20, (index) => index);

  @override
  void initState() {
    super.initState();
    // 為了演示方便，初始就在中間，讓你能感受到 prepend 的效果
    // 注意：實際專案中不要在 initState 直接 jump，這裡只是為了 Demo
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(500);
      }
    });
  }

  /// 核心功能：在頂部插入資料並修正滾動位置
  void _prependData() {
    // 1.【事前測量】
    // 獲取當前 Column 的高度 (如果還沒渲染則為 0)
    final RenderBox? renderBox =
        _columnKey.currentContext?.findRenderObject() as RenderBox?;
    final double oldHeight = renderBox?.size.height ?? 0;

    // 獲取當前滾動位置
    final double oldOffset = _scrollController.offset;

    print("更新前 -> 高度: $oldHeight, Offset: $oldOffset");

    // 2.【更新 UI】
    setState(() {
      // 模擬在頂部插入 5 個新項目
      final newItems = List.generate(5, (index) => 9000 + index); // 9000+ 代表新資料
      _items.insertAll(0, newItems);
    });

    // 3.【事後修正】
    // addPostFrameCallback 會在這一幀的 Layout 完成後回調
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // 再次獲取 Column 的新高度
      final RenderBox? newRenderBox =
          _columnKey.currentContext?.findRenderObject() as RenderBox?;
      final double newHeight = newRenderBox?.size.height ?? 0;

      // 計算高度差 (這就是內容變長了多少)
      final double diff = newHeight - oldHeight;

      print("更新後 -> 高度: $newHeight, 增加高度: $diff");

      if (diff > 0 && _scrollController.hasClients) {
        // 4.【瞬間跳轉】
        // 新位置 = 舊位置 + 高度差
        // 這樣使用者的眼睛看到的內容就會保持在原本的位置
        _scrollController.animateTo(
          oldOffset + diff,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        print("已修正 Scroll Offset 至: ${oldOffset + diff}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("方案二：手動 JumpTo 修正")),
      // 按鈕放在這方便操作
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _prependData,
        label: Text("頂部插入資料"),
        icon: Icon(Icons.add),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              key: _columnKey, // ⚠️ 綁定 Key 非常重要，用於測量高度
              children: [
                // 標題
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.yellow[100],
                  child: const Text("這是 Column 頂部\n點擊右下角按鈕插入資料\n注意觀察這裡不會被彈走",
                      textAlign: TextAlign.center),
                ),

                // 列表內容
                ..._items.map((item) {
                  // 為了明顯區分新舊資料，新資料(>9000)用紅色
                  final isNew = item >= 9000;
                  return Container(
                    height: 80, // 固定高度方便測試，實際動態高度也能運作
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
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
        ],
      ),
    );
  }
}
