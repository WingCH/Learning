import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Custom Range Slider Demo
/// 這個專案展示了如何實現一個自定義的 RangeSlider，
/// 特別解決了只在當前操作的滑塊上顯示值指示器的問題。
///
/// 主要特點：
/// 1. 選擇性值指示器顯示
/// 2. 自定義矩形指示器樣式
/// 3. 精確的滑塊識別
/// 4. 完整的調試輸出

// Debug print function for this project
void debugPrint(String message) {
  print('[RangeSliderDemo] $message');
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RangeSlider Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'RangeSlider with Custom Theme'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// 主頁面狀態
/// 處理滑塊的狀態管理和用戶交互
class _MyHomePageState extends State<MyHomePage> {
  // Constants
  static const double _minValue = 0.0;
  static const double _maxValue = 100.0;
  static const double _thumbRadius = 14.0;
  static const double _overlayRadius = 28.0;
  static const double _trackHeight = 4.0;
  static const double _tickMarkRadius = 3.0;

  // State variables
  RangeValues _currentRangeValues = const RangeValues(20, 80);
  Thumb? _activeThumb;

  // Helper method to get thumb from position
  Thumb _getThumbFromPosition(
      Offset localPosition, BoxConstraints constraints) {
    final double startPos =
        _currentRangeValues.start / _maxValue * constraints.maxWidth;
    final double endPos =
        _currentRangeValues.end / _maxValue * constraints.maxWidth;

    final double startDist = (localPosition.dx - startPos).abs();
    final double endDist = (localPosition.dx - endPos).abs();

    final thumb = startDist < endDist ? Thumb.start : Thumb.end;
    debugPrint(
        'Thumb selected: $thumb (startDist: $startDist, endDist: $endDist)');
    return thumb;
  }

  // Slider theme data
  SliderThemeData _getSliderTheme(BuildContext context) {
    return SliderTheme.of(context).copyWith(
      rangeThumbShape: const RoundRangeSliderThumbShape(
        enabledThumbRadius: _thumbRadius,
        elevation: 4,
      ),
      activeTrackColor: Colors.blue[700],
      inactiveTrackColor: Colors.grey[300],
      rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
      trackHeight: _trackHeight,
      overlayColor: Colors.blue.withOpacity(0.2),
      overlayShape:
          const RoundSliderOverlayShape(overlayRadius: _overlayRadius),
      activeTickMarkColor: Colors.blue[700],
      inactiveTickMarkColor: Colors.grey[300],
      tickMarkShape:
          const RoundSliderTickMarkShape(tickMarkRadius: _tickMarkRadius),
      valueIndicatorColor: Colors.blue,
      valueIndicatorTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      rangeValueIndicatorShape:
          CustomRectangularRangeSliderValueIndicatorShape(_activeThumb),
      showValueIndicator: ShowValueIndicator.always,
    );
  }

  // Event handlers
  void _handleRangeSliderChange(RangeValues values) {
    debugPrint('onChanged: values=$values, current=$_currentRangeValues');
    setState(() {
      _currentRangeValues = values;
    });
  }

  void _handleRangeSliderChangeStart(RangeValues values) {
    debugPrint('onChangeStart: values=$values, current=$_currentRangeValues');
  }

  void _handleRangeSliderChangeEnd(RangeValues values) {
    debugPrint('onChangeEnd: values=$values, current=$_currentRangeValues');
    setState(() {
      _activeThumb = null;
    });
  }

  void _handlePanDown(DragDownDetails details, BoxConstraints constraints) {
    final thumb = _getThumbFromPosition(details.localPosition, constraints);
    debugPrint('onPanDown: position=${details.localPosition}, thumb=$thumb');
    setState(() {
      _activeThumb = thumb;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 添加說明卡片
            const Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '改進說明',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '改進前：',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text('• 兩個滑塊同時顯示值指示器'),
                    SizedBox(height: 8),
                    Text(
                      '改進後：',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text('• 只在當前操作的滑塊顯示值指示器'),
                    Text('• 視覺效果更清晰'),
                    Text('• 直觀顯示正在調整的滑塊'),
                    SizedBox(height: 8),
                    Text(
                      '使用方式：',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text('• 點擊或拖動任一滑塊'),
                    Text('• 觀察值指示器的顯示變化'),
                  ],
                ),
              ),
            ),
            const Text(
              'Select a range:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            SliderTheme(
              data: _getSliderTheme(context),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onPanDown: (details) =>
                        _handlePanDown(details, constraints),
                    child: RangeSlider(
                      values: _currentRangeValues,
                      min: _minValue,
                      max: _maxValue,
                      divisions: 100,
                      labels: RangeLabels(
                        _currentRangeValues.start.round().toString(),
                        _currentRangeValues.end.round().toString(),
                      ),
                      onChanged: _handleRangeSliderChange,
                      onChangeStart: _handleRangeSliderChangeStart,
                      onChangeEnd: _handleRangeSliderChangeEnd,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Selected Range: ${_currentRangeValues.start.round()} - ${_currentRangeValues.end.round()}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// 自定義矩形範圍滑塊值指示器
/// 實現了一個矩形樣式的值指示器，只在當前操作的滑塊上顯示
///
/// 特點：
/// - 支援動態顯示/隱藏
/// - 自定義外觀樣式
/// - 精確的位置計算
class CustomRectangularRangeSliderValueIndicatorShape
    extends RangeSliderValueIndicatorShape {
  final Thumb? activeThumb;
  static const _RectangularSliderValueIndicatorPathPainter _pathPainter =
      _RectangularSliderValueIndicatorPathPainter();

  const CustomRectangularRangeSliderValueIndicatorShape(this.activeThumb);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double>? activationAnimation,
    Animation<double>? enableAnimation,
    bool? isDiscrete,
    bool? isOnTop,
    TextPainter? labelPainter,
    double? textScaleFactor,
    Size? sizeWithOverflow,
    RenderBox? parentBox,
    SliderThemeData? sliderTheme,
    TextDirection? textDirection,
    double? value,
    Thumb? thumb,
  }) {
    // Only show indicator for active thumb
    if (activeThumb == null ||
        activeThumb != thumb ||
        activationAnimation!.value == 0) {
      return;
    }

    debugPrint('Painting value indicator: thumb=$thumb, value=$value');

    final Canvas canvas = context.canvas;
    final double scale = activationAnimation.value;
    _pathPainter.paint(
      parentBox: parentBox!,
      canvas: canvas,
      center: center,
      scale: scale,
      labelPainter: labelPainter!,
      textScaleFactor: textScaleFactor!,
      sizeWithOverflow: sizeWithOverflow!,
      backgroundPaintColor: sliderTheme!.valueIndicatorColor!,
      strokePaintColor: isOnTop!
          ? sliderTheme.overlappingShapeStrokeColor
          : sliderTheme.valueIndicatorStrokeColor,
    );
  }

  @override
  Size getPreferredSize(
    bool isEnabled,
    bool isDiscrete, {
    required TextPainter labelPainter,
    required double textScaleFactor,
  }) {
    assert(textScaleFactor >= 0);
    return _pathPainter.getPreferredSize(labelPainter, textScaleFactor);
  }

  @override
  double getHorizontalShift({
    RenderBox? parentBox,
    Offset? center,
    TextPainter? labelPainter,
    Animation<double>? activationAnimation,
    double? textScaleFactor,
    Size? sizeWithOverflow,
  }) {
    return _pathPainter.getHorizontalShift(
      parentBox: parentBox!,
      center: center!,
      labelPainter: labelPainter!,
      textScaleFactor: textScaleFactor!,
      sizeWithOverflow: sizeWithOverflow!,
      scale: activationAnimation!.value,
    );
  }
}

/// 矩形值指示器路徑繪製器
/// 負責具體的繪製邏輯，包括：
/// - 計算指示器大小
/// - 處理位置偏移
/// - 繪製背景和文字
class _RectangularSliderValueIndicatorPathPainter {
  const _RectangularSliderValueIndicatorPathPainter();

  // Constants for painting
  static const double _triangleHeight = 8.0;
  static const double _labelPadding = 16.0;
  static const double _preferredHeight = 32.0;
  static const double _minLabelWidth = 16.0;
  static const double _bottomTipYOffset = 14.0;
  static const double _preferredHalfHeight = _preferredHeight / 2;
  static const double _upperRectRadius = 4;

  Size getPreferredSize(
    TextPainter labelPainter,
    double textScaleFactor,
  ) {
    return Size(
      _upperRectangleWidth(labelPainter, 1, textScaleFactor),
      labelPainter.height + _labelPadding,
    );
  }

  double getHorizontalShift({
    required RenderBox parentBox,
    required Offset center,
    required TextPainter labelPainter,
    required double textScaleFactor,
    required Size sizeWithOverflow,
    required double scale,
  }) {
    assert(!sizeWithOverflow.isEmpty);

    const double edgePadding = 8.0;
    final double rectangleWidth =
        _upperRectangleWidth(labelPainter, scale, textScaleFactor);
    final Offset globalCenter = parentBox.localToGlobal(center);

    final double overflowLeft =
        math.max(0, rectangleWidth / 2 - globalCenter.dx + edgePadding);
    final double overflowRight = math.max(
      0,
      rectangleWidth / 2 -
          (sizeWithOverflow.width - globalCenter.dx - edgePadding),
    );

    if (rectangleWidth < sizeWithOverflow.width) {
      return overflowLeft - overflowRight;
    } else if (overflowLeft - overflowRight > 0) {
      return overflowLeft - (edgePadding * textScaleFactor);
    } else {
      return -overflowRight + (edgePadding * textScaleFactor);
    }
  }

  double _upperRectangleWidth(
      TextPainter labelPainter, double scale, double textScaleFactor) {
    final double unscaledWidth =
        math.max(_minLabelWidth * textScaleFactor, labelPainter.width) +
            _labelPadding * 2;
    return unscaledWidth * scale;
  }

  void paint({
    required RenderBox parentBox,
    required Canvas canvas,
    required Offset center,
    required double scale,
    required TextPainter labelPainter,
    required double textScaleFactor,
    required Size sizeWithOverflow,
    required Color backgroundPaintColor,
    Color? strokePaintColor,
  }) {
    if (scale == 0.0) {
      return;
    }

    final double rectangleWidth =
        _upperRectangleWidth(labelPainter, scale, textScaleFactor);
    final double horizontalShift = getHorizontalShift(
      parentBox: parentBox,
      center: center,
      labelPainter: labelPainter,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
      scale: scale,
    );

    final double rectHeight = labelPainter.height + _labelPadding;
    final Rect upperRect = Rect.fromLTWH(
      -rectangleWidth / 2 + horizontalShift,
      -_triangleHeight - rectHeight,
      rectangleWidth,
      rectHeight,
    );

    final Path trianglePath = Path()
      ..lineTo(-_triangleHeight, -_triangleHeight)
      ..lineTo(_triangleHeight, -_triangleHeight)
      ..close();
    final Paint fillPaint = Paint()..color = backgroundPaintColor;
    final RRect upperRRect = RRect.fromRectAndRadius(
        upperRect, const Radius.circular(_upperRectRadius));
    trianglePath.addRRect(upperRRect);

    canvas.save();
    canvas.translate(center.dx, center.dy - _bottomTipYOffset);
    canvas.scale(scale, scale);

    if (strokePaintColor != null) {
      final Paint strokePaint = Paint()
        ..color = strokePaintColor
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawPath(trianglePath, strokePaint);
    }
    canvas.drawPath(trianglePath, fillPaint);

    final double bottomTipToUpperRectTranslateY =
        -_preferredHalfHeight / 2 - upperRect.height;
    canvas.translate(0, bottomTipToUpperRectTranslateY);
    final Offset boxCenter = Offset(horizontalShift, upperRect.height / 2);
    final Offset halfLabelPainterOffset =
        Offset(labelPainter.width / 2, labelPainter.height / 2);
    final Offset labelOffset = boxCenter - halfLabelPainterOffset;
    labelPainter.paint(canvas, labelOffset);
    canvas.restore();
  }
}

// 添加自定義的 RangeSlider
class CustomRangeSlider extends RangeSlider {
  final void Function(Thumb?)? onThumbChange;

  CustomRangeSlider({
    super.key,
    required super.values,
    required super.onChanged,
    super.onChangeStart,
    super.onChangeEnd,
    super.min = 0.0,
    super.max = 1.0,
    super.divisions,
    super.labels,
    super.activeColor,
    super.inactiveColor,
    super.semanticFormatterCallback,
    this.onThumbChange,
  });

  @override
  State<RangeSlider> createState() => _CustomRangeSliderState();
}

class _CustomRangeSliderState extends State<CustomRangeSlider> {
  RangeValues? _lastValues;

  @override
  Widget build(BuildContext context) {
    return RangeSlider(
      values: widget.values,
      onChanged: (RangeValues values) {
        // 檢測哪個滑塊在移動
        if (_lastValues != null) {
          if (values.start != _lastValues!.start &&
              values.end == _lastValues!.end) {
            widget.onThumbChange?.call(Thumb.start);
          } else if (values.end != _lastValues!.end &&
              values.start == _lastValues!.start) {
            widget.onThumbChange?.call(Thumb.end);
          }
        }
        _lastValues = values;
        widget.onChanged?.call(values);
      },
      onChangeStart: (RangeValues values) {
        _lastValues = values;
        widget.onChangeStart?.call(values);
      },
      onChangeEnd: (RangeValues values) {
        _lastValues = null;
        widget.onThumbChange?.call(null);
        widget.onChangeEnd?.call(values);
      },
      min: widget.min,
      max: widget.max,
      divisions: widget.divisions,
      labels: widget.labels,
      activeColor: widget.activeColor,
      inactiveColor: widget.inactiveColor,
      semanticFormatterCallback: widget.semanticFormatterCallback,
    );
  }
}
