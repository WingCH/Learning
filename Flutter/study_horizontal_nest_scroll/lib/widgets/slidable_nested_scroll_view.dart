import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/// 一個解決 Slidable 與水平滾動嵌套衝突的 Widget
///
/// 功能特點：
/// - 在滾動到右邊界時，禁用內部滾動，讓 Slidable 可以正常工作
/// - 當 Slidable 開啟時，禁用內部滾動
/// - 在右邊界向右滑動時，暫時啟用滾動讓使用者可以向左滾動
class SlidableNestedScrollView extends StatefulWidget {
  /// Slidable 的 controller
  final SlidableController slidableController;

  /// 滾動內容的 builder
  final Widget Function(BuildContext context, ScrollController controller)
      scrollContentBuilder;

  const SlidableNestedScrollView({
    super.key,
    required this.slidableController,
    required this.scrollContentBuilder,
  });

  @override
  State<SlidableNestedScrollView> createState() =>
      _SlidableNestedScrollViewState();
}

class _SlidableNestedScrollViewState extends State<SlidableNestedScrollView> {
  final ScrollController _scrollController = ScrollController();
  final Axis _scrollDirection = Axis.horizontal;

  // 使用 ValueNotifier 管理狀態，避免不必要的 setState
  final ValueNotifier<bool> _isAtRightEdgeNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isSwipingRightNotifier = ValueNotifier(false);
  final ValueNotifier<ActionPaneType> _actionPaneTypeNotifier = 
      ValueNotifier(ActionPaneType.none);
  
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
      
      // 監聽狀態變化並更新滾動物理
      _isAtRightEdgeNotifier.addListener(_updateScrollPhysics);
      _isSwipingRightNotifier.addListener(_updateScrollPhysics);
      _actionPaneTypeNotifier.addListener(_updateScrollPhysics);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _isAtRightEdgeNotifier.dispose();
    _isSwipingRightNotifier.dispose();
    _actionPaneTypeNotifier.dispose();
    _scrollPhysicsNotifier.dispose();
    super.dispose();
  }
  
  // 更新滾動物理狀態
  void _updateScrollPhysics() {
    final isAtRightEdge = _isAtRightEdgeNotifier.value;
    final isSwipingRight = _isSwipingRightNotifier.value;
    final actionPaneType = _actionPaneTypeNotifier.value;
    
    ScrollPhysics? newPhysics;
    
    // 邏輯優先順序：
    // 1. 如果正在向右滑動且在右邊界，允許滾動
    if (isSwipingRight && isAtRightEdge && actionPaneType == ActionPaneType.none) {
      newPhysics = null; // 允許滾動
    }
    // 2. 如果 Slidable 開啟，禁用滾動
    else if (actionPaneType == ActionPaneType.end) {
      newPhysics = const NeverScrollableScrollPhysics();
    }
    // 3. 如果在右邊界，禁用滾動（避免與 Slidable 衝突）
    else if (isAtRightEdge) {
      newPhysics = const NeverScrollableScrollPhysics();
    }
    // 4. 預設情況，允許滾動
    else {
      newPhysics = null;
    }
    
    _scrollPhysicsNotifier.value = newPhysics;
  }

  // 處理滾動位置更新
  void _handleScrollUpdate() {
    if (!_scrollController.hasClients) return;

    final pixels = _scrollController.position.pixels;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final newIsAtRightEdge = pixels >= maxScroll;

    if (_isAtRightEdgeNotifier.value != newIsAtRightEdge) {
      _isAtRightEdgeNotifier.value = newIsAtRightEdge;
      // 當離開右邊界時，重置向右滑動狀態
      if (!newIsAtRightEdge) {
        _isSwipingRightNotifier.value = false;
      }
    }
  }

  // 處理 Slidable 狀態更新
  void _handleSlidableUpdate() {
    final newActionPaneType = widget.slidableController.actionPaneType.value;
    if (_actionPaneTypeNotifier.value != newActionPaneType) {
      _actionPaneTypeNotifier.value = newActionPaneType;
    }
  }

  // 處理手勢偵測
  void _handlePointerMove(PointerMoveEvent event) {
    final isMovingRight = event.delta.dx > 0;

    // 只在右邊界且 Slidable 關閉時處理向右滑動
    if (isMovingRight &&
        _isAtRightEdgeNotifier.value &&
        _actionPaneTypeNotifier.value == ActionPaneType.none) {
      if (!_isSwipingRightNotifier.value) {
        _isSwipingRightNotifier.value = true;
      }
    }
  }

  // 處理手勢結束
  void _handlePointerUp(PointerUpEvent event) {
    if (_isSwipingRightNotifier.value) {
      // 立即重置右邊界狀態，讓滾動可以開始
      _isAtRightEdgeNotifier.value = false;

      // 延遲重置滑動狀態
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _isSwipingRightNotifier.value = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      child: ValueListenableBuilder<ScrollPhysics?>(
        valueListenable: _scrollPhysicsNotifier,
        builder: (context, scrollPhysics, child) {
          return SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: _scrollDirection,
            physics: scrollPhysics,
            child: child!,
          );
        },
        child: widget.scrollContentBuilder(context, _scrollController),
      ),
    );
  }
}