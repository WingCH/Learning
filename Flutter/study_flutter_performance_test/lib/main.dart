import 'package:flutter/material.dart';
import 'performance_comparison.dart';

void main() {
  runApp(PerformanceComparisonApp(
    items: List<String>.generate(10000, (i) => 'Item $i'),
  ));
}