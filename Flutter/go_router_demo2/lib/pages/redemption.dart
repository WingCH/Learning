import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RedemptionPage extends StatefulWidget {
  const RedemptionPage({
    Key? key,
    required this.queryParams,
  }) : super(key: key);

  final Map<String, String> queryParams;

  @override
  State<RedemptionPage> createState() {
    debugPrint('$runtimeType -- createState');
    return _RedemptionPageState(title: runtimeType.toString());
  }
}

class _RedemptionPageState extends State<RedemptionPage> {
  final String title;

  _RedemptionPageState({required this.title});

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
        leading: BackButton(
          onPressed: () {
            context.go('/${widget.queryParams['from']}');
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text('enter code'),
              onPressed: () {
                Uri uri = Uri(
                  path: '/redemption/enter_code',
                  queryParameters: widget.queryParams,
                );
                context.go(uri.toString());
              },
            ),
            const SizedBox(height: 20),
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
