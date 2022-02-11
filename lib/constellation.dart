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
  });

  final Position pos;
}

class AnimationStar extends Star {
  AnimationStar({required pos}) : super(pos: pos);

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
    required this.stars,
    required this.lines,
  });

  final List<Star> stars;
  final List<Line> lines;
}

class ConstellationAnimation {
  ConstellationAnimation({required this.stars, required this.lines});

  final List<AnimationStar> stars;
  final List<AnimationLine> lines;

  static ConstellationAnimation from(Constellation constellation) {
    return ConstellationAnimation(
      stars: constellation.stars.map((e) => AnimationStar(pos: e.pos)).toList(),
      lines: constellation.lines.map((e) => AnimationLine(e.start, e.end)).toList(),
    );
  }

  bool tick() {
    for (var star in stars) {
      if (star.shouldFill) {
        star.fill = min(star.fill + 1 / 60, 1);
      }
    }

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      var firstStar = stars[line.start];
      var secondStar = stars[line.end];
      if (firstStar.fill == 1 && !line.shouldFill) {
        line.shouldFill = true;
      }
      if(secondStar.fill == 1){
        var oppositeLine = lines.firstWhere((element) => element.start == line.end && element.end == line.start, orElse: () {
          var l = AnimationLine(line.end, line.start);
          lines.add(l);
          return l;
        });
        oppositeLine.shouldFill = true;
      }
      if (line.shouldFill) {
        line.fill = min(line.fill + 1 / 60, 1);
        if(line.fill == 1){
          var secondStar = stars[line.end];
          if(!secondStar.shouldFill){
            secondStar.shouldFill = true;
            secondStar.fill = 0.35;
          }
        }
      }
    }

    return stars.every((element) => element.fill == 1) && lines.every((element) => element.fill == 1);
  }
}
