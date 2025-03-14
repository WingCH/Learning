import 'package:flutter/material.dart';
import 'package:study_rebuild_mechanism/case/case2_page.dart';
import 'package:study_rebuild_mechanism/widget_cache.dart';

class Case6Page extends StatefulWidget {
  const Case6Page({super.key});

  @override
  State<Case6Page> createState() => _Case6PageState();
}

class _Case6PageState extends State<Case6Page> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _colorAnimation = ColorTween(
      begin: Colors.blue.withOpacity(0.2),
      end: Colors.red.withOpacity(0.2),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              color: _colorAnimation.value,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child:  WidgetCache(
                  value: 'test',
                  builder: (context, value) => Case2Page(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
