import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
import 'package:rive/rive.dart';

class Case4Page extends StatelessWidget {
  const Case4Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 100,
          height: 80,
          child: RiveAnimation.asset(
            'assets/favoriteActive.riv',
          ),
        ),
      ),
    );
  }
}
