import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/// 一個解決 Slidable 與水平滾動嵌套衝突的 Widget
///
/// 功能特點：
/// - 在滾動到右邊界時，禁用內部滾動，讓 Slidable 可以正常工作
/// - 當 Slidable 開啟時，禁用內部滾動
/// - 在右邊界向右滑動時，暫時啟用滾動讓使用者可以向左滾動
/// 限制說明：
/// - 此解決方案在某個時機切換 physics 為 NeverScrollableScrollPhysics
/// - 單次滑動的響應者只能有一個，比如 Flutter 列表滑動完之後，
///   如果不抬起手指而繼續滑動，是不會刷新 physics 的
class SlidableNestedScrollView extends StatefulWidget {
  /// Slidable 的 controller
  final SlidableController slidableController;

  /// 滾動內容的 builder
  final Widget Function(BuildContext context, ScrollController controller)
      scrollContentBuilder;

  /// 是否顯示 debug view
  final bool showDebugView;

  const SlidableNestedScrollView({
    super.key,
    required this.slidableController,
    required this.scrollContentBuilder,
    this.showDebugView = false,
  });

  @override
  State<SlidableNestedScrollView> createState() =>
      _SlidableNestedScrollViewState();
}

class _SlidableNestedScrollViewState extends State<SlidableNestedScrollView> {
  final ScrollController _scrollController = ScrollController();
  final Axis _scrollDirection = Axis.horizontal;

  bool _isAtRightEdge = false;
  ActionPaneType _actionPaneType = ActionPaneType.none;
  bool _isManualScrollToRight = false;

  // 統一的滾動物理狀態管理
  final ValueNotifier<ScrollPhysics?> _scrollPhysicsNotifier =
      ValueNotifier(null);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(_handleScrollUpdate);
      widget.slidableController.actionPaneType
          .addListener(_handleSlidableUpdate);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollPhysicsNotifier.dispose();
    super.dispose();
  }

  // 更新滾動物理狀態
  void _updateScrollPhysics() {
    ScrollPhysics? newPhysics;

    // 簡化的邏輯：
    // 1. 如果 Slidable 開啟，禁用滾動
    // 2. 如果在右邊界，禁用滾動（避免與 Slidable 衝突）
    // 3. 其他情況允許滾動
    if (_actionPaneType == ActionPaneType.end || _isAtRightEdge) {
      newPhysics = const NeverScrollableScrollPhysics();
    } else {
      newPhysics = null;
    }

    _scrollPhysicsNotifier.value = newPhysics;
  }

  // 處理滾動位置更新
  void _handleScrollUpdate() {
    if (!_scrollController.hasClients) return;
    if (_isManualScrollToRight) return;

    final pixels = _scrollController.position.pixels;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final wasAtRightEdge = _isAtRightEdge;
    _isAtRightEdge = pixels >= maxScroll;

    // 只在狀態改變時更新滾動物理
    if (wasAtRightEdge != _isAtRightEdge) {
      _updateScrollPhysics();
    }
  }

  // 處理 Slidable 狀態更新
  void _handleSlidableUpdate() {
    final newActionPaneType = widget.slidableController.actionPaneType.value;
    if (_actionPaneType != newActionPaneType) {
      _actionPaneType = newActionPaneType;
      _updateScrollPhysics();
    }
  }

  // 處理手勢偵測 - 提供即時視覺反饋
  // 由於SingleChildScrollView 的滾動會被禁用以避免與 Slidable 衝突
  // 因此需要向右滑動時手動處理滾動，提供即時視覺反饋
  void _handlePointerMove(PointerMoveEvent event) {
    // 當在右邊界且滾動被禁用時，手動處理滾動
    if (_isAtRightEdge &&
        _actionPaneType == ActionPaneType.none &&
        _scrollController.hasClients) {
      final currentPosition = _scrollController.position.pixels;
      // 根據手指移動的距離來更新滾動位置
      // 注意：向左滑動時 delta.dx 為負值，所以需要減去它
      final targetPosition = (currentPosition - event.delta.dx).clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      );

      _isManualScrollToRight = true;
      // 使用 jumpTo 提供即時反饋，跟隨手指移動
      _scrollController.jumpTo(targetPosition);
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_isManualScrollToRight) {
      _isManualScrollToRight = false;
      _handleScrollUpdate();
    }
  }

  Widget _buildDebugView() {
    return _DebugView(
      getIsAtRightEdge: () => _isAtRightEdge,
      getActionPaneType: () => _actionPaneType,
      getIsManualScrollToRight: () => _isManualScrollToRight,
      getHasClients: () => _scrollController.hasClients,
      getScrollPosition: () {
        try {
          if (_scrollController.hasClients &&
              _scrollController.positions.isNotEmpty) {
            return _scrollController.positions.first.pixels;
          }
        } catch (e) {
          // Ignore error
        }
        return 0.0;
      },
      getMaxScrollExtent: () {
        try {
          if (_scrollController.hasClients &&
              _scrollController.positions.isNotEmpty) {
            return _scrollController.positions.first.maxScrollExtent;
          }
        } catch (e) {
          // Ignore error
        }
        return 0.0;
      },
      getMinScrollExtent: () {
        try {
          if (_scrollController.hasClients &&
              _scrollController.positions.isNotEmpty) {
            return _scrollController.positions.first.minScrollExtent;
          }
        } catch (e) {
          // Ignore error
        }
        return 0.0;
      },
      scrollPhysicsNotifier: _scrollPhysicsNotifier,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      child: ValueListenableBuilder<ScrollPhysics?>(
        valueListenable: _scrollPhysicsNotifier,
        builder: (context, scrollPhysics, child) {
          final scrollView = SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: _scrollDirection,
            physics: scrollPhysics,
            child: child!,
          );

          if (!widget.showDebugView) {
            return scrollView;
          }

          return Stack(
            children: [
              scrollView,
              _buildDebugView(),
            ],
          );
        },
        child: widget.scrollContentBuilder(context, _scrollController),
      ),
    );
  }
}

