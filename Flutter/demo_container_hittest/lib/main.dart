import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (context) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Case 1'),
                Stack(
                  children: [
                    const DogImage(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 50,
                          width: 100,
                          color: Colors.red,
                        ),
                        const Text('''
  Container(
    height: 50,
    width: 100,
    color: Colors.red,
  )

Colored containers will block click events.
                        ''')
                      ],
                    ),
                  ],
                ),
                const Text('Case 2'),
                Stack(
                  children: [
                    const DogImage(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ignore: sized_box_for_whitespace
                        Container(
                          height: 50,
                          width: 100,
                        ),
                        const Text('''
  Container(
    height: 50,
    width: 100,
  )

If there is no color, click events will not be blocked
                        ''')
                      ],
                    ),
                  ],
                ),
                const Text('Case 3'),
                Stack(
                  children: [
                    const DogImage(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ignore: sized_box_for_whitespace
                        Container(
                          height: 50,
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.red,
                            ),
                          ),
                        ),
                        const Text('''
  Container(
    height: 50,
    width: 100,
    decoration: BoxDecoration(
      border: Border.all(
        color: Colors.red,
      ),
    ),
  )

if `decoration` is used, it will block click events.
                        ''')
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class DogImage extends StatelessWidget {
  const DogImage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OnTap a dog'),
          ),
        );
      },
      child: Image.network(
        width: 100,
        height: 100,
        'https://picsum.photos/id/237/100/100',
        fit: BoxFit.cover,
      ),
    );
  }
}
