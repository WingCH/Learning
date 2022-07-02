import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/*
when webview height is too large, the app will be crash.
fail: https://github.com/pichillilorenzo/flutter_inappwebview/issues/735
https://github.com/pichillilorenzo/flutter_inappwebview/issues/314

 */
class Example2Page extends StatefulWidget {
  const Example2Page({Key? key}) : super(key: key);

  @override
  State<Example2Page> createState() => _Example2PageState();
}

class _Example2PageState extends State<Example2Page> {
  InAppWebViewController? webViewController;
  double? height;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
  }

  void updateHeight(double height) async {
    print("height: $height");
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (this.height != height) {
        setState(() {
          print("use height: $height");
          this.height = height;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 200,
              color: Colors.red,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: height ?? 100,
              color: Colors.blue,
              child: InAppWebView(
                initialUrlRequest:
                    URLRequest(url: Uri.parse('https://wingch.site/')),
                // initialOptions: InAppWebViewGroupOptions(
                //   android: AndroidInAppWebViewOptions(
                //     useHybridComposition: true,
                //   ),
                // ),
                onWebViewCreated: (InAppWebViewController controller) {
                  webViewController = controller;
                  webViewController?.addJavaScriptHandler(
                      handlerName: 'Resize',
                      callback: (args) {
                        print("onMessageReceived: ${args}");
                        updateHeight(double.parse(args[0].toString()));
                      });
                },
                onLoadStop: (controller, url) async {
                  await controller.evaluateJavascript(source: """
                          const resizeObserver = new ResizeObserver(entries =>
  window.flutter_inappwebview.callHandler('Resize', entries[0].target.clientHeight))
  resizeObserver.observe(document.body)
  """);
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 200,
              color: Colors.yellow,
            ),
          ),
        ],
      ),
    );
  }
}
