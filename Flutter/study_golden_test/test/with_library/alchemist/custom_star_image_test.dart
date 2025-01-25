import 'package:alchemist/alchemist.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_golden_test/widgets/custom_star_image.dart';

void main() {
  group('CustomStarImage Golden Test', () {
    goldenTest(
      'renders correctly',
      fileName: 'custom_star_image',
      pumpBeforeTest: precacheImages,
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'normal',
            child: const CustomStarImage(
              height: 200,
              width: 200,
              imagePath: 'assets/images/dog.webp',
            ),
          ),
        ],
      ),
    );
  });
}
