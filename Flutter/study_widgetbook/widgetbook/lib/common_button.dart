import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:study_widgetbook/widgets/common_button.dart';

@widgetbook.UseCase(name: 'Normal style', type: CommonButton)
Widget buildCoolButtonUseCase(BuildContext context) {
  return Center(
    child: CommonButton(
      onPressed: () {},
      title: 'Button',
      buttonStyle: CommonButtonStyle.normal,
      isBtnEnabled:
          context.knobs.boolean(label: 'Is button enabled', initialValue: true),
    ),
  );
}

@widgetbook.UseCase(name: 'Outline style', type: CommonButton)
Widget buildCoolButtonUseCase3(BuildContext context) {
  return Center(
    child: CommonButton(
      onPressed: () {},
      title: context.knobs.string(label: 'Title', initialValue: 'Button'),
      buttonStyle: CommonButtonStyle.outline,
      isBtnEnabled:
          context.knobs.boolean(label: 'Is button enabled', initialValue: true),
    ),
  );
}
