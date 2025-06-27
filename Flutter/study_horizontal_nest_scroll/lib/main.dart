import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: NestedScrollDemo()));

// 自定義通知，用於內層通知外層需要滾動
class OuterScrollNotification extends Notification {
  final double delta;
  OuterScrollNotification(this.delta);
}

class NestedScrollDemo extends StatefulWidget {
  const NestedScrollDemo({super.key});

  @override
  State<NestedScrollDemo> createState() => _NestedScrollDemoState();
}

class _NestedScrollDemoState extends State<NestedScrollDemo> {
  final ScrollController _outerController = ScrollController();

  @override
  void dispose() {
    _outerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 200,
          color: Colors.grey[300],
          child: NotificationListener<OuterScrollNotification>(
            onNotification: (notification) {
              // 接收來自內層的滾動請求
              _outerController.jumpTo(
                _outerController.offset + notification.delta,
              );
              return true;
            },
            child: ListView.builder(
              controller: _outerController,
              itemCount: 5,
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => Container(
                width: 300,
                color: Colors.red[100],
                margin: const EdgeInsets.all(8),
                child: _InnerScrollView(index: i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InnerScrollView extends StatefulWidget {
  final int index;
  
  const _InnerScrollView({required this.index});

  @override
  State<_InnerScrollView> createState() => _InnerScrollViewState();
}

class _InnerScrollViewState extends State<_InnerScrollView> {
  final ScrollController _innerController = ScrollController();
  double _lastDragPosition = 0;
  bool _isDragging = false;
  bool _isControllingOuter = false;

  @override
  void dispose() {
    _innerController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _isDragging = true;
    _isControllingOuter = false;
    _lastDragPosition = details.globalPosition.dx;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final delta = details.globalPosition.dx - _lastDragPosition;
    _lastDragPosition = details.globalPosition.dx;

    if (_isControllingOuter) {
      // 發送通知給外層
      OuterScrollNotification(-delta).dispatch(context);
      return;
    }

    final innerPosition = _innerController.position;
    final atLeftEdge = innerPosition.pixels <= innerPosition.minScrollExtent;
    final atRightEdge = innerPosition.pixels >= innerPosition.maxScrollExtent;

    if ((delta > 0 && atLeftEdge) || (delta < 0 && atRightEdge)) {
      _isControllingOuter = true;
      OuterScrollNotification(-delta).dispatch(context);
    } else {
      final newOffset = _innerController.offset - delta;
      final clampedOffset = newOffset.clamp(
        innerPosition.minScrollExtent,
        innerPosition.maxScrollExtent,
      );
      _innerController.jumpTo(clampedOffset);
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    _isDragging = false;
    _isControllingOuter = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: ListView.builder(
        controller: _innerController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, j) => Container(
          width: 100,
          color: Colors.blue,
          margin: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.index}-$j',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (j == 0)
                  const Icon(
                    Icons.arrow_back,
                    color: Colors.white54,
                    size: 16,
                  ),
                if (j == 5)
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white54,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}