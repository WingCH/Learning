import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

void main() {
  runApp(const TopographicApp());
}

class TopographicApp extends StatelessWidget {
  const TopographicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Topographic Shader',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        useMaterial3: true,
      ),
      home: const TopographicPage(),
    );
  }
}

class TopographicPage extends StatefulWidget {
  const TopographicPage({super.key});

  @override
  State<TopographicPage> createState() => _TopographicPageState();
}

class _TopographicPageState extends State<TopographicPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock;

  ui.FragmentProgram? _program;
  String? _shaderLoadError;
  Offset? _pointerPosition;
  bool _pointerIsActive = false;
  bool _pointerIsPressed = false;
  bool _shaderEnabled = true;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 20),
    )..repeat();
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'shaders/topographic.frag',
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _program = program;
        _shaderLoadError = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _shaderLoadError = error.toString();
      });
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  void _updatePointer(PointerEvent event) {
    setState(() {
      _pointerPosition = event.localPosition;
      _pointerIsActive = true;
    });
  }

  void _handlePointerDown(PointerDownEvent event) {
    setState(() {
      _pointerPosition = event.localPosition;
      _pointerIsActive = true;
      _pointerIsPressed = true;
    });
  }

  void _handlePointerUp(PointerEvent event) {
    setState(() {
      _pointerPosition = event.localPosition;
      _pointerIsActive = true;
      _pointerIsPressed = false;
    });
  }

  void _handlePointerExit() {
    setState(() {
      _pointerIsActive = false;
      _pointerIsPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _clock,
        builder: (BuildContext context, Widget? child) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return MouseRegion(
                onExit: (_) => _handlePointerExit(),
                cursor: SystemMouseCursors.precise,
                child: Listener(
                  onPointerHover: _updatePointer,
                  onPointerMove: _updatePointer,
                  onPointerDown: _handlePointerDown,
                  onPointerUp: _handlePointerUp,
                  onPointerCancel: _handlePointerUp,
                  behavior: HitTestBehavior.opaque,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      RepaintBoundary(
                        child: CustomPaint(
                          painter: TopographicPainter(
                            elapsedSeconds: _clock.value * 90.0,
                            pointerIsActive: _pointerIsActive,
                            pointerIsPressed: _pointerIsPressed,
                            pointerPosition: _pointerPosition,
                            program: _program,
                            shaderEnabled: _shaderEnabled,
                          ),
                        ),
                      ),
                      const Positioned(
                        top: 20,
                        left: 24,
                        child: _SceneLabel(
                          text: 'Topographic',
                        ),
                      ),
                      Positioned(
                        right: 24,
                        bottom: 24,
                        child: _SceneLabel(
                          text: _pointerIsPressed
                              ? 'Pressing to carve'
                              : 'Move to elevate',
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Positioned(
                        top: 18,
                        right: 20,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xCC0A0A0A),
                            border: Border.all(
                              color: const Color(0x26C8956C),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'Shader',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: const Color(0xCCDBB08A),
                                        fontFamily: 'monospace',
                                        letterSpacing: 1.2,
                                      ),
                                ),
                                const SizedBox(width: 10),
                                Switch(
                                  value: _shaderEnabled,
                                  activeThumbColor: const Color(0xFFD4A574),
                                  activeTrackColor: const Color(0x66D4A574),
                                  inactiveThumbColor: const Color(0xFF5C4738),
                                  inactiveTrackColor: const Color(0x33181818),
                                  onChanged: (bool value) {
                                    setState(() {
                                      _shaderEnabled = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_shaderEnabled && _shaderLoadError != null)
                        Positioned(
                          left: 24,
                          bottom: 24,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xCC0A0A0A),
                              border: Border.all(
                                color: const Color(0x26C8956C),
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Text(
                                'Shader fallback active',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: const Color(0x80C8956C),
                                      fontFamily: 'monospace',
                                      letterSpacing: 1.2,
                                    ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SceneLabel extends StatelessWidget {
  const _SceneLabel({
    required this.text,
    this.textAlign,
  });

  final String text;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: const TextStyle(
        color: Color(0x80C8956C),
        fontFamily: 'monospace',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 2.4,
      ),
    );
  }
}

class TopographicPainter extends CustomPainter {
  static const double _cellSize = 12;
  static const int _numContours = 14;
  static const double _noiseScale = 0.003;
  static const double _labelDensity = 0.003;
  static const double _majorLabelDistance = 120;
  static const List<List<List<int>>> _edgeTable = <List<List<int>>>[
    <List<int>>[],
    <List<int>>[
      <int>[3, 2],
    ],
    <List<int>>[
      <int>[2, 1],
    ],
    <List<int>>[
      <int>[3, 1],
    ],
    <List<int>>[
      <int>[1, 0],
    ],
    <List<int>>[
      <int>[1, 0],
      <int>[3, 2],
    ],
    <List<int>>[
      <int>[2, 0],
    ],
    <List<int>>[
      <int>[3, 0],
    ],
    <List<int>>[
      <int>[0, 3],
    ],
    <List<int>>[
      <int>[0, 2],
    ],
    <List<int>>[
      <int>[0, 3],
      <int>[2, 1],
    ],
    <List<int>>[
      <int>[0, 1],
    ],
    <List<int>>[
      <int>[1, 3],
    ],
    <List<int>>[
      <int>[1, 2],
    ],
    <List<int>>[
      <int>[2, 3],
    ],
    <List<int>>[],
  ];
  static final _SimplexNoise3d _noise = _SimplexNoise3d(seed: 73);

  TopographicPainter({
    required this.elapsedSeconds,
    required this.pointerIsActive,
    required this.pointerIsPressed,
    required this.pointerPosition,
    required this.program,
    required this.shaderEnabled,
  });

  final double elapsedSeconds;
  final bool pointerIsActive;
  final bool pointerIsPressed;
  final Offset? pointerPosition;
  final ui.FragmentProgram? program;
  final bool shaderEnabled;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = const Color(0xFF0A0A0A));

    final ui.FragmentProgram? program = this.program;
    if (!shaderEnabled || program == null) {
      _paintFallbackBackground(canvas: canvas, rect: rect);
    } else {
      final ui.FragmentShader shader = program.fragmentShader();
      final Offset resolvedPointerPosition = pointerPosition ??
          Offset(
            size.width * 0.5,
            size.height * 0.5,
          );

      shader.setFloat(0, size.width);
      shader.setFloat(1, size.height);
      shader.setFloat(2, elapsedSeconds);
      shader.setFloat(3, resolvedPointerPosition.dx);
      shader.setFloat(4, resolvedPointerPosition.dy);
      shader.setFloat(5, pointerIsActive ? 1.0 : 0.0);
      shader.setFloat(6, pointerIsPressed ? -1.0 : 1.0);

      canvas.drawRect(
        rect,
        Paint()..shader = shader,
      );
    }

    _paintContours(
      canvas: canvas,
      size: size,
    );
    _paintVignette(
      canvas: canvas,
      rect: rect,
    );
  }

  void _paintFallbackBackground({
    required Canvas canvas,
    required Rect rect,
  }) {
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF11100E),
            Color(0xFF0A0A0A),
            Color(0xFF140F0C),
          ],
          stops: <double>[0.0, 0.5, 1.0],
        ).createShader(rect),
    );
  }

  void _paintContours({
    required Canvas canvas,
    required Size size,
  }) {
    final int columns = (size.width / _cellSize).ceil() + 1;
    final int rows = (size.height / _cellSize).ceil() + 1;
    final Float32List field = Float32List(columns * rows);
    final Offset resolvedPointer = pointerPosition ??
        Offset(
          size.width * 0.5,
          size.height * 0.5,
        );

    double minValue = double.infinity;
    double maxValue = -double.infinity;

    for (int row = 0; row < rows; row++) {
      for (int column = 0; column < columns; column++) {
        final double x = column * _cellSize;
        final double y = row * _cellSize;
        double value = _fbm(
          x: x * _noiseScale,
          y: y * _noiseScale,
          z: elapsedSeconds * 0.15,
        );

        if (pointerIsActive) {
          final double dx = x - resolvedPointer.dx;
          final double dy = y - resolvedPointer.dy;
          final double distance = math.sqrt(dx * dx + dy * dy);
          final double radius = math.min(size.width, size.height) * 0.2;

          if (distance < radius) {
            final double falloff = 1 - distance / radius;
            final double direction = pointerIsPressed ? -0.5 : 0.5;
            value += direction * falloff * falloff;
          }
        }

        field[row * columns + column] = value;
        minValue = math.min(minValue, value);
        maxValue = math.max(maxValue, value);
      }
    }

    final double range = maxValue - minValue == 0 ? 1 : maxValue - minValue;
    for (int index = 0; index < field.length; index++) {
      field[index] = (field[index] - minValue) / range;
    }

    final List<_ContourLabelCandidate> labelCandidates =
        <_ContourLabelCandidate>[];

    for (int contourIndex = 0;
        contourIndex < _numContours;
        contourIndex++) {
      final double threshold = (contourIndex + 1) / (_numContours + 1);
      final bool isMajor = contourIndex % 5 == 0;
      final double distanceFromCenter = (threshold - 0.5).abs() * 2;
      final double baseAlpha = 0.25 + (1 - distanceFromCenter) * 0.45;
      final double glowWidth = isMajor ? 4.5 : 2.5;
      final double sharpWidth = isMajor ? 1.2 : 0.6;
      final double glowAlpha = baseAlpha * 0.25;
      final double sharpAlpha = baseAlpha * (isMajor ? 1.0 : 0.8);
      final Color lineColor = _lineColor(threshold: threshold);
      final Path glowPath = Path();
      final Path sharpPath = Path();
      int segmentCount = 0;

      for (int row = 0; row < rows - 1; row++) {
        for (int column = 0; column < columns - 1; column++) {
          final double topLeft = field[row * columns + column];
          final double topRight = field[row * columns + column + 1];
          final double bottomRight = field[(row + 1) * columns + column + 1];
          final double bottomLeft = field[(row + 1) * columns + column];

          final int caseIndex =
              (topLeft >= threshold ? 8 : 0) |
                  (topRight >= threshold ? 4 : 0) |
                  (bottomRight >= threshold ? 2 : 0) |
                  (bottomLeft >= threshold ? 1 : 0);

          final List<List<int>> edges = _edgeTable[caseIndex];
          if (edges.isEmpty) {
            continue;
          }

          final double cellX = column * _cellSize;
          final double cellY = row * _cellSize;

          for (final List<int> edgePair in edges) {
            final Offset start = _edgePoint(
              edge: edgePair[0],
              cellX: cellX,
              cellY: cellY,
              cellWidth: _cellSize,
              cellHeight: _cellSize,
              topLeft: topLeft,
              topRight: topRight,
              bottomRight: bottomRight,
              bottomLeft: bottomLeft,
              threshold: threshold,
            );
            final Offset end = _edgePoint(
              edge: edgePair[1],
              cellX: cellX,
              cellY: cellY,
              cellWidth: _cellSize,
              cellHeight: _cellSize,
              topLeft: topLeft,
              topRight: topRight,
              bottomRight: bottomRight,
              bottomLeft: bottomLeft,
              threshold: threshold,
            );

            glowPath
              ..moveTo(start.dx, start.dy)
              ..lineTo(end.dx, end.dy);
            sharpPath
              ..moveTo(start.dx, start.dy)
              ..lineTo(end.dx, end.dy);
            segmentCount++;

            if (isMajor &&
                _shouldPlaceLabel(
                  column: column,
                  row: row,
                  contourIndex: contourIndex,
                )) {
              labelCandidates.add(
                _ContourLabelCandidate(
                  position: Offset(
                    (start.dx + end.dx) * 0.5,
                    (start.dy + end.dy) * 0.5,
                  ),
                  angle: math.atan2(
                    end.dy - start.dy,
                    end.dx - start.dx,
                  ),
                  elevation: (threshold * 1000).round(),
                  color: lineColor,
                  alpha: sharpAlpha * 0.6,
                ),
              );
            }
          }
        }
      }

      if (segmentCount == 0) {
        continue;
      }

      canvas.drawPath(
        glowPath,
        Paint()
          ..color = lineColor.withValues(alpha: glowAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = glowWidth
          ..strokeCap = StrokeCap.round,
      );

      canvas.drawPath(
        sharpPath,
        Paint()
          ..color = lineColor.withValues(alpha: sharpAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = sharpWidth
          ..strokeCap = StrokeCap.round,
      );
    }

    _paintLabels(
      canvas: canvas,
      size: size,
      candidates: labelCandidates,
    );
  }

  double _fbm({
    required double x,
    required double y,
    required double z,
  }) {
    double value = 0;
    double amplitude = 1;
    double frequency = 1;
    double totalAmplitude = 0;

    for (int octave = 0; octave < 4; octave++) {
      value += _noise.noise3d(
        x * frequency,
        y * frequency,
        z,
      ) *
          amplitude;
      totalAmplitude += amplitude;
      amplitude *= 0.5;
      frequency *= 2;
    }

    return value / totalAmplitude;
  }

  Color _lineColor({
    required double threshold,
  }) {
    const Color amber = Color(0xFFC8956C);
    const Color gold = Color(0xFFD4A574);
    const Color coral = Color(0xFFE07850);

    if (threshold < 0.5) {
      return Color.lerp(coral, amber, threshold * 2)!;
    }

    return Color.lerp(amber, gold, (threshold - 0.5) * 2)!;
  }

  bool _shouldPlaceLabel({
    required int column,
    required int row,
    required int contourIndex,
  }) {
    final int hash =
        ((column * 73856093) ^ (row * 19349663) ^ (contourIndex * 83492791)) &
            1023;
    return hash < (_labelDensity * 1024);
  }

  Offset _edgePoint({
    required int edge,
    required double cellX,
    required double cellY,
    required double cellWidth,
    required double cellHeight,
    required double topLeft,
    required double topRight,
    required double bottomRight,
    required double bottomLeft,
    required double threshold,
  }) {
    if (edge == 0) {
      final double t = _interpolate(
        start: topLeft,
        end: topRight,
        threshold: threshold,
      );
      return Offset(cellX + t * cellWidth, cellY);
    }

    if (edge == 1) {
      final double t = _interpolate(
        start: topRight,
        end: bottomRight,
        threshold: threshold,
      );
      return Offset(cellX + cellWidth, cellY + t * cellHeight);
    }

    if (edge == 2) {
      final double t = _interpolate(
        start: bottomLeft,
        end: bottomRight,
        threshold: threshold,
      );
      return Offset(cellX + t * cellWidth, cellY + cellHeight);
    }

    if (edge == 3) {
      final double t = _interpolate(
        start: topLeft,
        end: bottomLeft,
        threshold: threshold,
      );
      return Offset(cellX, cellY + t * cellHeight);
    }

    throw StateError('Unsupported edge index: $edge');
  }

  double _interpolate({
    required double start,
    required double end,
    required double threshold,
  }) {
    if ((end - start).abs() < 0.0001) {
      return 0.5;
    }
    return (threshold - start) / (end - start);
  }

  void _paintLabels({
    required Canvas canvas,
    required Size size,
    required List<_ContourLabelCandidate> candidates,
  }) {
    final List<_ContourLabelCandidate> filtered = <_ContourLabelCandidate>[];

    for (final _ContourLabelCandidate candidate in candidates) {
      if (candidate.position.dx < 80 ||
          candidate.position.dx > size.width - 80 ||
          candidate.position.dy < 40 ||
          candidate.position.dy > size.height - 40) {
        continue;
      }

      bool isTooClose = false;
      for (final _ContourLabelCandidate accepted in filtered) {
        final Offset delta = candidate.position - accepted.position;
        if (delta.distanceSquared <
            _majorLabelDistance * _majorLabelDistance) {
          isTooClose = true;
          break;
        }
      }

      if (!isTooClose) {
        filtered.add(candidate);
      }
    }

    for (final _ContourLabelCandidate label in filtered) {
      final TextSpan span = TextSpan(
        text: label.elevation.toString(),
        style: TextStyle(
          color: label.color.withValues(alpha: label.alpha),
          fontSize: 9,
          fontFamily: 'monospace',
          letterSpacing: 0.4,
        ),
      );
      final TextPainter painter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      )..layout();

      double angle = label.angle;
      if (angle > math.pi / 2) {
        angle -= math.pi;
      }
      if (angle < -math.pi / 2) {
        angle += math.pi;
      }

      canvas.save();
      canvas.translate(label.position.dx, label.position.dy);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: painter.width + 6,
            height: painter.height + 4,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xD90A0A0A),
      );
      painter.paint(
        canvas,
        Offset(-painter.width * 0.5, -painter.height * 0.5),
      );
      canvas.restore();
    }
  }

  void _paintVignette({
    required Canvas canvas,
    required Rect rect,
  }) {
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.92,
          colors: <Color>[
            const Color(0x000A0A0A),
            const Color(0x660A0A0A),
          ],
          stops: const <double>[0.34, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant TopographicPainter oldDelegate) {
    return oldDelegate.elapsedSeconds != elapsedSeconds ||
        oldDelegate.pointerIsActive != pointerIsActive ||
        oldDelegate.pointerIsPressed != pointerIsPressed ||
        oldDelegate.pointerPosition != pointerPosition ||
        oldDelegate.program != program ||
        oldDelegate.shaderEnabled != shaderEnabled;
  }
}

class _ContourLabelCandidate {
  const _ContourLabelCandidate({
    required this.position,
    required this.angle,
    required this.elevation,
    required this.color,
    required this.alpha,
  });

  final Offset position;
  final double angle;
  final int elevation;
  final Color color;
  final double alpha;
}

class _SimplexNoise3d {
  _SimplexNoise3d({
    required int seed,
  })  : _perm = Uint8List(512),
        _permMod12 = Uint8List(512) {
    const List<List<int>> gradients = <List<int>>[
      <int>[1, 1, 0],
      <int>[-1, 1, 0],
      <int>[1, -1, 0],
      <int>[-1, -1, 0],
      <int>[1, 0, 1],
      <int>[-1, 0, 1],
      <int>[1, 0, -1],
      <int>[-1, 0, -1],
      <int>[0, 1, 1],
      <int>[0, -1, 1],
      <int>[0, 1, -1],
      <int>[0, -1, -1],
    ];

    _grad3 = gradients;
    final Uint8List source = Uint8List(256);
    for (int index = 0; index < 256; index++) {
      source[index] = index;
    }

    int state = seed;
    for (int index = 255; index > 0; index--) {
      state = (state * 16807) % 2147483647;
      final int swapIndex = state % (index + 1);
      final int temp = source[index];
      source[index] = source[swapIndex];
      source[swapIndex] = temp;
    }

    for (int index = 0; index < 512; index++) {
      _perm[index] = source[index & 255];
      _permMod12[index] = _perm[index] % 12;
    }
  }

  static const double _f3 = 1 / 3;
  static const double _g3 = 1 / 6;

  final Uint8List _perm;
  final Uint8List _permMod12;
  late final List<List<int>> _grad3;

  double noise3d(double xin, double yin, double zin) {
    final double skew = (xin + yin + zin) * _f3;
    final int i = (xin + skew).floor();
    final int j = (yin + skew).floor();
    final int k = (zin + skew).floor();
    final double unskew = (i + j + k) * _g3;
    final double x0 = xin - (i - unskew);
    final double y0 = yin - (j - unskew);
    final double z0 = zin - (k - unskew);

    late int i1;
    late int j1;
    late int k1;
    late int i2;
    late int j2;
    late int k2;

    if (x0 >= y0) {
      if (y0 >= z0) {
        i1 = 1;
        j1 = 0;
        k1 = 0;
        i2 = 1;
        j2 = 1;
        k2 = 0;
      } else if (x0 >= z0) {
        i1 = 1;
        j1 = 0;
        k1 = 0;
        i2 = 1;
        j2 = 0;
        k2 = 1;
      } else {
        i1 = 0;
        j1 = 0;
        k1 = 1;
        i2 = 1;
        j2 = 0;
        k2 = 1;
      }
    } else {
      if (y0 < z0) {
        i1 = 0;
        j1 = 0;
        k1 = 1;
        i2 = 0;
        j2 = 1;
        k2 = 1;
      } else if (x0 < z0) {
        i1 = 0;
        j1 = 1;
        k1 = 0;
        i2 = 0;
        j2 = 1;
        k2 = 1;
      } else {
        i1 = 0;
        j1 = 1;
        k1 = 0;
        i2 = 1;
        j2 = 1;
        k2 = 0;
      }
    }

    final double x1 = x0 - i1 + _g3;
    final double y1 = y0 - j1 + _g3;
    final double z1 = z0 - k1 + _g3;
    final double x2 = x0 - i2 + 2 * _g3;
    final double y2 = y0 - j2 + 2 * _g3;
    final double z2 = z0 - k2 + 2 * _g3;
    final double x3 = x0 - 1 + 3 * _g3;
    final double y3 = y0 - 1 + 3 * _g3;
    final double z3 = z0 - 1 + 3 * _g3;

    final int ii = i & 255;
    final int jj = j & 255;
    final int kk = k & 255;

    final double n0 = _cornerContribution(
      x: x0,
      y: y0,
      z: z0,
      gradientIndex: _permMod12[ii + _perm[jj + _perm[kk]]],
    );
    final double n1 = _cornerContribution(
      x: x1,
      y: y1,
      z: z1,
      gradientIndex: _permMod12[ii + i1 + _perm[jj + j1 + _perm[kk + k1]]],
    );
    final double n2 = _cornerContribution(
      x: x2,
      y: y2,
      z: z2,
      gradientIndex: _permMod12[ii + i2 + _perm[jj + j2 + _perm[kk + k2]]],
    );
    final double n3 = _cornerContribution(
      x: x3,
      y: y3,
      z: z3,
      gradientIndex: _permMod12[ii + 1 + _perm[jj + 1 + _perm[kk + 1]]],
    );

    return 32 * (n0 + n1 + n2 + n3);
  }

  double _cornerContribution({
    required double x,
    required double y,
    required double z,
    required int gradientIndex,
  }) {
    double t = 0.6 - x * x - y * y - z * z;
    if (t < 0) {
      return 0;
    }

    t *= t;
    final List<int> gradient = _grad3[gradientIndex];
    return t *
        t *
        (gradient[0] * x + gradient[1] * y + gradient[2] * z);
  }
}
