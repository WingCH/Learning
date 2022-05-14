import 'dart:math';

import 'package:flutter/material.dart';

import '../coordinate_pro.dart';

class Paper extends StatelessWidget {
  const Paper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: CustomPaint(
        painter: PaperPainter(),
      ),
    );
  }
}

class PaperPainter extends CustomPainter {
  final Coordinate coordinate = Coordinate(step: 25);

  @override
  void paint(Canvas canvas, Size size) {
    coordinate.paint(canvas, size);
    canvas.translate(size.width / 2, size.height / 2);

    double radius = 10;
    Path path = Path();
    Paint paint = Paint()
      ..color = Colors.purpleAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    path.moveTo(100 - 10, -250);
    path.relativeLineTo(150, 0);
    path.relativeArcToPoint(
      Offset(radius, radius),
      radius: Radius.circular(radius),
      largeArc: false,
      clockwise: true,
    );
    path.relativeLineTo(0, 150);
    canvas.drawPath(path, paint);

    canvas.drawPath(path.transform(Matrix4.rotationZ(pi).storage), paint);
    canvas.drawPath(path.transform(Matrix4.rotationZ(pi / 2).storage), paint);
    canvas.drawPath(path.transform(Matrix4.rotationZ(-pi / 2).storage), paint);
  }

  @override
  bool shouldRepaint(PaperPainter oldDelegate) => true;
}
