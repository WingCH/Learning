import 'package:flutter/material.dart';
import 'package:study_flutter_rust_01/src/rust/api/simple.dart';
import 'package:study_flutter_rust_01/src/rust/frb_generated.dart';

import 'src/rust/api/basic4.dart';
import 'src/rust/api/cpu_arch.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")}`'),
              Text(
                  'Action: Call Rust `add(1, 2)`\nResult: `${add(x: 1, y: 2)}`'),
              Text('Action: Call Rust `cpuArch()`\nResult: `${cpuArch()}`'),
            ],
          ),
        ),
      ),
    );
  }
}