/// Debug view that auto-refreshes to show real-time data
class _DebugView extends StatefulWidget {
  final bool Function() getIsAtRightEdge;
  final ActionPaneType Function() getActionPaneType;
  final bool Function() getIsManualScrollToRight;
  final bool Function() getHasClients;
  final double Function() getScrollPosition;
  final double Function() getMaxScrollExtent;
  final double Function() getMinScrollExtent;
  final ValueNotifier<ScrollPhysics?> scrollPhysicsNotifier;

  const _DebugView({
    required this.getIsAtRightEdge,
    required this.getActionPaneType,
    required this.getIsManualScrollToRight,
    required this.getHasClients,
    required this.getScrollPosition,
    required this.getMaxScrollExtent,
    required this.getMinScrollExtent,
    required this.scrollPhysicsNotifier,
  });

  @override
  State<_DebugView> createState() => _DebugViewState();
}

class _DebugViewState extends State<_DebugView> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // 每 50ms 更新一次 debug view
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          // 只是觸發重建，不需要更新任何狀態
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DefaultTextStyle(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontFamily: 'monospace',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('===== Debug View =====',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('isAtRightEdge: ${widget.getIsAtRightEdge()}'),
                Text('actionPaneType: ${widget.getActionPaneType().name}'),
                Text(
                    'isManualScrollToRight: ${widget.getIsManualScrollToRight()}'),
                if (widget.getHasClients()) ...[
                  Text(
                      'scrollPosition: ${widget.getScrollPosition().toStringAsFixed(2)}'),
                  Text(
                      'maxScrollExtent: ${widget.getMaxScrollExtent().toStringAsFixed(2)}'),
                  Text(
                      'minScrollExtent: ${widget.getMinScrollExtent().toStringAsFixed(2)}'),
                ],
                ValueListenableBuilder<ScrollPhysics?>(
                  valueListenable: widget.scrollPhysicsNotifier,
                  builder: (context, physics, _) {
                    return Text(
                        'scrollPhysics: ${physics?.runtimeType ?? "null (default)"}');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
