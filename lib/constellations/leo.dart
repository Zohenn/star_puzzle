import 'dart:ui';

import 'package:star_puzzle/models/constellation.dart';

final leo = Constellation(
  name: 'Leo',
  skyFileName: 'leo_sky.jpg',
  skyBoxOffset: const Offset(1505, 703),
  skyBoxSize: const Size.square(550),
  backgroundColor: const Color(0xff010221),
  stars: [
    Star(pos: Position(0.09323719143867493, 0.8338998158772787), name: 'Denebola', magnitude: 2.10, distance: 35.88),
    Star(pos: Position(0.35868561267852783, 0.7173051834106445), name: 'Chertan', magnitude: 3.30, distance: 165.06),
    Star(pos: Position(0.30417118469874066, 0.5528748432795206), name: 'Zosma', magnitude: 2.55, distance: 58.43),
    Star(pos: Position(0.909420887629191, 0.6356855233510336), name: 'Regulus', magnitude: 1.35, distance: 79.30),
    Star(pos: Position(0.8535563945770264, 0.47968006134033203), name: 'Al Jabhah', magnitude: 3.45, distance: 1269.09),
    Star(pos: Position(0.7184153397878011, 0.4228614966074626), name: 'Algieba', magnitude: 2.20, distance: 125.64),
    Star(pos: Position(0.6952492396036783, 0.3005525271097819), name: 'Adhafera', magnitude: 3.40, distance: 274.08),
    Star(pos: Position(0.8311196168263754, 0.14241970578829447), name: 'Rasalas', magnitude: 3.85, distance: 124.11),
    Star(pos: Position(0.9128709634145101, 0.1887227694193522), name: 'Algenubi', magnitude: 2.95, distance: 246.71),
  ],
  lines: [
    Line(0, 1),
    Line(0, 2),
    Line(1, 2),
    Line(1, 3),
    Line(3, 4),
    Line(4, 5),
    Line(5, 6),
    Line(6, 7),
    Line(7, 8),
    Line(2, 5),
  ],
  boundaries: [
    Position(0.5114754098360655, 0.475),
    Position(0.5221311475409836, 0.45046296296296295),
    Position(0.526775956284153, 0.45601851851851855),
    Position(0.5300546448087432, 0.44814814814814813),
    Position(0.5327868852459017, 0.4513888888888889),
    Position(0.5360655737704918, 0.44305555555555554),
    Position(0.5286885245901639, 0.4356481481481482),
    Position(0.5352459016393443, 0.4148148148148148),
    Position(0.5275956284153005, 0.4083333333333333),
    Position(0.5322404371584699, 0.38657407407407407),
    Position(0.5778688524590164, 0.42083333333333334),
    Position(0.573224043715847, 0.43472222222222223),
    Position(0.555464480874317, 0.47824074074074074),
    Position(0.573224043715847, 0.5032407407407408),
    Position(0.5595628415300546, 0.5287037037037037),
    Position(0.5382513661202186, 0.49675925925925923),
    Position(0.5325136612021858, 0.5074074074074074),
  ],
);

















