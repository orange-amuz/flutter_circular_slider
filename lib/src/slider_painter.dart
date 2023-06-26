import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'circular_slider_paint.dart' show CircularSliderMode;
import 'utils.dart';

class SliderPainter extends CustomPainter {
  final CircularSliderMode mode;
  final double startAngle;
  final double endAngle;
  final double sweepAngle;
  final Color selectionColor;
  final Color handlerColor;
  final double handlerOutterRadius;
  final bool showRoundedCapInSelection;
  final bool showHandlerOutter;
  final double sliderStrokeWidth;
  final Gradient? gradient;

  late Offset initHandler;
  late Offset endHandler;
  late Offset center;
  late double radius;

  SliderPainter({
    required this.mode,
    required this.startAngle,
    required this.endAngle,
    required this.sweepAngle,
    required this.selectionColor,
    required this.handlerColor,
    required this.handlerOutterRadius,
    required this.showRoundedCapInSelection,
    required this.showHandlerOutter,
    required this.sliderStrokeWidth,
    this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    center = Offset(size.width / 2, size.height / 2);
    radius = math.min(size.width / 2, size.height / 2) - sliderStrokeWidth;

    Paint progress = _getPaint(color: selectionColor);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + startAngle,
      sweepAngle,
      false,
      progress,
    );

    Paint handler = _getPaint(color: handlerColor, style: PaintingStyle.fill);
    // Paint handlerOutter = _getPaint(color: handlerColor, width: 2.0);

    // draw handlers
    if (mode == CircularSliderMode.doubleHandler) {
      initHandler =
          radiansToCoordinates(center, -math.pi / 2 + startAngle, radius);
      // canvas.drawCircle(initHandler, 8.0, handler);

      canvas.drawCircle(initHandler, handlerOutterRadius, handler);
    }

    endHandler = radiansToCoordinates(center, -math.pi / 2 + endAngle, radius);
    // canvas.drawCircle(endHandler, 8.0, handler);
    canvas.drawCircle(endHandler, handlerOutterRadius, handler);

    // if (showHandlerOutter) {
    //   canvas.drawCircle(endHandler, handlerOutterRadius, handlerOutter);
    // }
  }

  Paint _getPaint({
    required Color color,
    double? width,
    PaintingStyle style = PaintingStyle.stroke,
  }) =>
      Paint()
        ..color = gradient == null ? color : Colors.black
        ..shader = gradient?.createShader(
          Rect.fromCircle(
            center: center,
            radius: radius,
          ),
        )
        ..strokeCap =
            showRoundedCapInSelection ? StrokeCap.round : StrokeCap.butt
        ..style = style
        ..strokeWidth = width ?? sliderStrokeWidth;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
