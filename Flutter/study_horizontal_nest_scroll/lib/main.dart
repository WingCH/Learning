import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: NestedScrollDemo()));

/*
巢狀橫向滾動的手勢衝突問題

  當你有兩層都是橫向滾動的 ListView 時：
  - 外層：灰色容器內的橫向 ListView（顯示紅色卡片）
  - 內層：每個紅色卡片內的橫向 ListView（顯示藍色方塊）

  問題描述：

  1. 手勢競爭：當用戶在藍色區域橫向滑動時，Flutter 不知道應該滾動哪一層
  2. 預設行為：內層 ListView 會優先捕獲手勢，導致外層難以滾動
  3. 用戶體驗差：用戶必須在非常特定的位置（紅色但非藍色區域）才能滾動外層
*/
class NestedScrollDemo extends StatelessWidget {
  const NestedScrollDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 200,
          color: Colors.grey[300],
          child: ListView.builder(
            itemCount: 2,
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) => Container(
              width: 300,
              color: Colors.red[100],
              margin: const EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: 3,
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, j) => Container(
                  width: 100,
                  color: Colors.blue,
                  margin: const EdgeInsets.all(8),
                  child: Center(child: Text('$i-$j')),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
