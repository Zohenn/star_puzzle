import 'dart:ui';

import 'package:star_puzzle/constellation.dart';

final sagittarius = Constellation(
  name: 'Sagittarius',
  skyFileName: 'sagittarius_sky.jpg',
  skyBoxOffset: const Offset(1550, 712),
  skyBoxSize: const Size.square(550),
  backgroundColor: const Color(0xff1e0c00),
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
    // Star(pos: Position(0.10569952925046285, 0.837079922358195)),
    // Star(pos: Position(0.08132179578145345, 0.6346089839935303)),
    // Star(pos: Position(0.06658176084359486, 0.4057055314381917)),
    // Star(pos: Position(0.24704084793726602, 0.33039941390355426)),
    // Star(pos: Position(0.37726883093516034, 0.12928909063339233)),
    // Star(pos: Position(0.4005415042241414, 0.16671927769978842)),
    // Star(pos: Position(0.44922443230946857, 0.23801171779632568)),
    // Star(pos: Position(0.4802670081456502, 0.26304880777994794)),
    // Star(pos: Position(0.5305305322011312, 0.2533775766690572)),
    // Star(pos: Position(0.43796555201212567, 0.4373764991760254)),
    // Star(pos: Position(0.45529353618621826, 0.5070285399754842)),
    // Star(pos: Position(0.5203277667363485, 0.4099842309951782)),
    // Star(pos: Position(0.5794328451156616, 0.4421725670496623)),
    // Star(pos: Position(0.7068212827046713, 0.4218255281448364)),
    // Star(pos: Position(0.835226853688558, 0.3205755352973938)),
    // Star(pos: Position(0.7182191212972006, 0.5629639228185018)),
    // Star(pos: Position(0.664368748664856, 0.6896766026814779)),
    // Star(pos: Position(0.6849069595336914, 0.7681629657745361)),
    // Star(pos: Position(0.806866725285848, 0.6063794692357382)),
    // Star(pos: Position(0.945991595586141, 0.5718612273534139)),
    // Star(pos: Position(0.2840492328008016, 0.80875563621521)),
    // Star(pos: Position(0.27548863490422565, 0.9321476618448893)),
    Star(pos: Position(0.13744073112805685, 0.8379698594411215), name: 'ι Sgr', magnitude: 4.10, distance: 181.80),
    Star(pos: Position(0.11128311355908711, 0.6473647753397623), name: 'θ1 Sgr', magnitude: 4.35, distance: 518.53),
    Star(pos: Position(0.09209337830543518, 0.4267674684524536), name: 'Terebellum IV', magnitude: 4.40, distance: 448.63),
    Star(pos: Position(0.26454299688339233, 0.3517579634984334), name: 'h2 Sgr', magnitude: 4.55, distance: 189.63),
    Star(pos: Position(0.384981632232666, 0.15747053424517313), name: 'ρ1 Sgr', magnitude: 3.90, distance: 126.96),
    Star(pos: Position(0.4085509777069092, 0.19252755244572958), name: 'd Sgr', magnitude: 4.85, distance: 467.94),
    Star(pos: Position(0.454267422358195, 0.2590736150741577), name: 'Albaldah', magnitude: 2.85, distance: 509.62),
    Star(pos: Position(0.48530999819437665, 0.28559396664301556), name: 'ο Sgr', magnitude: 3.75, distance: 142.05),
    Star(pos: Position(0.5346835851669312, 0.27236296733220416), name: 'ξ Sgr', magnitude: 3.50, distance: 365.24),
    Star(pos: Position(0.4477548996607463, 0.45102226734161377), name: 'Namalsadirah II', magnitude: 3.30, distance: 116.99),
    Star(pos: Position(0.4662694533665975, 0.5174111922581991), name: 'Ascella', magnitude: 3.25, distance: 89.09),
    Star(pos: Position(0.5271506309509277, 0.4236299991607666), name: 'Nunki', magnitude: 2.05, distance: 227.76),
    Star(pos: Position(0.5841792027155558, 0.4528518517812093), name: 'Namalsadirah I', magnitude: 3.15, distance: 239.29),
    Star(pos: Position(0.704151471455892, 0.4325048128763835), name: 'Kaus Borealis', magnitude: 2.80, distance: 192.24),
    Star(pos: Position(0.8257341384887695, 0.33125482002894086), name: 'Polis', magnitude: 3.80, distance: 36239.60),
    Star(pos: Position(0.7190581957499186, 0.5667396386464437), name: 'Kaus Media', magnitude: 2.70, distance: 347.71),
    Star(pos: Position(0.670451800028483, 0.688208262125651), name: 'Kaus Australis', magnitude: 1.75, distance: 143.30),
    Star(pos: Position(0.690780242284139, 0.7620798746744791), name: 'Hamalwarid', magnitude: 3.10, distance: 145.93),
    Star(pos: Position(0.8053835233052572, 0.6051928997039795), name: 'Alnasl', magnitude: 2.95, distance: 96.87),
    Star(pos: Position(0.9387237230936686, 0.5677081743876139), name: '2 Sgr', magnitude: 4.50, distance: 950.89),
    Star(pos: Position(0.30718767642974854, 0.8081623713175455), name: 'Rukbat', magnitude: 3.95, distance: 181.80),
    Star(pos: Position(0.30189019441604614, 0.9282912413279215), name: 'Arkab Posterior', magnitude: 4.25, distance: 134.17),
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
  starSize: 12,
);
