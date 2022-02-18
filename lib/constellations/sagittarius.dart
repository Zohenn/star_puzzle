import 'dart:ui';

import 'package:star_puzzle/constellation.dart';

final sagittarius = Constellation(
  name: 'Sagittarius',
  skyFileName: 'sagittarius_sky.jpg',
  skyBoxOffset: const Offset(1545, 535),
  stars: [
    // Star(pos: Position(0.14841665824254355, 0.7243541876475016)),
    // Star(pos: Position(0.12222916881243388, 0.5680833260218302)),
    // Star(pos: Position(0.12047916650772095, 0.5325624942779541)),
    // Star(pos: Position(0.10514583190282185, 0.38850001494089764)),
    // Star(pos: Position(0.25950000683466595, 0.3215000033378601)),
    // Star(pos: Position(0.3476041555404663, 0.15302082896232605)),
    // Star(pos: Position(0.37325000762939453, 0.1809583306312561)),
    // Star(pos: Position(0.41600000858306885, 0.22614582379659018)),
    // Star(pos: Position(0.4482291539510091, 0.2452500065167745)),
    // Star(pos: Position(0.48900000254313153, 0.22964582840601602)),
    // Star(pos: Position(0.4338124990463257, 0.3851666847864787)),
    // Star(pos: Position(0.45766667524973553, 0.4358333349227905)),
    // Star(pos: Position(0.49956250190734863, 0.3488750060399373)),
    // Star(pos: Position(0.5598541498184204, 0.3686041831970215)),
    // Star(pos: Position(0.664104183514913, 0.3304583430290222)),
    // Star(pos: Position(0.7509791851043701, 0.22920833031336466)),
    // Star(pos: Position(0.7051666577657064, 0.4348125060399373)),
    // Star(pos: Position(0.6833541393280029, 0.5401666561762491)),
    // Star(pos: Position(0.726437489191691, 0.6008541584014893)),
    // Star(pos: Position(0.7961874802907308, 0.44974998633066815)),
    // Star(pos: Position(0.908020814259847, 0.39149999618530273)),
    // Star(pos: Position(0.3344791730244954, 0.6942500273386637)),
    // Star(pos: Position(0.34193750222524005, 0.7856041590372721)),
    Star(pos: Position(0.10569952925046285, 0.837079922358195)),
    Star(pos: Position(0.08132179578145345, 0.6346089839935303)),
    Star(pos: Position(0.06658176084359486, 0.4057055314381917)),
    Star(pos: Position(0.24704084793726602, 0.33039941390355426)),
    Star(pos: Position(0.37726883093516034, 0.12928909063339233)),
    Star(pos: Position(0.4005415042241414, 0.16671927769978842)),
    Star(pos: Position(0.44922443230946857, 0.23801171779632568)),
    Star(pos: Position(0.4802670081456502, 0.26304880777994794)),
    Star(pos: Position(0.5305305322011312, 0.2533775766690572)),
    Star(pos: Position(0.43796555201212567, 0.4373764991760254)),
    Star(pos: Position(0.45529353618621826, 0.5070285399754842)),
    Star(pos: Position(0.5203277667363485, 0.4099842309951782)),
    Star(pos: Position(0.5794328451156616, 0.4421725670496623)),
    Star(pos: Position(0.7068212827046713, 0.4218255281448364)),
    Star(pos: Position(0.835226853688558, 0.3205755352973938)),
    Star(pos: Position(0.7182191212972006, 0.5629639228185018)),
    Star(pos: Position(0.664368748664856, 0.6896766026814779)),
    Star(pos: Position(0.6849069595336914, 0.7681629657745361)),
    Star(pos: Position(0.806866725285848, 0.6063794692357382)),
    Star(pos: Position(0.945991595586141, 0.5718612273534139)),
    Star(pos: Position(0.2840492328008016, 0.80875563621521)),
    Star(pos: Position(0.27548863490422565, 0.9321476618448893)),
  ],
  lines: [
    Line(21, 0),
    Line(0, 20),
    Line(0, 1),
    Line(1, 2),
    Line(2, 3),
    Line(3, 9),
    Line(9, 10),
    Line(9, 11),
    Line(11, 12),
    Line(10, 12),
    Line(11, 8),
    Line(8, 7),
    Line(7, 6),
    Line(6, 5),
    Line(5, 4),
    Line(12, 13),
    Line(13, 14),
    Line(13, 15),
    Line(15, 16),
    Line(16, 17),
    Line(15, 18),
    Line(18, 19)
  ],
  starSize: 10,
);
