import 'package:flutter/material.dart';

class RedemptionEnterCodePage extends StatefulWidget {
  const RedemptionEnterCodePage({Key? key}) : super(key: key);

  @override
  State<RedemptionEnterCodePage> createState() {
    debugPrint('$runtimeType -- createState');
    return _RedemptionEnterCodePageState(title: runtimeType.toString());
  }
}

class _RedemptionEnterCodePageState extends State<RedemptionEnterCodePage> {
  final String title;

  _RedemptionEnterCodePageState({required this.title});

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
                // https://github.com/csells/go_router/issues/99#issuecomment-949687524
                Navigator.maybePop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
