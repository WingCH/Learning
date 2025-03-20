import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: Scaffold(
        body: Center(
          child: Stack(
            fit: StackFit.loose,
            alignment: Alignment.center,
            children: [
              Positioned(
                child: GestureDetector(
                  onTap: () {
                    print('Box 1');
                  },
                  child:  Container(
                    height: 100,
                    width: 100,
                    color: Colors.red,
                  ),
                ),
              ),
              Positioned(
                child: GestureDetector(
                  onTap: () {
                    print('Box 2');
                  },
                  child:  Container(
                    height: 50,
                    width: 100,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
