import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/// Solution 1: 邊界禁用滾動方案
///
/// 原理：
/// - 使用 NotificationListener 監聽滾動通知
/// - 當檢測到 OverscrollNotification（表示已到達邊界）時
/// - 將內層的 ScrollPhysics 設為 NeverScrollableScrollPhysics
/// - 這樣手勢不會被內層消耗，可以傳遞給外層 Slidable
/// - 當用戶反向滑動時，恢復正常的滾動物理屬性
class Solution1DisableAtEdge extends StatefulWidget {
  const Solution1DisableAtEdge({super.key});

  @override
  State<Solution1DisableAtEdge> createState() => _Solution1DisableAtEdgeState();
}

class _Solution1DisableAtEdgeState extends State<Solution1DisableAtEdge> {
  ScrollPhysics _scrollPhysics = const AlwaysScrollableScrollPhysics();
  final ScrollController _scrollController = ScrollController();

  // 追蹤上次的滾動方向和位置
  bool _isAtLeftEdge = false;
  bool _isAtRightEdge = false;

  // Debug 信息
  double _currentScrollPosition = 0;
  String _debugInfo = '等待滾動事件...';
  int _disableCount = 0;
  DateTime? _lastDisableTime;

  @override
  void initState() {
    super.initState();
    // 延遲添加監聽器，避免在初始構建時觸發
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(_checkScrollPosition);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkScrollPosition() {
    if (!_scrollController.hasClients) return;

    final pixels = _scrollController.position.pixels;
    final maxScroll = _scrollController.position.maxScrollExtent;

    final newIsAtLeftEdge = pixels <= 0;
    final newIsAtRightEdge = pixels >= maxScroll;

    // 只在狀態真正改變時才調用 setState
    if (_isAtLeftEdge != newIsAtLeftEdge ||
        _isAtRightEdge != newIsAtRightEdge ||
        _currentScrollPosition != pixels) {
      // 使用 addPostFrameCallback 避免在構建過程中調用 setState
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isAtLeftEdge = newIsAtLeftEdge;
            _isAtRightEdge = newIsAtRightEdge;
            _currentScrollPosition = pixels;
          });
        }
      });

      debugPrint(
          '[ScrollPosition] pixels: $pixels, max: $maxScroll, atLeft: $newIsAtLeftEdge, atRight: $newIsAtRightEdge');
    }
  }

  void _updateDebugInfo(String info) {
    // 避免在構建過程中調用 setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _debugInfo = info;
        });
      }
    });
    debugPrint('[DEBUG] $info');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solution 1: 邊界禁用滾動'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
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
                    height: 300, // 增加高度以容納 debug 信息
                    width: 300, // 增加寬度
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
                        SizedBox(
                          height: 150, // 固定滾動區域高度
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification notification) {
                              // 移除通知類型的追蹤

                              if (notification is ScrollUpdateNotification) {
                                // 監聽滾動更新，判斷滾動方向
                                final delta = notification.scrollDelta ?? 0;

                                _updateDebugInfo(
                                    'ScrollUpdate - delta: $delta, pixels: ${notification.metrics.pixels.toStringAsFixed(2)}');

                                // 只在右邊界且繼續向右滾動時，禁用滾動
                                if (_isAtRightEdge && delta > 0) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (mounted) {
                                      // 如果還不是禁用狀態，則禁用
                                      if (_scrollPhysics
                                          is! NeverScrollableScrollPhysics) {
                                        setState(() {
                                          _scrollPhysics =
                                              const NeverScrollableScrollPhysics();
                                          _disableCount++;
                                          _lastDisableTime = DateTime.now();
                                        });
                                        _updateDebugInfo(
                                            '禁用滾動 (右邊界) #$_disableCount - atRight: $_isAtRightEdge, delta: $delta');
                                      }
                                    }
                                  });
                                } else if (
                                    // 檢測反向滑動：在右邊界向左滑
                                    (_isAtRightEdge && delta < 0) ||
                                        // 或者已經離開右邊界
                                        !_isAtRightEdge) {
                                  // 如果當前是禁用狀態，恢復滾動
                                  if (_scrollPhysics
                                      is NeverScrollableScrollPhysics) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (mounted) {
                                        setState(() {
                                          _scrollPhysics =
                                              const AlwaysScrollableScrollPhysics();
                                        });
                                        _updateDebugInfo(
                                            '恢復滾動 (離開右邊界或反向滑動) - delta: $delta, atRight: $_isAtRightEdge');
                                      }
                                    });
                                  }
                                }
                              } else if (notification
                                  is ScrollStartNotification) {
                                _updateDebugInfo('ScrollStart - 開始滾動');

                                // 如果在開始新的滾動手勢時還是禁用狀態，可能需要恢復
                                // 這可能表示用戶想要開始新的滾動操作
                                if (_scrollPhysics
                                    is NeverScrollableScrollPhysics) {
                                  // 檢查是否應該恢復（例如：用戶可能想反向滾動）
                                  _updateDebugInfo('檢測到新的滾動手勢，但滾動仍被禁用');
                                }
                              } else if (notification
                                  is ScrollEndNotification) {
                                _updateDebugInfo('ScrollEnd - 結束滾動');
                              } else if (notification
                                  is UserScrollNotification) {
                                // 用戶滾動通知
                                final direction = notification.direction;
                                _updateDebugInfo(
                                    'UserScrollNotification - direction: $direction');
                              }

                              return false; // 允許通知繼續傳播
                            },
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              physics: _scrollPhysics,
                              child: Row(
                                children: List.generate(6, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 150, // 調大了
                                      height: 120, // 調大了
                                      decoration: BoxDecoration(
                                        color: Colors.blue[
                                                ((index + 1) * 100) % 900] ??
                                            Colors.blue,
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
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 顯示當前狀態（方便調試）
            Container(
              width: 300,
              height: 300,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '滾動狀態: ${_scrollPhysics is NeverScrollableScrollPhysics ? "🔴 已禁用" : "🟢 正常"}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '位置: ${_currentScrollPosition.toStringAsFixed(1)} | 左邊界: $_isAtLeftEdge | 右邊界: $_isAtRightEdge',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                  Text(
                    '禁用次數: $_disableCount',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                  if (_lastDisableTime != null)
                    Text(
                      '最後禁用: ${DateTime.now().difference(_lastDisableTime!).inMilliseconds}ms 前',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '調試信息: $_debugInfo',
                    style: const TextStyle(
                        fontSize: 11, color: Colors.yellowAccent),
                  ),
                  const SizedBox(height: 8),
                  // 手動恢復按鈕（用於測試）
                  if (_scrollPhysics is NeverScrollableScrollPhysics)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _scrollPhysics =
                              const AlwaysScrollableScrollPhysics();
                        });
                        _updateDebugInfo('手動恢復滾動');
                      },
                      child: const Text('手動恢復滾動'),
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
