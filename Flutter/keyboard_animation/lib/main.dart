import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const KeyboardSensitiveView(),
    );
  }
}

class KeyboardSensitiveView extends StatelessWidget {
  const KeyboardSensitiveView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomOffset = mq.viewInsets.bottom + mq.padding.bottom;
    // You can play with some different Curves:
    const curve = Curves.easeOutQuad;
    // and timings:
    const durationMS = 275;
    // Also, you can add different setup for Android
    return Scaffold(
      // !!! Important part > to disable default scaffold insets (which is not animated)
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Keyboard Animation')),
      body: AnimatedContainer(
        curve: curve,
        duration: const Duration(milliseconds: durationMS),
        padding: EdgeInsets.only(bottom: bottomOffset),
        child: SafeArea(
          bottom: false, // !!! Important part > we are adding SafeArea.bottom above with " + mq.padding.bottom"
          child: Stack(children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: TextComposer(),
            ),
          ]),
        ),
      ),
    );
  }
}

class TextComposer extends StatefulWidget {
  const TextComposer({Key? key}) : super(key: key);

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(
            width: 60,
            child: Icon(Icons.add_a_photo),
          ),
          Flexible(
            child: TextField(
              style: Theme.of(context).textTheme.titleSmall,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter text...',
              ),
            ),
          ),
          const SizedBox(
            width: 60,
            child: Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}