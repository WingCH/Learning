import 'dart:io';

import 'package:cupertino_http/cupertino_http.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

class CupertinoHttpPage extends StatefulWidget {
  const CupertinoHttpPage({super.key});

  @override
  State<CupertinoHttpPage> createState() => _CupertinoHttpPageState();
}

class _CupertinoHttpPageState extends State<CupertinoHttpPage> {
  bool _isLoading = false;
  String _response = "";

  Client httpClient() {
    if (Platform.isIOS || Platform.isMacOS) {
      final config = URLSessionConfiguration.ephemeralSessionConfiguration()..cache = URLCache.withCapacity(memoryCapacity: 1000000);
      return CupertinoClient.fromSessionConfiguration(config);
    }
    return IOClient();
  }

  Future<String> fetch() async {
    try {
      final response = await httpClient().get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));
      return response.body;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("cupertino_http"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              child: const Text("GET"),
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                _response = await fetch();
                setState(() {
                  _isLoading = false;
                });
              },
            ),
            Text(_isLoading ? "Loading..." : _response),
          ],
        ),
      ),
    );
  }
}
