import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_combine/image_combine.dart';

/*
Result:
Pixel 8 pro, flutter 3.27.0 profile mode
combine 3 images
1. 3024 × 4032 2.5mb
2. 3024 × 4032 2.8 mb
3. 3024 × 4032 3 mb

use dart image package
main thread, loading view will very lag 
I/flutter (16717): Image 1 size: 2489146 bytes
I/flutter (16717): Image 1.1 size: 2816887 bytes
I/flutter (16717): Image 2 size: 2962509 bytes
I/flutter (16717): Operation took: 17667 milliseconds
I/flutter (16717): Result size: 26052038 bytes


use dart image package
isolateis, loagin view very smooth
I/flutter (19096): Image 1 size: 2489146 bytes
I/flutter (19096): Image 1.1 size: 2816887 bytes
I/flutter (19096): Image 2 size: 2962509 bytes
I/flutter (19096): Operation took: 42840 milliseconds
I/flutter (19096): Result size: 26052038 bytes
*/
void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

// Data class to pass to isolate
class IsolateData {
  final List<Uint8List> images;
  IsolateData(this.images);
}

// Function to run in isolate
Future<Uint8List> combineImagesInIsolate(IsolateData data) async {
  final result = await ImageCombiner.combineImagesVertically(data.images);
  return result;
}

class _MainAppState extends State<MainApp> {
  bool _isLoading = false;

  // Function to load demo image from assets
  Future<Uint8List> _loadDemoImage(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }

  // Function to handle image combination process
  Future<void> _handleImageCombination() async {
    try {
      // Load demo images
      final image1 = await _loadDemoImage('assets/demo/receipt_1.jpeg');
      final image1_1 = await _loadDemoImage('assets/demo/receipt_1.1.jpeg');
      final image2 = await _loadDemoImage('assets/demo/receipt_2.jpeg');

      // Print image sizes
      print('Image 1 size: ${image1.length} bytes');
      print('Image 1.1 size: ${image1_1.length} bytes');
      print('Image 2 size: ${image2.length} bytes');

      final stopwatch = Stopwatch()..start();

      // Create receive port for communication with isolate
      final receivePort = ReceivePort();

      // Spawn isolate
      final isolate = await Isolate.spawn(
        (message) async {
          final SendPort sendPort = message[0] as SendPort;
          final IsolateData isolateData = message[1] as IsolateData;

          // Process images in isolate
          final result = await combineImagesInIsolate(isolateData);

          // Send result back to main isolate
          sendPort.send(result);
        },
        [
          receivePort.sendPort,
          IsolateData([image1, image1_1, image2]),
        ],
      );

      // Wait for result from isolate
      final result = await receivePort.first as Uint8List;

      // Clean up
      receivePort.close();
      isolate.kill();

      // Stop timing and print results
      stopwatch.stop();
      print('Operation took: ${stopwatch.elapsedMilliseconds} milliseconds');
      print('Result size: ${result.length} bytes');
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else
                TextButton(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });

                    await _handleImageCombination();

                    setState(() {
                      _isLoading = false;
                    });
                  },
                  child: const Text('Combine'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
