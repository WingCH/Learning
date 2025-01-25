import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_golden_test/widgets/custom_button.dart';

void main() {
  testWidgets('CustomButton Golden Test', (WidgetTester tester) async {
    // Test normal button
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CustomButton(
              onPressed: () {},
              child: const Text('Click Me'),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(CustomButton),
      matchesGoldenFile('goldens/custom_button_normal.png'),
    );

    // Test button with icon
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CustomButton(
              onPressed: () {},
              icon: const Icon(Icons.add),
              child: const Text('Add Item'),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(CustomButton),
      matchesGoldenFile('goldens/custom_button_with_icon.png'),
    );

    // Test disabled button
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CustomButton(
              onPressed: null,
              child: Text('Disabled'),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(CustomButton),
      matchesGoldenFile('goldens/custom_button_disabled.png'),
    );
  });
}
