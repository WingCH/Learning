import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Home Page'),
      ),
      body: const Center(
        child: ColoredBox(
          color: Colors.greenAccent,
          child: _TooltipButton(),
        ),
      ),
    );
  }
}

class _TooltipButton extends StatefulWidget {
  const _TooltipButton({Key? key}) : super(key: key);

  @override
  State<_TooltipButton> createState() => _TooltipButtonState();
}

class _TooltipButtonState extends State<_TooltipButton> {
  OverlayEntry? overlayEntry;

  @override
  Widget build(BuildContext context) {
    Offset? _calcPosition() {
      // widget is visible
      final RenderObject? renderObject = context.findRenderObject();
      if (renderObject is RenderBox) {
        var size = renderObject.size;
        var offset = renderObject.localToGlobal(Offset.zero);
        return Offset(offset.dx, offset.dy + size.height);
      } else {
        return null;
      }
    }

    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () {
        if (overlayEntry == null) {
          Offset? position = _calcPosition();
          if (position != null) {
            overlayEntry = OverlayEntry(builder: (context) {
              return Positioned(
                left: position.dx,
                top: position.dy,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    color: Colors.red,
                    child: const Text('hello world'),
                  ),
                ),
              );
            });
            Overlay.of(context)?.insert(overlayEntry!);
          }
        } else {
          overlayEntry?.remove();
          overlayEntry = null;
        }
      },
    );
  }
}
