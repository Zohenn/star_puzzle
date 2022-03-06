import 'dart:ui';

import 'package:star_puzzle/models/constellation.dart';

final hercules = Constellation(
  name: 'Hercules',
  skyFileName: 'hercules_sky.jpg',
  skyBoxOffset: const Offset(1477, 815),
  skyBoxSize: const Size.square(550),
  backgroundColor: const Color(0xff100022),
  stars: [
    Star(pos: Position(0.033409190674622856, 0.8284982840220133), name: '111 Her', magnitude: 4.30, distance: 92.26),
    Star(pos: Position(0.05002392828464508, 0.7655890782674154), name: '110 Her', magnitude: 4.15, distance: 62.65),
    Star(pos: Position(0.1924582521120707, 0.7469368775685629), name: '109 Her', magnitude: 3.85, distance: 118.78),
    Star(pos: Position(0.28571883837382, 0.7783064047495524), name: '102 Her', magnitude: 4.35, distance: 916.17),
    Star(pos: Position(0.3315012852350871, 0.7596542835235596), name: '95 Her', magnitude: 4.85, distance: 470.64),
    Star(pos: Position(0.3047948678334554, 0.5659266312917074), name: 'o Her', magnitude: 3.80, distance: 337.99),
    Star(pos: Position(0.3624468644460042, 0.5557527939478556), name: 'ξ Her', magnitude: 3.70, distance: 136.81),
    Star(pos: Position(0.42688143253326416, 0.5985678434371948), name: 'μ Her', magnitude: 3.40, distance: 27.11),
    Star(pos: Position(0.5209898551305135, 0.6418068408966064), name: 'Maasym', magnitude: 4.40, distance: 383.71),
    Star(pos: Position(0.6155221462249756, 0.6723284721374512), name: 'Sarin', magnitude: 3.10, distance: 75.13),
    Star(pos: Position(0.6324785947799683, 0.9512623945871989), name: 'Rasalgethi', magnitude: 3.35, distance: 382.36),
    Star(pos: Position(0.5989895661671957, 0.35566643873850506), name: 'π Her', magnitude: 3.15, distance: 376.62),
    Star(pos: Position(0.5527831713358561, 0.3484599192937215), name: 'ρ Her', magnitude: 4.50, distance: 401.67),
    Star(pos: Position(0.3806750774383545, 0.3437968889872233), name: 'θ Her', magnitude: 3.85, distance: 753.25),
    Star(pos: Position(0.4735116958618164, 0.11361286044120789), name: 'ι Her', magnitude: 3.80, distance: 454.89),
    Star(pos: Position(0.84104323387146, 0.07122169435024261), name: 'τ Her', magnitude: 3.90, distance: 307.40),
    Star(pos: Position(0.8995429674784342, 0.09665639201800029), name: 'φ Her', magnitude: 4.20, distance: 218.90),
    Star(pos: Position(0.7922933101654053, 0.1852539380391439), name: 'σ Her', magnitude: 4.20, distance: 251.66),
    Star(pos: Position(0.7621955871582031, 0.28487316767374676), name: 'η Her', magnitude: 3.45, distance: 108.65),
    Star(pos: Position(0.7956845760345459, 0.47605737050374347), name: 'Rutilicus', magnitude: 2.85, distance: 35.21),
    Star(pos: Position(0.6914023558298746, 0.5057312250137329), name: 'ε Her', magnitude: 3.90, distance: 155.02),
    Star(pos: Position(0.8965756098429362, 0.7333717346191406), name: 'Kornephoros', magnitude: 2.75, distance: 139.15),
    Star(pos: Position(0.957194964090983, 0.788480281829834), name: 'Nasak Shamiya III', magnitude: 3.70, distance: 192.65),
  ],
  lines: [
    Line(0, 1),
    Line(1, 2),
    Line(2, 3),
    Line(3, 4),
    Line(4, 5),
    Line(5, 6),
    Line(5, 7),
    Line(7, 20),
    Line(7, 8),
    Line(8, 9),
    Line(9, 10),
    Line(6, 11),
    Line(11, 12),
    Line(12, 13),
    Line(13, 14),
    Line(14, 15),
    Line(15, 16),
    Line(14, 17),
    Line(16, 17),
    Line(11, 18),
    Line(18, 19),
    Line(19, 20),
    Line(11, 20),
    Line(20, 21),
    Line(21, 22),
  ],
  boundaries: [
    Position(0.3669398907103825, 0.6476851851851851),
    Position(0.3581967213114754, 0.6486111111111111),
    Position(0.35792349726775957, 0.6171296296296296),
    Position(0.35792349726775957, 0.6050925925925926),
    Position(0.3590163934426229, 0.5851851851851851),
    Position(0.3590163934426229, 0.5833333333333334),
    Position(0.3762295081967213, 0.5851851851851851),
    Position(0.3765027322404372, 0.5689814814814815),
    Position(0.3825136612021858, 0.5694444444444444),
    Position(0.387431693989071, 0.5032407407407408),
    Position(0.38633879781420766, 0.5032407407407408),
    Position(0.3877049180327869, 0.49212962962962964),
    Position(0.41174863387978144, 0.4976851851851852),
    Position(0.41174863387978144, 0.49444444444444446),
    Position(0.43333333333333335, 0.49074074074074076),
    Position(0.4382513661202186, 0.5236111111111111),
    Position(0.426775956284153, 0.5287037037037037),
    Position(0.43278688524590164, 0.5680555555555555),
    Position(0.43688524590163935, 0.5662037037037037),
    Position(0.4371584699453552, 0.5689814814814815),
    Position(0.44043715846994536, 0.5671296296296297),
    Position(0.442896174863388, 0.5787037037037037),
    Position(0.4456284153005464, 0.5768518518518518),
    Position(0.45, 0.5935185185185186),
    Position(0.4459016393442623, 0.5967592592592592),
    Position(0.4560109289617486, 0.6314814814814815),
    Position(0.45109289617486337, 0.6361111111111111),
    Position(0.4377049180327869, 0.6472222222222223),
    Position(0.4308743169398907, 0.6185185185185185),
    Position(0.416120218579235, 0.6268518518518519),
    Position(0.41530054644808745, 0.6217592592592592),
    Position(0.3819672131147541, 0.6333333333333333),
    Position(0.38278688524590165, 0.6439814814814815),
  ]
);