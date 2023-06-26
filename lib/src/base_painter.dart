import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'utils.dart';

class BasePainter extends CustomPainter {
  final Color baseColor;
  final Color selectionColor;
  final int primarySectors;
  final int secondarySectors;
  final double sliderStrokeWidth;
  final double sliderPadding;
  final TextStyle? timeTextStyle;
  final bool showDots;

  BasePainter({
    required this.baseColor,
    required this.selectionColor,
    required this.primarySectors,
    required this.secondarySectors,
    required this.sliderStrokeWidth,
    this.timeTextStyle,
    this.sliderPadding = 0,
    this.showDots = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint base = _getPaint(
      color: baseColor,
      width: sliderStrokeWidth + sliderPadding,
    );

    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        math.min(size.width / 2, size.height / 2) - sliderStrokeWidth;
    // we need this in the parent to calculate if the user clicks on the circumference

    assert(radius > 0);

    canvas.drawCircle(center, radius, base);

    final outterShadowPainter = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = sliderStrokeWidth / 2
      ..shader = RadialGradient(
        radius: 0.425,
        focal: Alignment.center,
        focalRadius: 0.35,
        colors: [
          Color.fromRGBO(0, 0, 0, 0.03),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: radius + sliderStrokeWidth / 2,
        ),
      );

    final innerShadowPainter = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = sliderStrokeWidth / 2
      ..shader = RadialGradient(
        radius: 0.525,
        focal: Alignment.center,
        focalRadius: 0.45,
        colors: [
          Colors.transparent,
          Color.fromRGBO(0, 0, 0, 0.03),
        ],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: radius + sliderStrokeWidth / 2,
        ),
      );

    canvas.drawCircle(
      center,
      radius - sliderStrokeWidth / 4,
      outterShadowPainter,
    );
    canvas.drawCircle(
      center,
      radius + sliderStrokeWidth / 4,
      innerShadowPainter,
    );

    _paintTime(
      canvas: canvas,
      radius: radius,
      center: center,
    );

    if (primarySectors > 0) {
      _paintSectors(
        sectors: primarySectors,
        radiusPadding: 8.0,
        color: selectionColor,
        canvas: canvas,
        center: center,
        radius: radius,
      );
    }

    if (secondarySectors > 0) {
      _paintSectors(
        sectors: secondarySectors,
        radiusPadding: 6.0,
        color: baseColor,
        canvas: canvas,
        center: center,
        radius: radius,
      );
    }
  }

  void _paintTime({
    required Canvas canvas,
    required Offset center,
    required double radius,
  }) {
    // const int hourNum = 4;
    final int hourNum = showDots ? 24 : 4;
    const double largeTextSize = 13;

    final offsets = getSectionsCoordinatesInCircle(
      center,
      radius - sliderStrokeWidth,
      hourNum,
    );

    for (int i = 0; i < hourNum; i++) {
      final currentTextSize = largeTextSize;

      final textSpan = TextSpan(
        text: showDots
            ? i % 6 == 0
                ? '$i'
                : '∙'
            : '${i * 6}',
        style: timeTextStyle,
      );

      final textPainter = TextPainter()
        ..text = textSpan
        ..textDirection = TextDirection.ltr
        ..textAlign = TextAlign.center
        ..layout();

      final size = textPainter.size;

      textPainter.paint(
        canvas,
        Offset(
          (2 * center.dx - offsets.elementAt(i).dx) - size.width / 2,
          (2 * center.dy - offsets.elementAt(i).dy) -
              (currentTextSize * (timeTextStyle?.height ?? 1.3)) / 2,
        ),
      );
    }
  }

  void _paintSectors({
    required int sectors,
    required double radiusPadding,
    required Color color,
    required Canvas canvas,
    required Offset center,
    required double radius,
  }) {
    Paint section = _getPaint(color: color, width: 2.0);

    var endSectors = getSectionsCoordinatesInCircle(
      center,
      radius + radiusPadding,
      sectors,
    );
    var initSectors = getSectionsCoordinatesInCircle(
      center,
      radius - radiusPadding,
      sectors,
    );

    _paintLines(canvas, initSectors, endSectors, section);
  }

  void _paintLines(
    Canvas canvas,
    List<Offset> inits,
    List<Offset> ends,
    Paint section,
  ) {
    assert(inits.length == ends.length && inits.isNotEmpty);

    for (var i = 0; i < inits.length; i++) {
      canvas.drawLine(inits[i], ends[i], section);
    }
  }

  Paint _getPaint({
    required Color color,
    double? width,
    PaintingStyle? style,
  }) =>
      Paint()
        ..color = color
        ..strokeCap = StrokeCap.round
        ..style = style ?? PaintingStyle.stroke
        ..strokeWidth = width ?? sliderStrokeWidth;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
