import 'dart:math';

import 'package:flutter/material.dart';
import 'package:star_puzzle/models/constellation.dart';
import 'package:star_puzzle/utils/star_path.dart';
import 'package:touchable/touchable.dart';

class ConstellationAnimationPainter extends CustomPainter {
  ConstellationAnimationPainter(
    this.context,
    this.constellation,
    this.preScale, {
    this.useCircles = false,
    this.starSize,
    this.onStarTap,
    this.selectedStar,
    this.selectedStarAnimationController,
  }) : super(repaint: selectedStarAnimationController);

  final BuildContext context;
  final ConstellationAnimation constellation;
  final double preScale;
  final bool useCircles;
  final double? starSize;
  final void Function(Star star)? onStarTap;
  final Star? selectedStar;
  final AnimationController? selectedStarAnimationController;

  static const _baseStarPathSize = Size(12, 12);

  Size get starPathSize => (starSize != null ? Size.square(starSize!) : _baseStarPathSize) * preScale;

  static Offset sizeToOffset(Size size) => Offset(size.width, size.height);

  @override
  void paint(Canvas _canvas, Size size) {
    final canvas = TouchyCanvas(context, _canvas);

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = (starPathSize / 5).width;
    for (var line in constellation.lines) {
      var firstStar = constellation.stars[line.start];
      if (line.shouldFill) {
        var secondStar = constellation.stars[line.end];
        var firstStarOffset = firstStar.pos.toOffset(size);
        var secondStarOffset = secondStar.pos.toOffset(size);
        canvas.drawLine(
          firstStarOffset,
          firstStarOffset + (secondStarOffset - firstStarOffset) * line.fill,
          linePaint,
        );
      }
    }

    // final starPaint = Paint()..color = Color(0xffFFF7D5);
    final starPaint = Paint()..color = Colors.white;
    for (var star in constellation.stars) {
      final isSelected = star == selectedStar;
      if (useCircles) {
        canvas.drawCircle(star.pos.toOffset(size), starPathSize.width * preScale, starPaint);
      } else {
        final _starPathSize = starPathSize * (isSelected ? 1.25 : 1);
        final starPath = getStarPath(_starPathSize).shift(star.pos.toOffset(size) - sizeToOffset(_starPathSize) / 2);
        final needsRotation = star.fill != 0 && star.fill != 1 || selectedStarAnimationController != null;
        if (needsRotation) {
          _canvas.save();
          _canvas.translate(star.pos.toOffset(size).dx, star.pos.toOffset(size).dy);
          _canvas.rotate((isSelected ? selectedStarAnimationController!.value : star.fill) * pi);
          if (selectedStarAnimationController == null) {
            _canvas.scale(sin(star.fill * pi) * 0.5 + 1);
          }
          _canvas.translate(-star.pos.toOffset(size).dx, -star.pos.toOffset(size).dy);
        }
        canvas.drawShadow(starPath, Colors.white, star.fill * 2, true);
        if (onStarTap != null) {
          final tapRegionPaint = Paint()..color = Colors.transparent;
          if (!isSelected) {
            // draw transparent square, so it's easier to hit the star
            canvas.drawRect(
              (star.pos.toOffset(size) - sizeToOffset(_starPathSize) / 2) & _starPathSize,
              tapRegionPaint,
              onTapDown: (details) {
                onStarTap!(star);
              },
            );
          } else {
            canvas.drawCircle(
              star.pos.toOffset(size),
              starPathSize.width,
              tapRegionPaint,
              onTapDown: (details) {
                onStarTap!(star);
              },
            );
          }
        }
        canvas.drawPath(
          starPath,
          starPaint,
          onTapDown: onStarTap != null
              ? (details) {
                  onStarTap!(star);
                }
              : null,
        );
        if (needsRotation) {
          _canvas.restore();
        }

        if (isSelected) {
          final selectedStarCirclePaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0
            ..color = Colors.white.withOpacity(0.4);
          canvas.drawCircle(star.pos.toOffset(size), starPathSize.width, selectedStarCirclePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
