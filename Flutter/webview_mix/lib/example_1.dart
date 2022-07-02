import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/*
when webview height is too large, the app will be crash.
https://github.com/flutter/flutter/issues/45243
 */
class Example1Page extends StatefulWidget {
  const Example1Page({Key? key}) : super(key: key);

  @override
  State<Example1Page> createState() => _Example1PageState();
}

class _Example1PageState extends State<Example1Page> {
  late WebViewController _webViewController;
  double? height;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
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
              child: WebView(
                debuggingEnabled: true,
                initialUrl: 'https://wingch.site/',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  print('WebView created');
                  _webViewController = webViewController;
                  _webViewController.runJavascript("""
                      const resizeObserver = new ResizeObserver(entries =>
  Resize.postMessage(entries[0].target.clientHeight))
  resizeObserver.observe(document.body)
                    """);
                },
                javascriptChannels: {
                  JavascriptChannel(
                      name: "Resize",
                      onMessageReceived: (JavascriptMessage message) {
                        print("onMessageReceived: ${message.message}");
                        updateHeight(double.parse(message.message));
                      })
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
