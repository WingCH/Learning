import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Case2Page extends StatefulWidget {
  const Case2Page({super.key});

  @override
  State<Case2Page> createState() => _Case2PageState();
}

class _Case2PageState extends State<Case2Page> {
  bool show10Lottie = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Switch(
                    value: show10Lottie,
                    onChanged: (value) {
                      setState(() {
                        show10Lottie = value;
                      });
                    },
                  ),
                  Text('Show 10 Lottie'),
                ],
              ),
              Lottie.asset('assets/favoriteActive.json'),
              if (show10Lottie) ...[
                Lottie.asset('assets/game_in.json'),
                Lottie.asset('assets/game_out.json'),
                Lottie.asset('assets/home_in.json'),
                Lottie.asset('assets/home_out.json'),
                Lottie.asset('assets/inplay_continued_blue.json'),
                Lottie.asset('assets/inplay_continued_gray.json'),
                Lottie.asset('assets/inplay_in.json'),
                Lottie.asset('assets/inplay_out.json'),
                Lottie.asset('assets/mine_in.json'),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
