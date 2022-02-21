import 'dart:math';

import 'package:flutter/painting.dart';

class Position {
  Position(
    this.x,
    this.y,
  );

  final double x;
  final double y;

  Offset toOffset(Size size) {
    return Offset(x * size.width, y * size.height);
  }
}

class Star {
  Star({
    required this.pos,
    this.name,
    this.magnitude,
    this.distance,
  });

  final Position pos;
  final String? name;
  final double? magnitude;
  final double? distance;
}

class AnimationStar extends Star {
  AnimationStar({required pos, String? name, double? magnitude, double? distance})
      : super(
          pos: pos,
          name: name,
          magnitude: magnitude,
          distance: distance,
        );

  double fill = 0;
  bool shouldFill = false;
}

class Line {
  Line(
    this.start,
    this.end,
  );

  final int start;
  final int end;
}

class AnimationLine extends Line {
  AnimationLine(int start, int end) : super(start, end);

  double fill = 0;
  bool shouldFill = false;
}

class Constellation {
  Constellation({
    required this.name,
    required this.skyFileName,
    required this.skyBoxOffset,
    Size? skyBoxSize,
    this.backgroundColor,
    required this.stars,
    required this.lines,
    this.starSize,
    this.boundaries,
  }) : _skyBoxSize = skyBoxSize;

  final String name;
  final String skyFileName;
  final Offset skyBoxOffset;
  final Size? _skyBoxSize;
  final Color? backgroundColor;
  final List<Star> stars;
  final List<Line> lines;
  final double? starSize;
  final List<Position>? boundaries;

  Size get skyBoxSize => _skyBoxSize ?? const Size.square(750);
}

class ConstellationAnimation {
  ConstellationAnimation({required this.stars, required this.lines});

  final List<AnimationStar> stars;
  final List<AnimationLine> lines;

  static ConstellationAnimation from(Constellation constellation) {
    return ConstellationAnimation(
      stars: constellation.stars
          .map((e) => AnimationStar(
                pos: e.pos,
                name: e.name,
                magnitude: e.magnitude,
                distance: e.distance,
              ))
          .toList(),
      lines: constellation.lines.map((e) => AnimationLine(e.start, e.end)).toList(),
    );
  }

  double lineLength(Line line) {
    var firstStar = stars[line.start];
    var secondStar = stars[line.end];
    return sqrt(pow(firstStar.pos.x - secondStar.pos.x, 2) + pow(firstStar.pos.y - secondStar.pos.y, 2));
  }

  bool tick(int delta) {
    final animationSpeed = delta / 400;
    for (var star in stars) {
      if (star.shouldFill) {
        star.fill = min(star.fill + animationSpeed, 1);
      }
    }

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      var firstStar = stars[line.start];
      var secondStar = stars[line.end];
      if (firstStar.fill == 1 && !line.shouldFill) {
        line.shouldFill = true;
      }
      if (secondStar.fill == 1) {
        var oppositeLine =
            lines.firstWhere((element) => element.start == line.end && element.end == line.start, orElse: () {
          var l = AnimationLine(line.end, line.start);
          lines.add(l);
          return l;
        });
        oppositeLine.shouldFill = true;
      }
      if (line.shouldFill) {
        line.fill = min(line.fill + animationSpeed * (1 - lineLength(line)), 1);
        if (line.fill == 1) {
          var secondStar = stars[line.end];
          if (!secondStar.shouldFill) {
            secondStar.shouldFill = true;
            secondStar.fill = 0.35;
          }
        }
      }
    }

    return stars.every((element) => element.fill == 1) && lines.every((element) => element.fill == 1);
  }

  void skipForward() {
    for (var star in stars) {
      star.shouldFill = true;
      star.fill = 1;
    }

    for (var line in lines) {
      line.shouldFill = true;
      line.fill = 1;
    }
  }
}
