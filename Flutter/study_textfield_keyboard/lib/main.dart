import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<bool> _showKeyboardNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    // _focusNode.addListener(() {
    //   setState(() {});
    // });
    _showKeyboardNotifier.addListener(() {
      if (_showKeyboardNotifier.value) {
        activateKeyboard();
      } else {
        deactivateKeyboard();
      }
    });
  }

  Future<void> activateKeyboard() async {
    final FocusScopeNode scope = FocusScope.of(context);
    scope.unfocus();
    await Future.delayed(const Duration(milliseconds: 100));
    scope.requestFocus(_focusNode);
  }

  void deactivateKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Text('Focus Node: ${_focusNode.hasFocus}'),
            ManuallyManageFocusTextfield(
              focusNode: _focusNode,
              onTap: () {
                _showKeyboardNotifier.value = true;
              },
            ),
            TextButton(
              onPressed: () {
                _showKeyboardNotifier.value = false;
              },
              child: const Text('hide keyboard'),
            ),
            TextButton(
              onPressed: () {
                _showKeyboardNotifier.value = true;
              },
              child: const Text('show keyboard'),
            ),
          ],
        ),
      ),
    );
  }
}

class ManuallyManageFocusTextfield extends StatelessWidget {
  const ManuallyManageFocusTextfield({Key? key, required this.onTap, required this.focusNode}) : super(key: key);
  final VoidCallback onTap;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: IgnorePointer(
        ignoring: true,
        child: Placeholder(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              focusNode: focusNode,
              decoration: const InputDecoration(
                hintText: 'Enter text',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
