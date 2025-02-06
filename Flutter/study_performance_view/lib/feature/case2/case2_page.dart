import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Case2Page extends StatelessWidget {
  const Case2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/favoriteActive.json'),
              // Lottie.asset('assets/game_in.json'),
              // Lottie.asset('assets/game_out.json'),
              // Lottie.asset('assets/home_in.json'),
              // Lottie.asset('assets/home_out.json'),
              // Lottie.asset('assets/inplay_continued_blue.json'),
              // Lottie.asset('assets/inplay_continued_gray.json'),
              // Lottie.asset('assets/inplay_in.json'),
              // Lottie.asset('assets/inplay_out.json'),
              // Lottie.asset('assets/mine_in.json'),
            ],
          ),
        ],
      ),
    );
  }
}
