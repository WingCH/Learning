import 'dart:math';

import 'package:flutter/material.dart';

class CustomStarImage extends StatelessWidget {
  final double height;
  final double width;
  final String imagePath;

  const CustomStarImage({
    super.key,
    required this.height,
    required this.width,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: StarClipper(),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        height: height,
        width: width,
      ),
    );
  }
}

class StarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;
    final innerRadius = radius * 0.4;

    for (int i = 0; i < 5; i++) {
      // Outer points of the star
      final outerX = centerX + radius * cos(2 * pi * i * 2 / 10 - pi / 2);
      final outerY = centerY + radius * sin(2 * pi * i * 2 / 10 - pi / 2);

      // Inner points of the star
      final innerX =
          centerX + innerRadius * cos(2 * pi * (i * 2 + 1) / 10 - pi / 2);
      final innerY =
          centerY + innerRadius * sin(2 * pi * (i * 2 + 1) / 10 - pi / 2);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
