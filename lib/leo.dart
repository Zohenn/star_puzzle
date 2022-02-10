import 'package:star_puzzle/constellation.dart';

final leo = Constellation(
  stars: [
    Star(pos: Position(0.078249990940094, 0.614187479019165)),
    Star(pos: Position(0.3201666673024495, 0.5946875015894572)),
    Star(pos: Position(0.31877084573109943, 0.4531041781107585)),
    Star(pos: Position(0.7631458441416422, 0.6821458339691162)),
    Star(pos: Position(0.7780208587646484, 0.5588124990463257)),
    Star(pos: Position(0.687541643778483, 0.470520814259847)),
    Star(pos: Position(0.7138333320617676, 0.376687486966451)),
    Star(pos: Position(0.8784791628519694, 0.3069791595141093)),
    Star(pos: Position(0.9232291380564371, 0.36556251843770343)),
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
);
