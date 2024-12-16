import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_combine_rust/image_combine_rust.dart';

/*
Operation took: 1082 milliseconds
*/
Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

// Create a class to hold the data we need to pass to the isolate
class IsolateData {
  final SendPort sendPort;
  final List<Uint8List> images;

  IsolateData(this.sendPort, this.images);
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = false;
  Uint8List? _combinedImage;

  // Move this to a static method so it can be called from the isolate
  Future<Uint8List> _loadDemoImage(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }

  // This is the function that will run in the isolate
  static Future<void> _isolateFunction(IsolateData data) async {
    try {
      // Initialize RustLib in the isolate
      await RustLib.init();

      // Now we can safely call the Rust function
      final result = await combineImagesVertical(imageBytes: data.images);
      data.sendPort.send(result);
    } catch (e) {
      print('Error in isolate: $e');
      data.sendPort.send(null);
    }
  }

  Future<Uint8List?> _handleImageCombination() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stopwatch = Stopwatch()..start();

      // Create ports for communication
      final receivePort = ReceivePort();

      // Prepare asset paths
      final assetPaths = [
        'assets/demo/receipt_1.jpeg',
        'assets/demo/receipt_1.1.jpeg',
        'assets/demo/receipt_2.jpeg',
      ];

      // Load all images
      final images = await Future.wait(
        assetPaths.map((path) => _loadDemoImage(path)),
      );

      // Create and spawn the isolate
      await Isolate.spawn(
        _isolateFunction,
        IsolateData(receivePort.sendPort, images),
      );

      // Wait for the result
      final result = await receivePort.first as Uint8List?;

      // Stop timing and print results
      stopwatch.stop();
      print('Operation took: ${stopwatch.elapsedMilliseconds} milliseconds');

      return result;
    } catch (e) {
      print('Error: $e');
      return null;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Image Combine with Rust'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  TextButton(
                    onPressed: () async {
                      _combinedImage = null;
                      setState(() {});
                      final result = await _handleImageCombination();
                      _combinedImage = result;
                      setState(() {});
                    },
                    child: const Text("Combine Images"),
                  ),
                if (_combinedImage != null)
                  Image.memory(_combinedImage!)
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
