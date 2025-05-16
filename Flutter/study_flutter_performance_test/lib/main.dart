import 'package:flutter/material.dart';
import 'performance_comparison.dart';

void main() {
  // IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  runApp(
    PerformanceComparisonApp(
      items: List<String>.generate(10000, (i) => 'Item $i'),
    ),
  );
}
