import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:star_puzzle/star_path.dart';

class StarLoader extends StatefulWidget {
  const StarLoader({
    Key? key,
    this.starSize = 18,
    this.noStars = 3,
    this.spacerSize = 0,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  final double starSize;
  final int noStars;
  final double spacerSize;
  final Duration duration;

  @override
  _StarLoaderState createState() => _StarLoaderState();
}

class _StarLoaderState extends State<StarLoader> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(vsync: this, duration: widget.duration);

    animation = Tween(begin: 0.0, end: 1.0).animate(animationController);

    animationController.repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarLoaderPainter(
          starSize: widget.starSize, noStars: widget.noStars, spacerSize: widget.spacerSize, animation: animation),
      size: Size.square(widget.starSize * widget.noStars + widget.spacerSize * (widget.noStars - 1)),
    );
  }
}

class _StarLoaderPainter extends CustomPainter {
  _StarLoaderPainter({
    required this.starSize,
    required this.noStars,
    required this.spacerSize,
    required this.animation,
  }) : super(repaint: animation);

  final double starSize;
  final int noStars;
  final double spacerSize;

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()..color = Color(0xffffffff);
    final stepWidth = 1 / (noStars * 2);
    final step = animation.value / stepWidth;

    Offset getShift(int i) {
      return Offset(i * starSize + i * spacerSize, ((i + 1) % 2) * (2 * starSize + 2 * spacerSize));
    }

    for (var i = 0; i < noStars; i++) {
      // final starPath = getStarPath(Size.square(starSize)).shift(Offset(i * starSize + i * spacerSize, 0));
      final shift = getShift(i);
      final nextStarShift = getShift((i + 1) % noStars);
      final starPath = getStarPath(Size.square(starSize)).shift(shift);
      final rotation = (step.toInt() % noStars) == i ? lerpDouble(0, 180, step - step.toInt())! : 180;
      final scale = (step.toInt() % noStars) == i ? sin((step - step.toInt()) * pi) * 0.5 + 1 : 1.0;
      // final translate = Offset(i * starSize + i * spacerSize + starSize / 2, starSize / 2);
      final sizeOffset = Offset(starSize / 2, starSize / 2);
      final translate = shift + sizeOffset;
      double lineFill;
      double lineStep = step < noStars ? step : step - noStars;
      bool reverse = step >= noStars;
      if (lineStep.toInt() < i) {
        lineFill = 0;
      } else if (lineStep.toInt() > i) {
        lineFill = 1;
      } else {
        lineFill = lineStep - lineStep.toInt();
      }
      final linePaint = Paint()
        ..color = Color(0x20ffffff)
        ..strokeWidth = starSize / 5;
      if (reverse) {
        canvas.drawLine(nextStarShift + sizeOffset, nextStarShift + sizeOffset + (shift + sizeOffset - (nextStarShift + sizeOffset)) * (1 - lineFill), linePaint);
      } else {
        canvas.drawLine(
          shift + sizeOffset,
          shift + sizeOffset + (nextStarShift + sizeOffset - (shift + sizeOffset)) * lineFill,
          linePaint,
        );
      }
      canvas.save();
      canvas.translate(translate.dx, translate.dy);
      canvas.rotate(rotation * pi / 180);
      canvas.scale(scale);
      canvas.translate(-translate.dx, -translate.dy);
      canvas.drawPath(starPath, starPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
