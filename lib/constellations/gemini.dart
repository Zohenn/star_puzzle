import 'dart:ui';

import 'package:star_puzzle/models/constellation.dart';

final gemini = Constellation(
  name: 'Gemini',
  skyFileName: 'gemini_sky.jpg',
  skyBoxOffset: const Offset(1545, 712),
  skyBoxSize: const Size.square(550),
  backgroundColor: const Color(0xff001500),
  stars: [
    Star(pos: Position(0.3571465015411377, 0.14882448315620422), name: 'Pollux', magnitude: 1.15, distance: 33.78),
    Star(pos: Position(0.3806761105855306, 0.23619856437047324), name: 'υ Gem', magnitude: 4.05, distance: 264.09),
    Star(pos: Position(0.2613798181215922, 0.24968685706456503), name: 'κ Gem', magnitude: 3.55, distance: 141.38),
    Star(pos: Position(0.3459063371022542, 0.46549936135609943), name: 'Wasat', magnitude: 3.50, distance: 60.47),
    Star(pos: Position(0.21581941843032837, 0.628257950146993), name: 'λ Gem', magnitude: 3.55, distance: 100.88),
    Star(pos: Position(0.34680553277333576, 0.932493527730306), name: 'Alzirr', magnitude: 3.35, distance: 58.70),
    Star(pos: Position(0.4121487538019816, 0.6015810569127401), name: 'Mekbuda', magnitude: 4.00, distance: 1376.19),
    Star(pos: Position(0.48588470617930096, 0.8773415088653564), name: 'Alhena', magnitude: 1.90, distance: 109.30),
    Star(pos: Position(0.4658021132151286, 0.2739657362302144), name: 'ι Gem', magnitude: 3.75, distance: 120.35),
    Star(pos: Position(0.6186692714691162, 0.29165037473042804), name: 'τ Gem', magnitude: 4.40, distance: 321.02),
    Star(pos: Position(0.526649276415507, 0.11150689919789632), name: 'Castor', magnitude: 1.90, distance: 51.55),
    Star(pos: Position(0.8242906729380289, 0.28715429703394574), name: 'θ Gem', magnitude: 3.60, distance: 189.08),
    Star(pos: Position(0.6587408781051636, 0.5890069405237833), name: 'Mebsuta', magnitude: 3.05, distance: 844.96),
    Star(pos: Position(0.6392416954040527, 0.8158971468607584), name: 'Nucatai', magnitude: 4.10, distance: 544.50),
    Star(pos: Position(0.7352541287740072, 0.7811377048492432), name: 'Tejat', magnitude: 2.85, distance: 231.65),
    Star(pos: Position(0.791173537572225, 0.8255937894185384), name: 'Propus', magnitude: 3.30, distance: 349.20),
    Star(pos: Position(0.8837014039357504, 0.8600985209147135), name: '1 Gem', magnitude: 4.75, distance: 150.72),
  ],
  lines: [
    Line(0, 1),
    Line(1, 2),
    Line(1, 3),
    Line(3, 4),
    Line(4, 5),
    Line(3, 6),
    Line(6, 7),
    Line(1, 8),
    Line(8, 9),
    Line(9, 10),
    Line(9, 11),
    Line(9, 12),
    Line(12, 13),
    Line(12, 14),
    Line(14, 15),
    Line(15, 16),
  ],
  boundaries: [
    Position(0.5393442622950819, 0.3365740740740741),
    Position(0.5396174863387978, 0.325),
    Position(0.5355191256830601, 0.324537037037037),
    Position(0.5357923497267759, 0.3074074074074074),
    Position(0.5327868852459017, 0.26666666666666666),
    Position(0.5521857923497268, 0.26157407407407407),
    Position(0.5478142076502732, 0.22083333333333333),
    Position(0.5633879781420765, 0.21481481481481482),
    Position(0.5677595628415301, 0.21388888888888888),
    Position(0.5691256830601092, 0.2375),
    Position(0.5811475409836065, 0.23703703703703705),
    Position(0.5811475409836065, 0.24351851851851852),
    Position(0.5978142076502733, 0.2449074074074074),
    Position(0.5948087431693989, 0.2898148148148148),
    Position(0.5997267759562842, 0.2916666666666667),
    Position(0.5991803278688524, 0.29583333333333334),
    Position(0.5926229508196721, 0.29398148148148145),
    Position(0.5885245901639344, 0.325),
    Position(0.5863387978142076, 0.32407407407407407),
    Position(0.5833333333333334, 0.34120370370370373),
    Position(0.5688524590163935, 0.3351851851851852),
    Position(0.5683060109289617, 0.33935185185185185),
    Position(0.5510928961748633, 0.3333333333333333),
    Position(0.5505464480874317, 0.3384259259259259),
  ],
);