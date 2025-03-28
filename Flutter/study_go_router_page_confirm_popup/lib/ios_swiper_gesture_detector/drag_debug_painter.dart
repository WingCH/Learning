import 'package:flutter/material.dart';

/// 用於繪製滑動位置的自定義畫筆
class   DragDebugPainter extends CustomPainter {
  final double? startX;
  final double? currentX;
  final double screenWidth;
  final bool showThreshold;
  
  DragDebugPainter({
    this.startX,
    this.currentX,
    required this.screenWidth,
    this.showThreshold = true,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (startX == null || currentX == null) return;
    
    final double threshold = screenWidth * 0.20;
    
    // 繪製起始位置 (現在是固定的 0)
    final startPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawCircle(
      Offset(0, size.height / 2),
      10.0,
      startPaint,
    );
    
    // 繪製當前位置 (相對於起點)
    final currentPaint = Paint()
      ..color = Colors.red.withOpacity(0.7)
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;
    
    canvas.drawCircle(
      Offset(currentX!, size.height / 2),
      15.0,
      currentPaint,
    );
    
    // 繪製連接線
    final linePaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(currentX!, size.height / 2),
      linePaint,
    );
    
    if (showThreshold) {
      // 繪製滑動閾值線
      final thresholdPaint = Paint()
        ..color = Colors.amber
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      
      final dashPath = Path();
      const dashWidth = 10.0;
      const dashSpace = 5.0;
      double distance = threshold;
      double dashX = 0;
      
      while (dashX < distance) {
        dashPath.moveTo(dashX, 0);
        dashPath.lineTo(dashX + dashWidth > distance ? distance : dashX + dashWidth, 0);
        dashX += dashWidth + dashSpace;
      }
      
      // 繪製閾值虛線
      canvas.save();
      canvas.translate(0, size.height / 2);
      canvas.drawPath(dashPath, thresholdPaint);
      canvas.restore();
    }
    
    // 繪製文字標籤
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.white.withOpacity(0.7),
    );
    
    final startTextPainter = TextPainter(
      text: TextSpan(text: '起點', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    startTextPainter.layout();
    startTextPainter.paint(canvas, Offset(0 - startTextPainter.width / 2, size.height / 2 - 30));
    
    final currentTextPainter = TextPainter(
      text: TextSpan(text: '當前值: ${currentX!.toStringAsFixed(1)}', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    currentTextPainter.layout();
    currentTextPainter.paint(canvas, Offset(currentX! - currentTextPainter.width / 2, size.height / 2 + 20));
    
    final distanceTextPainter = TextPainter(
      text: TextSpan(
        text: '距離: ${currentX!.toStringAsFixed(1)}px (${(currentX! / screenWidth * 100).toStringAsFixed(1)}%)',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    );
    distanceTextPainter.layout();
    distanceTextPainter.paint(
      canvas, 
      Offset(currentX! / 2 - distanceTextPainter.width / 2, size.height / 2 - 60),
    );
    
    if (showThreshold) {
      final thresholdTextPainter = TextPainter(
        text: TextSpan(text: '閾值(20%)', style: textStyle),
        textDirection: TextDirection.ltr,
      );
      thresholdTextPainter.layout();
      thresholdTextPainter.paint(canvas, Offset(threshold - thresholdTextPainter.width / 2, size.height / 2 - 30));
    }
  }
  
  @override
  bool shouldRepaint(DragDebugPainter oldDelegate) {
    return oldDelegate.startX != startX || 
           oldDelegate.currentX != currentX ||
           oldDelegate.screenWidth != screenWidth;
  }
}
