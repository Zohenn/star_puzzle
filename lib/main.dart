import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:star_puzzle/bootstrap.dart';
import 'package:star_puzzle/constellation.dart';
import 'package:star_puzzle/constellations/leo.dart';
import 'package:star_puzzle/constellations/sagittarius.dart';
import 'package:star_puzzle/new_constellation_puzzle.dart';
import 'package:star_puzzle/painters.dart';
import 'package:star_puzzle/puzzle.dart';
import 'package:star_puzzle/services/base_service.dart';
import 'package:star_puzzle/services/constellation_service.dart';
import 'package:star_puzzle/widgets/star_loader.dart';
import 'package:star_puzzle/widgets/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ThemeProvider(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: Theme.of(context),
      home: Bootstrap(),
      // home: Scaffold(body: Stack(
      //   children: [
      //     Positioned.fill(child: Image.asset('assets/night_sky.jpg', fit: BoxFit.cover)),
      //     Center(child: StarLoader(),),
      //   ],
      // ),),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late ConstellationMeta selectedConstellation;
  bool isSolving = false;

  final gridSize = Size(300, 300);
  final size = 3;

  List<ConstellationMeta> get constellations => Get.find<ConstellationService>().constellations;

  SolvingState get solvingState => Get.find<BaseService>().solvingState();

  @override
  void initState() {
    super.initState();

    selectedConstellation = constellations.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: constellations.length,
        initialIndex: 0,
        child: Stack(
          children: [
            Positioned.fill(
                child: Image.asset(
              'assets/night_sky.jpg',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            )),
            Positioned.fill(
              child: Obx(
                () => AnimatedContainer(
                  color: solvingState == SolvingState.solving ? Color(0x20ffffff) : Color(0x00ffffff),
                  duration: kThemeChangeDuration,
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      for (var constellation in constellations)
                        NewConstellationPuzzle(
                          constellation: constellation,
                          gridSize: gridSize,
                        ),
                    ],
                  ),
                ),
                Obx(
                  () => AnimatedContainer(
                    duration: kThemeChangeDuration,
                    curve: Curves.easeInOut,
                    transform: Matrix4.translationValues(0, solvingState != SolvingState.none ? 96 + 2 * 24 : 0, 0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Row(
                        children: [
                          for (var constellation in constellations) ...[
                            AnimatedContainer(
                              duration: kThemeChangeDuration,
                              curve: Curves.easeInOut,
                              transform: Matrix4.translationValues(0, selectedConstellation == constellation ? -8 : 0, 0),
                              child: Card(
                                clipBehavior: Clip.hardEdge,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                margin: EdgeInsets.zero,
                                color: Colors.transparent,
                                elevation: selectedConstellation == constellation ? 4 : 0,
                                // shadowColor: Color(0xfffff8dc),
                                child: Stack(
                                  children: [
                                    SizedBox.square(
                                      dimension: 96,
                                      child: Obx(
                                        () => Image.memory(
                                          constellation.imageBytes()!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: AnimatedContainer(
                                        duration: kThemeChangeDuration,
                                        color: selectedConstellation == constellation
                                            ? Colors.transparent
                                            : Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Material(
                                        type: MaterialType.transparency,
                                        child: Builder(
                                          builder: (context) => InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedConstellation = constellation;
                                                DefaultTabController.of(context)!
                                                    .animateTo(constellations.indexOf(constellation));
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (constellation != constellations.last) SizedBox(width: 16),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
