import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 效能極差的列表項組件 - 每次渲染時都執行複雜計算
class InefficientListItem extends StatefulWidget {
  final String text;
  final int itemIndex; // 用於生成不同的計算結果

  const InefficientListItem({
    super.key,
    required this.text,
    required this.itemIndex,
  });

  @override
  State<InefficientListItem> createState() => _InefficientListItemState();
}

class _InefficientListItemState extends State<InefficientListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 極度沒效率的斐波那契數列計算 (指數時間複雜度)
  int _fibonacci(int n) {
    if (n <= 1) return n;
    return _fibonacci(n - 1) + _fibonacci(n - 2);
  }

  // 無效率的質數檢查
  bool _isPrime(int n) {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    for (int i = 5; i * i <= n; i += 6) {
      if (n % i == 0 || n % (i + 2) == 0) return false;
    }
    return true;
  }

  // 組合多個極度耗時的操作，每次渲染都會執行
  int _extremelyExpensiveCalculation(int seed, int subIndex) {
    // 執行多種超複雜計算，模擬嚴重性能問題
    int result = 0;

    // 組合項目索引和子索引來影響計算結果
    int adjustedSeed = seed * (widget.itemIndex + 1);

    // 1. 首先計算小型斐波那契數
    int fibResult = _fibonacci(min(20, adjustedSeed % 22));

    // 2. 基於斐波那契結果，生成一個範圍
    int rangeEnd = 50000 + (fibResult % 3000) + (widget.itemIndex * 100);

    // 3. 在範圍內進行嵌套循環計算
    for (int i = 0; i < rangeEnd; i++) {
      if (i % 500 == 0) {
        // 每500次迭代，執行額外的質數檢查
        for (int j = i; j < i + 50; j++) {
          if (_isPrime(j)) {
            result += (j % 17) * (widget.itemIndex + 1);
          }
        }
      }

      // 一般迭代的計算
      for (int j = 0; j < 50; j++) {
        result += ((i * j) % 123) + widget.itemIndex;

        // 三層嵌套，繼續增加計算量
        if (j % 20 == 0) {
          for (int k = 0; k < 30; k++) {
            result =
                (result + math.pow(k + widget.itemIndex, 2).toInt()) % 10000;
          }
        }
      }
    }

    // 4. 使用大量字符串操作（修復索引越界問題）
    String tempString = '';
    String resultStr = result.toString();
    for (int i = 0; i < 500; i++) {
      // 確保索引不會越界
      int safeIndex = (i + widget.itemIndex) % resultStr.length;
      tempString += resultStr[safeIndex];
    }

    // 5. 將字符串操作的結果混入計算
    result += tempString.codeUnits.fold(0, (prev, curr) => prev + curr);

    // 6. 使用超大數計算
    for (int i = 0; i < 5; i++) {
      BigInt bigValue = BigInt.from(result + i + widget.itemIndex);
      for (int j = 1; j <= 15; j++) {
        bigValue = bigValue * BigInt.from(j + (widget.itemIndex % 5));
      }
      result += bigValue.remainder(BigInt.from(100 + widget.itemIndex)).toInt();
    }

    // 確保每個項目和每個子項都有不同的計算結果
    return (result % 700000) + (widget.itemIndex * 10000) + (subIndex * 1000);
  }

  @override
  Widget build(BuildContext context) {
    // 每次重建UI時執行耗時的斐波那契計算
    final realTimeValue = _fibonacci(17 + (widget.itemIndex % 3));

    // 使用複雜的佈局、動畫和實時計算來製造嚴重效能問題
    return Card(
      elevation: 4.0 + _controller.value * 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: List.generate(5, (index) {
            // 每次構建UI時執行極度耗時的複雜計算
            final seed =
                20 + index + (widget.itemIndex * 13) + _random.nextInt(10);
            final calculatedValue = _extremelyExpensiveCalculation(seed, index);

            // 動態生成大量不必要的字符串
            String generatedText = '';
            for (int i = 0; i < 100; i++) {
              generatedText +=
                  '${widget.text[0]}${(i + widget.itemIndex) % 10}';
            }

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.5 + _controller.value * 0.5,
                  child: Transform.scale(
                    scale: 0.9 + _controller.value * 0.2,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(
                              (calculatedValue % 255),
                              ((calculatedValue * 2) % 255),
                              ((calculatedValue * 3) % 255),
                              0.7 + _controller.value * 0.3,
                            ),
                            Color.fromRGBO(
                              ((calculatedValue * 4) % 255),
                              ((calculatedValue * 5) % 255),
                              ((calculatedValue * 6) % 255),
                              0.8,
                            ),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.1 + _controller.value * 0.1),
                            blurRadius: 10.0 * _controller.value,
                            spreadRadius: 2.0 * _controller.value,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Color.fromRGBO(
                                ((calculatedValue + widget.itemIndex) % 255),
                                ((calculatedValue * 2 + widget.itemIndex) %
                                    255),
                                ((calculatedValue * 3 + widget.itemIndex) %
                                    255),
                                1.0,
                              ),
                              radius: 20.0 + _controller.value * 5.0,
                              child: Text('$index'),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${widget.text} - $index (實時計算: $realTimeValue)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0 + _controller.value * 2.0,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black54,
                                          blurRadius: 2.0 * _controller.value,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text('複雜計算結果: $calculatedValue'),
                                  Text(
                                    generatedText.substring(0, 50),
                                    style: const TextStyle(fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  // 輔助函數，限制數值範圍
  int min(int a, int b) => a < b ? a : b;
}
