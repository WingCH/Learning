import 'dart:math';
import 'package:flutter/material.dart';

class Paper extends StatelessWidget {
  const Paper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.white,
        width: 335,
        height: 118,
        child: CustomPaint(
          painter: PaperPainter(),
        ),
      ),
    );
  }
}

class PaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background color (optional, can be disabled as needed)
    canvas.drawColor(Colors.grey.shade200, BlendMode.srcOver);

    // Paint for showcasing different colors for lines and arcs
    final paintLines = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // (1) Define parameters
    const double margin = 10.0; // Distance from edges
    const double notchRadius = 10.0; // Radius for top and bottom notches
    const double cornerRadius = 8.0; // Corner radius for ticket edges

    // Calculate dynamically using size.width and size.height
    const double left = margin;
    const double top = margin;
    final double right = size.width - margin;
    final double bottom = size.height - margin;
    final double centerX = (left + right) / 2;

    // Create a unified Path for final filling
    final path = Path();

    //
    // Step 1: moveTo to the starting point at the "cut point of the top-left corner"
    //
    // Start point: (left + cornerRadius, top)
    //
    paintLines.color = Colors.red;
    paintLines.strokeWidth = 3;
    canvas.drawCircle(
      const Offset(left + cornerRadius, top),
      3,
      paintLines,
    );
    // Draw a small label
    _drawText(
      canvas,
      'Start Point',
      const Offset(left + cornerRadius + 5, top - 20),
      color: Colors.red,
    );

    path.moveTo(left + cornerRadius, top);

    //
    // Step 2: Draw the top edge to the "left end of the top notch"
    //
    // End point: (centerX - notchRadius, top)
    //
    paintLines.color = Colors.blue;
    canvas.drawLine(
      const Offset(left + cornerRadius, top),
      Offset(centerX - notchRadius, top),
      paintLines,
    );
    _drawText(
      canvas,
      'Top Edge',
      Offset((left + cornerRadius + (centerX - notchRadius)) / 2, top - 20),
      color: Colors.blue,
    );

    // Path also needs to lineTo this point
    path.lineTo(centerX - notchRadius, top);

    //
    // Step 3: Draw the "top notch" arc using arcToPoint
    //
    // End point: (centerX + notchRadius, top)
    //
    paintLines.color = Colors.orange;
    paintLines.style = PaintingStyle.stroke;
    Path tempArc1 = Path();
    tempArc1.moveTo(centerX - notchRadius, top);
    tempArc1.arcToPoint(
      Offset(centerX + notchRadius, top),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    canvas.drawPath(tempArc1, paintLines);

    path.arcToPoint(
      Offset(centerX + notchRadius, top),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );

    //
    // Step 4: Draw the top-right edge to the corner radius
    //
    // From (centerX + notchRadius, top) -> (right - cornerRadius, top)
    // Then use quadraticBezierTo for the corner radius
    //
    paintLines.color = Colors.purple;
    // Draw the straight line first
    canvas.drawLine(
      Offset(centerX + notchRadius, top),
      Offset(right - cornerRadius, top),
      paintLines,
    );
    // Mark the corner with a small circle
    canvas.drawCircle(
      Offset(right - cornerRadius, top),
      3,
      paintLines,
    );

    // Draw the corner radius using the same color
    Path tempArc2 = Path();
    tempArc2.moveTo(right - cornerRadius, top);
    tempArc2.quadraticBezierTo(
      right,
      top,
      right,
      top + cornerRadius,
    );
    canvas.drawPath(tempArc2, paintLines);

    // Path
    path.lineTo(right - cornerRadius, top);
    path.quadraticBezierTo(
      right,
      top,
      right,
      top + cornerRadius,
    );

    //
    // Step 5: Draw the right edge down to the bottom-right corner
    //
    // Draw the straight line first
    paintLines.color = Colors.brown;
    Path tempLine3 = Path();
    tempLine3.moveTo(right, top + cornerRadius);
    tempLine3.lineTo(right, bottom - cornerRadius);
    canvas.drawPath(tempLine3, paintLines);

    // Draw the bottom-right corner
    Path tempArc3 = Path();
    tempArc3.moveTo(right, bottom - cornerRadius);
    tempArc3.quadraticBezierTo(
      right,
      bottom,
      right - cornerRadius,
      bottom,
    );
    canvas.drawPath(tempArc3, paintLines);

    // Path
    path.lineTo(right, bottom - cornerRadius);
    path.quadraticBezierTo(
      right,
      bottom,
      right - cornerRadius,
      bottom,
    );

    //
    // Step 6: Draw the "bottom notch" lineTo + arc
    //
    // lineTo -> (centerX + notchRadius, bottom)
    // arcTo -> (centerX - notchRadius, bottom)
    //
    paintLines.color = Colors.green;
    canvas.drawLine(
      Offset(right - cornerRadius, bottom),
      Offset(centerX + notchRadius, bottom),
      paintLines,
    );
    // Draw the arc
    Path tempArc4 = Path();
    tempArc4.moveTo(centerX + notchRadius, bottom);
    tempArc4.arcToPoint(
      Offset(centerX - notchRadius, bottom),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    canvas.drawPath(tempArc4, paintLines);

    // Path
    path.lineTo(centerX + notchRadius, bottom);
    path.arcToPoint(
      Offset(centerX - notchRadius, bottom),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );

    //
    // Step 7: Draw the bottom-left corner and left edge
    //
    paintLines.color = Colors.cyan;
    // Line to (left + cornerRadius, bottom)
    canvas.drawLine(
      Offset(centerX - notchRadius, bottom),
      Offset(left + cornerRadius, bottom),
      paintLines,
    );
    // Bottom-left corner
    Path tempArc5 = Path();
    tempArc5.moveTo(left + cornerRadius, bottom);
    tempArc5.quadraticBezierTo(
      left,
      bottom,
      left,
      bottom - cornerRadius,
    );
    canvas.drawPath(tempArc5, paintLines);

    // Draw the left edge upwards
    Path tempLine4 = Path();
    tempLine4.moveTo(left, bottom - cornerRadius);
    tempLine4.lineTo(left, top + cornerRadius);
    canvas.drawPath(tempLine4, paintLines);

    // Top-left corner
    Path tempArc6 = Path();
    tempArc6.moveTo(left, top + cornerRadius);
    tempArc6.quadraticBezierTo(
      left,
      top,
      left + cornerRadius,
      top,
    );
    canvas.drawPath(tempArc6, paintLines);

    // Path
    path.lineTo(left + cornerRadius, bottom);
    path.quadraticBezierTo(
      left,
      bottom,
      left,
      bottom - cornerRadius,
    );
    path.lineTo(left, top + cornerRadius);
    path.quadraticBezierTo(
      left,
      top,
      left + cornerRadius,
      top,
    );

    // Complete the closed path
    path.close();

    //
    // Final Step: Fill the entire shape
    //
    // Can be done at the top or bottom, done here last so earlier visual hints aren't overwritten too soon.
    //
    final paintFill = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paintFill);
  }

  @override
  bool shouldRepaint(PaperPainter oldDelegate) => true;

  // Simple method to draw text
  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    Color color = Colors.black,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }
}
