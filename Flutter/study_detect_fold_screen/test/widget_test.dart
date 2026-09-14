import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:study_detect_fold_screen/main.dart';

void main() {
  testWidgets('shows fold crease bounds from displayFeatures', (tester) async {
    tester.view.physicalSize = const Size(852, 884);
    tester.view.devicePixelRatio = 1;
    tester.view.displayFeatures = const [
      DisplayFeature(
        bounds: Rect.fromLTRB(426, 0, 426, 884),
        type: DisplayFeatureType.fold,
        state: DisplayFeatureState.postureFlat,
      ),
    ];
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const FoldDetectApp());

    expect(find.text('摺疊線偵測'), findsOneWidget);
    expect(find.textContaining('displayFeatures：1'), findsOneWidget);
    expect(find.textContaining('feature[0]  fold  postureFlat'), findsOneWidget);
    expect(find.text('left   426.0'), findsOneWidget);
    expect(find.text('垂直摺線 x = 426.0'), findsOneWidget);
  });

  testWidgets('shows empty state when there is no display feature', (
    tester,
  ) async {
    await tester.pumpWidget(const FoldDetectApp());

    expect(find.textContaining('displayFeatures：0'), findsOneWidget);
    expect(find.textContaining('而家冇 display feature'), findsOneWidget);
  });
}
