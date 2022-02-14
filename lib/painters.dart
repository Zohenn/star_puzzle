import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:star_puzzle/constellation.dart';
import 'package:star_puzzle/star_path.dart';

class ConstellationBackgroundPainter extends CustomPainter {
  ConstellationBackgroundPainter(this.image, this.containerKey);

  final ui.Image? image;
  final GlobalKey containerKey;

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      final context = containerKey.currentContext!;
      final mq = MediaQuery.of(Get.context!);
      final screenSize = (mq.size) * mq.devicePixelRatio;
      final box = context.findRenderObject() as RenderBox;
      final pos = box.localToGlobal(Offset.zero);
      final scale = screenSize.height / image!.height;
      final srcSize = box.size * mq.devicePixelRatio * 1 / scale;
      final imageOffset = Offset(image!.width / 2 - srcSize.width / 2, pos.dy * mq.devicePixelRatio * 1 / scale);
      canvas.save();
      canvas.drawImageRect(image!, imageOffset & srcSize, Offset.zero & size, Paint());
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class ConstellationAnimationPainter extends CustomPainter {
  ConstellationAnimationPainter(this.constellation, this.preScale);

  final ConstellationAnimation constellation;
  final double preScale;

  static const baseStarPathSize = Size(12, 12);

  Size get starPathSize => baseStarPathSize * preScale;

  static Offset sizeToOffset(Size size) => Offset(size.width, size.height);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Color(0x30ffffff)
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
    final starPaint = Paint()..color = Color(0xffffffff);
    for (var star in constellation.stars) {
      final starPath = getStarPath(starPathSize).shift(star.pos.toOffset(size) - sizeToOffset(starPathSize) / 2);
      if (star.fill != 0 && star.fill != 1) {
        canvas.save();
        canvas.translate(star.pos.toOffset(size).dx, star.pos.toOffset(size).dy);
        canvas.rotate(star.fill * pi);
        canvas.scale(sin(star.fill * pi) * 0.5 + 1);
        canvas.translate(-star.pos.toOffset(size).dx, -star.pos.toOffset(size).dy);
      }
      canvas.drawShadow(starPath, Color(0xffffffff), star.fill * 2, true);
      canvas.drawPath(starPath, starPaint);
      if (star.fill != 0 && star.fill != 1) {
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class PiecePainter extends CustomPainter {
  PiecePainter(
    this.image,
    this.i,
    this.j,
    this.tileSize,
  );

  ui.Image? image;
  int i;
  int j;
  Size tileSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      final scale = (image!.width / 3) / tileSize.width;
      canvas.drawImageRect(
          image!,
          (Offset(j.toDouble(), i.toDouble()) * tileSize.width * scale +
                  Offset((tileSize.width - size.width) * scale / 2, (tileSize.height - size.height) * scale / 2)) &
              (size * scale),
          Offset.zero & size,
          Paint()..filterQuality = FilterQuality.high);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
