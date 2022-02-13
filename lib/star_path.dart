import 'package:flutter/rendering.dart';

Path getStarPath(Size size) {
  final starPath = Path();
  starPath.lineTo(size.width / 2, 0);
  starPath.cubicTo(size.width / 2, 0, size.width * 0.53, size.height * 0.28, size.width * 0.62, size.height * 0.38);
  starPath.cubicTo(size.width * 0.72, size.height * 0.47, size.width, size.height / 2, size.width, size.height / 2);
  starPath.cubicTo(size.width, size.height / 2, size.width * 0.72, size.height * 0.53, size.width * 0.62, size.height * 0.62);
  starPath.cubicTo(size.width * 0.53, size.height * 0.72, size.width / 2, size.height, size.width / 2, size.height);
  starPath.cubicTo(size.width / 2, size.height, size.width * 0.47, size.height * 0.72, size.width * 0.38, size.height * 0.62);
  starPath.cubicTo(size.width * 0.28, size.height * 0.53, 0, size.height / 2, 0, size.height / 2);
  starPath.cubicTo(0, size.height / 2, size.width * 0.28, size.height * 0.47, size.width * 0.38, size.height * 0.38);
  starPath.cubicTo(size.width * 0.47, size.height * 0.28, size.width / 2, 0, size.width / 2, 0);
  starPath.cubicTo(size.width / 2, 0, size.width / 2, 0, size.width / 2, 0);
  return starPath;
}
