import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alchemist/alchemist.dart';
import 'package:study_golden_test/widgets/custom_button.dart';

void main() {
  group('CustomButton Golden Test', () {
    goldenTest(
      'renders correctly',
      fileName: 'custom_button',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'enabled',
            child: CustomButton(
              onPressed: () {},
              child: const Text('Enabled'),
            ),
          ),
          GoldenTestScenario(
            name: 'disabled',
            child: const CustomButton(
              onPressed: null,
              child: Text('Disabled'),
            ),
          ),
        ],
      ),
    );
    goldenTest(
      'CustomButton renders tap indicator when pressed',
      fileName: 'custom_button_pressed',
      whilePerforming: press(find.byType(CustomButton)),
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'pressed',
            child: CustomButton(
              onPressed: () {},
              child: const Text('Pressed'),
            ),
          ),
        ],
      ),
    );
  });
}
