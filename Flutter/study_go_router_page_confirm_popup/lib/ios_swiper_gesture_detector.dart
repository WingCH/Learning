import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

/// IOSSwiperGestureDetector 是一個參考 Flutter 官方 CupertinoRouteTransitionMixin 實現的手勢偵測元件。
/// 
/// 它主要實現了類似 iOS 返回手勢的功能，允許使用者從螢幕左側邊緣向右滑動來觸發特定動作。
/// 
/// 實現細節：
/// 1. 在螢幕左側建立一個透明的偵測區域
/// 2. 使用 HorizontalDragGestureRecognizer 監聽手勢事件
/// 3. 當使用者從左側邊緣開始滑動，且滑動距離達到閾值時觸發回調
/// 
/// 這個實現模仿了 Cupertino 路由過渡動畫中的 _CupertinoBackGestureDetector 類別，
/// 但簡化為只專注於偵測右滑手勢而不處理動畫。
class IOSSwiperGestureDetector extends StatefulWidget {
  /// 主要子Widget
  final Widget child;

  /// 是否啟用「往右滑」偵測
  final bool enableSwipe;

  /// 偵測到往右滑手勢時會呼叫此函式
  final VoidCallback onSwipe;

  const IOSSwiperGestureDetector({
    super.key,
    required this.child,
    required this.onSwipe,
    this.enableSwipe = true,
  });

  @override
  State<IOSSwiperGestureDetector> createState() => _IOSSwiperGestureDetectorState();
}

class _IOSSwiperGestureDetectorState extends State<IOSSwiperGestureDetector> {
  static const edgeWidth = 20.0;
  // 參考 CupertinoRouteTransitionMixin 中的 _CupertinoBackGestureDetector，
  // 它也是透過 HorizontalDragGestureRecognizer 來監聽左側邊緣手勢。
  late HorizontalDragGestureRecognizer _dragRecognizer;
  
  /// 記錄手勢開始時的X座標位置
  double? _startDragX;

  @override
  void initState() {
    super.initState();
    // 初始化手勢識別器並設置回調函數
    _dragRecognizer = HorizontalDragGestureRecognizer(debugOwner: this)
      ..onStart = _handleDragStart
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
  }

  @override
  void dispose() {
    // 釋放手勢識別器資源
    _dragRecognizer.dispose();
    super.dispose();
  }

  /// 處理滑動開始事件
  /// 
  /// 檢查手勢是否從左側邊緣區域開始，如果是則記錄起始位置
  /// 這是模仿 Cupertino 中只允許從螢幕邊緣開始的返回手勢行為
  void _handleDragStart(DragStartDetails details) {
    if (!widget.enableSwipe) return;
    final isInEdge = details.globalPosition.dx <= edgeWidth;

    // 與 CupertinoRouteTransitionMixin 類似，先檢查是否自「左側區域」開始，
    // 官方預設寬度是 _kBackGestureWidth ( 20.0 )。
    if (isInEdge) {
      _startDragX = details.globalPosition.dx;
    }
  }

  /// 處理滑動結束事件
  /// 
  /// 計算滑動距離並轉換為螢幕寬度的百分比
  /// 當滑動距離超過螢幕寬度的 20% 時觸發回調
  /// 
  /// 這是參考 Cupertino 路由過渡的邏輯，但簡化為僅基於距離判斷，
  /// 而不考慮速度因素，適用於更穩定的手勢檢測
  void _handleDragEnd(DragEndDetails details) {
    // 結束後若「開始位置」不在邊緣，或根本沒開始，就不做事
    if (_startDragX == null) return;
    
    // 計算水平滑動的距離
    final double currentX = details.globalPosition.dx;
    final double dragDistance = currentX - _startDragX!;
    
    // 取得螢幕寬度以計算滑動比例
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double dragPercentage = dragDistance / screenWidth;
    
    // 當滑動距離超過螢幕寬度的15%時觸發回調
    final bool isDragEnough = dragPercentage > 0.15;
    
    // 符合條件就執行回調
    if (isDragEnough) {
      widget.onSwipe();
    }
    
    // 重置開始位置
    _startDragX = null;
  }

  /// 處理滑動取消事件
  /// 
  /// 當手勢被系統取消時重置狀態
  void _handleDragCancel() {
    _startDragX = null;
  }

  /// 建立手勢偵測層
  /// 
  /// 創建一個位於螢幕左側的透明區域來偵測手勢
  /// 參考 _CupertinoBackGestureDetector 中的實現，
  /// 考慮了裝置邊框安全區域，確保在有瀏海的設備上也能正常工作
  Widget _buildGestureLayer(BuildContext context) {
    // 若有瀏海或邊框安全區，為了避免實際可偵測區域太窄，可考慮取 max。
    final double layerWidth = max(edgeWidth, MediaQuery.paddingOf(context).left);

    return PositionedDirectional(
      start: 0.0,
      width: layerWidth,
      top: 0.0,
      bottom: 0.0,
      child: ColoredBox(
        color: Colors.red, // 可視化偵測區域，生產環境應移除或改為透明
        child: Listener(
          // 當手指接觸到螢幕時，若啟用 side-swipe，則把指針事件交給 _dragRecognizer 處理
          onPointerDown: (PointerDownEvent event) {
            if (widget.enableSwipe) {
              _dragRecognizer.addPointer(event);
            }
          },
          behavior: HitTestBehavior.translucent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 用 Stack 疊加左側偵測區
    // 這樣不會干擾主要內容的點擊事件，只在左側邊緣區域監聽滑動手勢
    return Stack(
      children: [
        widget.child,
        _buildGestureLayer(context),
      ],
    );
  }
}
