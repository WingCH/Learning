import 'dart:math';
import 'package:flutter/material.dart';
import 'package:study_go_router_page_confirm_popup/ios_swiper_gesture_detector/drag_debug_painter.dart';

/// IOSSwiperGestureDetector 是一個參考 Flutter 官方 CupertinoRouteTransitionMixin 實現的手勢偵測元件。
///
/// 它主要實現了類似 iOS 返回手勢的功能，允許使用者從螢幕左側邊緣向右滑動來觸發特定動作。
///
/// 實現細節：
/// 1. 在螢幕左側建立一個透明的偵測區域
/// 2. 當使用者從左側邊緣開始滑動，且滑動距離達到閾值時觸發回調
/// 3. 不會阻擋其他手勢事件
///
/// 這個實現模仿了 Cupertino 路由過渡動畫中的 _CupertinoBackGestureDetector 類別，
/// 但簡化為只專注於偵測右滑手勢而不處理動畫。
class IOSSwiperGestureDetector extends StatefulWidget {
  /// 主要子Widget
  final Widget child;

  /// 是否啟用「往右滑」偵測
  final bool enable;

  /// 偵測到往右滑手勢時會呼叫此函式
  final VoidCallback onSwipe;
  
  /// Enable debug logs for gesture detection
  final bool debugLog;

  const IOSSwiperGestureDetector({
    super.key,
    required this.child,
    required this.onSwipe,
    this.enable = true,
    this.debugLog = true,
  });

  @override
  State<IOSSwiperGestureDetector> createState() =>
      _IOSSwiperGestureDetectorState();
}

class _IOSSwiperGestureDetectorState extends State<IOSSwiperGestureDetector> {
  static const edgeWidth = 20.0;
  
  /// 記錄手勢開始時的X座標位置
  double? _startDragX;
  /// 記錄當前手指位置
  double? _currentDragX;
  
  /// 共用日誌函數，僅在 debugLog 為 true 時輸出
  void _log(String message) {
    if (widget.debugLog) {
      debugPrint('IOSSwiperGestureDetector: $message');
    }
  }

  @override
  void initState() {
    super.initState();
    _log('initialized with enable=${widget.enable}');
  }

  @override
  void dispose() {
    _log('disposing');
    super.dispose();
  }

  /// 建立手勢偵測層
  Widget _buildGestureLayer(BuildContext context) {
    final double layerWidth =
        max(edgeWidth, MediaQuery.paddingOf(context).left);
        
    _log('building gesture layer with width=$layerWidth');

    return PositionedDirectional(
      start: 0.0,
      width: layerWidth,
      top: 0.0,
      bottom: 0.0,
      child: GestureDetector(
        onHorizontalDragStart: (DragStartDetails details) {
          _log('drag start at ${details.localPosition}');
          _startDragX = details.globalPosition.dx;
          _currentDragX = details.globalPosition.dx;
          
          // 觸發重繪來顯示視覺指示器
          if (widget.debugLog) {
            setState(() {});
          }
        },
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          _currentDragX = details.globalPosition.dx;
          _log('drag update at x=$_currentDragX');
          
          // 僅在開啟調試模式時更新視覺指示器
          if (widget.debugLog) {
            setState(() {});
          }
        },
        onHorizontalDragEnd: (DragEndDetails details) {
          // 如果沒有有效的開始位置，則忽略
          if (_startDragX == null || _currentDragX == null) {
            _log('drag ignored - no valid start position');
            return;
          }

          // 計算水平滑動的距離
          final double dragDistance = _currentDragX! - _startDragX!;

          // 取得螢幕寬度以計算滑動比例
          final double screenWidth = MediaQuery.sizeOf(context).width;
          final double dragPercentage = dragDistance / screenWidth;

          // 當滑動距離超過螢幕寬度的20%時觸發回調
          final bool isDragEnough = dragPercentage > 0.20;

          _log('drag distance=$dragDistance px, '
              'percentage=${(dragPercentage * 100).toStringAsFixed(2)}%, '
              'threshold met=$isDragEnough');

          // 符合條件就執行回調
          if (isDragEnough) {
            _log('executing onSwipe callback');
            widget.onSwipe();
          }

          // 重置開始位置
          _startDragX = null;
          _currentDragX = null;

          // 清除視覺指示器
          if (widget.debugLog) {
            setState(() {});
          }
        },
        onHorizontalDragCancel: () {
          _log('drag cancelled');
          _startDragX = null;
          _currentDragX = null;
          
          // 清除視覺指示器
          if (widget.debugLog) {
            setState(() {});
          }
        },
        behavior: HitTestBehavior.translucent,
      ),
    );
  }
  
  /// 建立視覺指示器來顯示當前滑動位置
  Widget _buildDebugVisualizer() {
    // 只有當手勢開始時才繪製視覺指示器
    if (_startDragX == null || _currentDragX == null) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      left: _startDragX!, // 從起點開始繪製
      top: 0,
      height: MediaQuery.sizeOf(context).height,
      child: IgnorePointer(
        child: CustomPaint(
          painter: DragDebugPainter(
            startX: 0, // 起點在 CustomPaint 中為 0
            currentX: _currentDragX! - _startDragX!,
            screenWidth: MediaQuery.sizeOf(context).width,
            showThreshold: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _log('building widget, enable=${widget.enable}');
    return Stack(
      children: [
        widget.child,
        if (widget.enable) _buildGestureLayer(context),
        // 僅在調試模式下顯示視覺指示器
        if (widget.debugLog) _buildDebugVisualizer(),
      ],
    );
  }
}

