import 'dart:ui' show DisplayFeature, DisplayFeatureType;

import 'package:flutter/material.dart';

void main() {
  runApp(const FoldDetectApp());
}

class FoldDetectApp extends StatelessWidget {
  const FoldDetectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fold Detect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const FoldDetectPage(),
    );
  }
}

class FoldDetectPage extends StatelessWidget {
  const FoldDetectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final features = MediaQuery.displayFeaturesOf(context);
    final size = MediaQuery.sizeOf(context);
    final creases = features
        .where(
          (feature) =>
              feature.type == DisplayFeatureType.fold ||
              feature.type == DisplayFeatureType.hinge,
        )
        .toList();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: _FeatureInfoPanel(
              screenSize: size,
              features: features,
              creases: creases,
            ),
          ),
          IgnorePointer(
            child: CustomPaint(
              painter: DisplayFeaturePainter(features: features),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureInfoPanel extends StatelessWidget {
  const _FeatureInfoPanel({
    required this.screenSize,
    required this.features,
    required this.creases,
  });

  final Size screenSize;
  final List<DisplayFeature> features;
  final List<DisplayFeature> creases;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('摺疊線偵測', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'MediaQuery.displayFeaturesOf(context)',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 12),
        Text(
          '畫面 ${screenSize.width.toStringAsFixed(1)} × ${screenSize.height.toStringAsFixed(1)}',
        ),
        Text('displayFeatures：${features.length}'),
        const SizedBox(height: 12),
        if (features.isEmpty) const Text('而家冇 display feature。應該要係摺疊機，先會報摺線。'),
        for (var i = 0; i < features.length; i++)
          _FeatureCard(index: i, feature: features[i]),
        if (creases.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final crease in creases) Text(_creaseSummary(crease)),
        ],
      ],
    );
  }

  String _creaseSummary(DisplayFeature feature) {
    final bounds = feature.bounds;
    if (bounds.height >= bounds.width) {
      return '垂直摺線 x = ${bounds.center.dx.toStringAsFixed(1)}';
    }
    return '水平摺線 y = ${bounds.center.dy.toStringAsFixed(1)}';
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.index, required this.feature});

  final int index;
  final DisplayFeature feature;

  @override
  Widget build(BuildContext context) {
    final bounds = feature.bounds;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              'feature[$index]  ${feature.type.name}  ${feature.state.name}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text('left   ${bounds.left.toStringAsFixed(1)}'),
            Text('top    ${bounds.top.toStringAsFixed(1)}'),
            Text('right  ${bounds.right.toStringAsFixed(1)}'),
            Text('bottom ${bounds.bottom.toStringAsFixed(1)}'),
            Text(
              'size   ${bounds.width.toStringAsFixed(1)} × ${bounds.height.toStringAsFixed(1)}',
            ),
            Text(
              'center (${bounds.center.dx.toStringAsFixed(1)}, ${bounds.center.dy.toStringAsFixed(1)})',
            ),
          ],
        ),
      ),
    );
  }
}

class DisplayFeaturePainter extends CustomPainter {
  const DisplayFeaturePainter({required this.features});

  final List<DisplayFeature> features;

  @override
  void paint(Canvas canvas, Size size) {
    for (final feature in features) {
      final rect = _visibleRect(feature.bounds, size);
      final isCrease =
          feature.type == DisplayFeatureType.fold ||
          feature.type == DisplayFeatureType.hinge;
      final color = switch (feature.type) {
        DisplayFeatureType.fold => Colors.deepPurple,
        DisplayFeatureType.hinge => Colors.indigo,
        DisplayFeatureType.cutout => Colors.orange,
        DisplayFeatureType.unknown => Colors.grey,
      };

      if (rect.width > 2 && rect.height > 2) {
        canvas.drawRect(rect, Paint()..color = color.withValues(alpha: 0.18));
      }

      _drawDashedRect(
        canvas,
        rect,
        Paint()
          ..color = color
          ..style = .stroke
          ..strokeWidth = isCrease ? 3 : 2,
      );
    }
  }

  Rect _visibleRect(Rect bounds, Size size) {
    var rect = bounds;
    if (rect.width < 2) {
      rect = Rect.fromCenter(
        center: rect.center,
        width: 2,
        height: rect.height.clamp(2, size.height),
      );
    }
    if (rect.height < 2) {
      rect = Rect.fromCenter(
        center: rect.center,
        width: rect.width.clamp(2, size.width),
        height: 2,
      );
    }
    return rect;
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    const dash = 10.0;
    const gap = 6.0;
    _drawDashedLine(canvas, rect.topLeft, rect.topRight, paint, dash, gap);
    _drawDashedLine(canvas, rect.topRight, rect.bottomRight, paint, dash, gap);
    _drawDashedLine(
      canvas,
      rect.bottomRight,
      rect.bottomLeft,
      paint,
      dash,
      gap,
    );
    _drawDashedLine(canvas, rect.bottomLeft, rect.topLeft, paint, dash, gap);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double dash,
    double gap,
  ) {
    final delta = end - start;
    final distance = delta.distance;
    if (distance == 0) {
      return;
    }
    final direction = delta / distance;
    var drawn = 0.0;
    var drawDash = true;
    while (drawn < distance) {
      final step = drawDash ? dash : gap;
      final next = (drawn + step).clamp(0.0, distance);
      if (drawDash) {
        canvas.drawLine(
          start + direction * drawn,
          start + direction * next,
          paint,
        );
      }
      drawn = next;
      drawDash = !drawDash;
    }
  }

  @override
  bool shouldRepaint(DisplayFeaturePainter oldDelegate) {
    return oldDelegate.features != features;
  }
}
