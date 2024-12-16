// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:image_combine/image_combine.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'dart:io';

void main() {
  group('ImageCombiner Tests', () {
    // Create base test output directory
    final baseOutputDir = Directory('test/output');

    setUp(() {
      if (!baseOutputDir.existsSync()) {
        baseOutputDir.createSync();
      }
    });

    test('should throw exception when no images provided', () {
      expect(
        () => ImageCombiner.combineImagesVertically([]),
        throwsException,
      );
    });

    test('should combine images vertically and save to file', () async {
      final stopwatch = Stopwatch()..start();

      // Create test case specific directory
      final testDir = Directory('test/output/same_width_test');
      if (!testDir.existsSync()) {
        testDir.createSync(recursive: true);
      }

      print('Directory creation: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.reset();

      // Create two test images
      final image1 = img.Image(width: 100, height: 100);
      final image2 = img.Image(width: 100, height: 150);

      // Fill images with different colors
      img.fill(image1, color: img.ColorRgb8(255, 0, 0)); // Red
      img.fill(image2, color: img.ColorRgb8(0, 255, 0)); // Green

      print('Image creation: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.reset();

      // Save individual test images
      File('${testDir.path}/input_image1.png')
          .writeAsBytesSync(img.encodePng(image1));
      File('${testDir.path}/input_image2.png')
          .writeAsBytesSync(img.encodePng(image2));

      print('Save input images: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.reset();

      // Convert images to Uint8List
      final imageData1 = Uint8List.fromList(img.encodePng(image1));
      final imageData2 = Uint8List.fromList(img.encodePng(image2));

      print('Convert to Uint8List: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.reset();

      // Combine images
      final result = await ImageCombiner.combineImagesVertically([
        imageData1,
        imageData2,
      ]);

      print('Image combination: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.reset();

      // Save combined result
      File('${testDir.path}/result_combined.png').writeAsBytesSync(result);

      print('Save result: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.reset();

      // Verify result
      expect(result, isA<Uint8List>());

      final combinedImage = img.decodeImage(result);
      expect(combinedImage, isNotNull);
      expect(combinedImage!.width, 100);
      expect(combinedImage.height, 250); // 100 + 150

      print('Verification: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.stop();
    });

    test('should handle images with different widths and save to file',
        () async {
      final stopwatch = Stopwatch()..start();

      // Create test case specific directory
      final testDir = Directory('test/output/different_width_test');
      if (!testDir.existsSync()) {
        testDir.createSync(recursive: true);
      }

      print('Directory creation: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.reset();

      // Create two test images with different widths
      final image1 = img.Image(width: 100, height: 100);
      final image2 = img.Image(width: 150, height: 100);

      img.fill(image1, color: img.ColorRgb8(255, 0, 0));
      img.fill(image2, color: img.ColorRgb8(0, 255, 0));

      print('Image creation: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.reset();

      // Save individual test images
      File('${testDir.path}/input_image1.png')
          .writeAsBytesSync(img.encodePng(image1));
      File('${testDir.path}/input_image2.png')
          .writeAsBytesSync(img.encodePng(image2));

      print('Save input images: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.reset();

      final imageData1 = Uint8List.fromList(img.encodePng(image1));
      final imageData2 = Uint8List.fromList(img.encodePng(image2));

      print('Convert to Uint8List: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.reset();

      final result = await ImageCombiner.combineImagesVertically([
        imageData1,
        imageData2,
      ]);

      print('Image combination: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.reset();

      // Save combined result
      File('${testDir.path}/result_combined.png').writeAsBytesSync(result);

      print('Save result: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.reset();

      final combinedImage = img.decodeImage(result);
      expect(combinedImage, isNotNull);
      expect(combinedImage!.width, 150); // Should use the larger width
      expect(combinedImage.height, 200); // 100 + 100

      print('Verification: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.stop();
    });

    test('should combine real images - case 1', () async {
      final stopwatch = Stopwatch()..start();

      // Create test case specific directory
      final testDir = Directory('test/output/real_case_1');
      if (!testDir.existsSync()) {
        testDir.createSync(recursive: true);
      }

      print('Directory creation: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.reset();

      // Read image files
      final List<File> inputFiles = [
        File('${testDir.path}/receipt_1.jpeg'),
        File('${testDir.path}/receipt_1.1.jpeg'),
        File('${testDir.path}/receipt_2.jpeg'),
      ];

      // Convert files to Uint8List
      final List<Uint8List> imageDataList = [];
      for (var file in inputFiles) {
        final bytes = await file.readAsBytes();
        imageDataList.add(bytes);

        // Copy input files to test directory for reference
        final fileName = file.path.split('/').last;
        await File('${testDir.path}/input_$fileName').writeAsBytes(bytes);
      }

      print('Load input images: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.reset();

      // Combine images
      final result = await ImageCombiner.combineImagesVertically(imageDataList);

      print('Image combination: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.reset();

      // Save combined result
      await File('${testDir.path}/result_combined.png').writeAsBytes(result);

      print('Save result: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.reset();

      // Verify result
      expect(result, isA<Uint8List>());

      final combinedImage = img.decodeImage(result);
      expect(combinedImage, isNotNull);

      print('Verification: ${stopwatch.elapsedMilliseconds}ms');
      stopwatch.stop();
    });

    // Clean up test files after all tests
    tearDownAll(() {
      // Optionally remove test files
      // baseOutputDir.deleteSync(recursive: true);
    });
  });
}
