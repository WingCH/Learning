import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_golden_test/widgets/custom_star_image.dart';

void main() {
  testWidgets('CustomStarImage Golden Test', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                child: CustomStarImage(
                  height: 200,
                  width: 200,
                  imagePath: 'assets/images/dog.webp',
                ),
              ),
            ),
          ),
        ),
      );

      // Precache image to ensure it's loaded, https://github.com/flutter/flutter/issues/38997#issuecomment-555687558
      final imageWidget = tester.widget<Image>(find.byType(Image));
      await precacheImage(
          imageWidget.image, tester.element(find.byType(Image)));
      await tester.pumpAndSettle();
    });

    await expectLater(
      find.byType(CustomStarImage),
      matchesGoldenFile('goldens/custom_star_image.png'),
    );
  });
}
