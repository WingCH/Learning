library image_combine;

import 'package:image/image.dart' as img;
import 'dart:typed_data';

class ImageCombiner {
  /// Combines multiple images vertically into a single image
  /// Returns a Future<Uint8List> containing the combined image data
  static Future<Uint8List> combineImagesVertically(
      List<Uint8List> images) async {
    if (images.isEmpty) {
      throw Exception('No images provided');
    }

    // Decode all images
    List<img.Image> decodedImages = [];
    int totalHeight = 0;
    int maxWidth = 0;

    for (var imageData in images) {
      final image = img.decodeImage(imageData);
      if (image == null) continue;

      decodedImages.add(image);
      totalHeight += image.height;
      maxWidth = maxWidth < image.width ? image.width : maxWidth;
    }

    // Create a new image with combined dimensions
    final combinedImage = img.Image(
      width: maxWidth,
      height: totalHeight,
    );

    // Draw each image vertically
    int currentY = 0;
    for (var image in decodedImages) {
      img.compositeImage(
        combinedImage,
        image,
        dstY: currentY,
      );
      currentY += image.height;
    }

    // Encode the final image to PNG format
    return Uint8List.fromList(img.encodePng(combinedImage));
  }
}
