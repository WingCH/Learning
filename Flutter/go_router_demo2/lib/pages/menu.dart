import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() {
    debugPrint('$runtimeType -- createState');
    return _MenuPageState(title: runtimeType.toString());
  }
}

class _MenuPageState extends State<MenuPage> {
  final String title;

  _MenuPageState({required this.title});

  @override
  void initState() {
    super.initState();
    debugPrint('$title -- initState');
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint('$title -- dispose');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('$title -- build');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text('back to previous page'),
              onPressed: () {
                // context.go('/home/menu');
                // https://github.com/csells/go_router/issues/99#issuecomment-949687524
                Navigator.maybePop(context);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('redemption'),
              onPressed: () {
                context.go('/redemption');
              },
            ),
          ],
        ),
      ),
    );
  }
}
