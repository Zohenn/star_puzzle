import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:star_puzzle/bootstrap.dart';
import 'package:star_puzzle/constellation.dart';
import 'package:star_puzzle/constellations/leo.dart';
import 'package:star_puzzle/constellations/sagittarius.dart';
import 'package:star_puzzle/painters.dart';
import 'package:star_puzzle/puzzle.dart';
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
  ui.Image? image;
  ui.Image? renderedImage;
  ConstellationAnimation constellationAnimation = ConstellationAnimation.from(sagittarius);
  Ticker? ticker;
  int previousTime = 0;
  final containerKey = GlobalKey();
  late Puzzle puzzle;

  // = Puzzle(
  //   [
  //     Tile(TilePosition(0, 0), TilePosition(0, 0), false),
  //     Tile(TilePosition(0, 1), TilePosition(0, 1), false),
  //     Tile(TilePosition(0, 2), TilePosition(0, 2), false),
  //     Tile(TilePosition(1, 0), TilePosition(1, 0), false),
  //     Tile(TilePosition(1, 1), TilePosition(1, 1), false),
  //     Tile(TilePosition(1, 2), TilePosition(1, 2), false),
  //     Tile(TilePosition(2, 0), TilePosition(2, 0), false),
  //     Tile(TilePosition(2, 1), TilePosition(2, 1), false),
  //     Tile(TilePosition(2, 2), TilePosition(2, 2), true),
  //   ],
  // );
  final animationControllers = <int, AnimationController>{};
  final animations = <int, Animation<TilePosition>>{};
  bool complete = true;
  bool showAnimation = false;
  late ConstellationMeta selectedConstellation;

  final gridSize = Size(300, 300);
  final size = 3;

  Size get tileSize => gridSize / size.toDouble();

  List<ConstellationMeta> get constellations => Get.find<ConstellationService>().constellations;

  @override
  void initState() {
    super.initState();

    selectedConstellation = constellations.first;

    puzzle = Puzzle.generate(size);

    // puzzle = Puzzle([
    //   Tile(TilePosition(0, 0), TilePosition(2, 2), false),
    //   Tile(TilePosition(1, 0), TilePosition(1, 2), false),
    //   Tile(TilePosition(2, 0), TilePosition(2, 1), false),
    //   Tile(TilePosition(0, 1), TilePosition(2, 0), false),
    //   Tile(TilePosition(1, 1), TilePosition(0, 2), false),
    //   Tile(TilePosition(2, 1), TilePosition(0, 1), false),
    //   Tile(TilePosition(0, 2), TilePosition(1, 1), false),
    //   Tile(TilePosition(1, 2), TilePosition(0, 0), false),
    //   Tile(TilePosition(2, 2), TilePosition(1, 0), true),
    // ]);

    for (var tile in puzzle.tiles) {
      final animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 150));
      animationControllers[tile.number] = animationController;
      animations[tile.number] = animatePosition(tile.positionTween, animationController);
    }

    loadImage();

    // Future.delayed(Duration(milliseconds: 200), startAnimation);
  }

  Animation<TilePosition> animatePosition(TilePositionTween tween, AnimationController controller) {
    return tween.animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  Future<void> loadImage() async {
    ByteData bd = await rootBundle.load("assets/night_sky.jpg");

    final Uint8List bytes = Uint8List.view(bd.buffer);
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.Image _image = (await codec.getNextFrame()).image;
    codec.dispose();

    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    // final size = containerKey.currentContext!.size!;
    final scale = MediaQuery.of(context).devicePixelRatio;
    final size = gridSize * scale;
    final backgroundPainter = ConstellationBackgroundPainter(_image, containerKey);
    final foregroundPainter = ConstellationAnimationPainter(constellationAnimation, scale);
    backgroundPainter.paint(canvas, size);
    foregroundPainter.paint(canvas, size);
    final _renderedImage = await recorder.endRecording().toImage(size.width.floor(), size.height.floor());

    setState(() {
      image = _image;
      renderedImage = _renderedImage;
    });
  }

  void startAnimation() {
    if (ticker != null) {
      ticker!.stop();
      ticker!.dispose();
    }
    constellationAnimation = ConstellationAnimation.from(sagittarius);
    constellationAnimation.stars.first.shouldFill = true;
    previousTime = 0;
    ticker = Ticker((elapsed) {
      var finished = constellationAnimation.tick(elapsed.inMilliseconds - previousTime);
      previousTime = elapsed.inMilliseconds;
      if (!finished) {
        setState(() {});
      } else {
        ticker!.stop();
      }
    });
    ticker!.start();
  }

  @override
  void dispose() {
    ticker?.stop();
    ticker?.dispose();
    animationControllers.forEach((key, value) {
      value.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: constellations.length,
        initialIndex: 0,
        child: Stack(
          children: [
            Positioned.fill(child: Image.asset('assets/night_sky.jpg', fit: BoxFit.cover, filterQuality: FilterQuality.high,)),
            Positioned.fill(
              child: AnimatedContainer(
                color: complete ? Color(0x00ffffff) : Color(0x20ffffff),
                duration: Duration(milliseconds: 500),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      for (var constellation in constellations)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                constellation.solved ? constellation.constellation.name : 'Unknown',
                                style: Theme.of(context).textTheme.headline4!.copyWith(color: constellation.solved ? Colors.white : Colors.white60),
                              ),
                              SizedBox(height: 16),
                              SizedBox.fromSize(
                                size: gridSize,
                                child: CustomPaint(
                                  painter: ConstellationAnimationPainter(constellation.constellationAnimation, 1),
                                ),
                              ),
                              SizedBox(height: 16),
                              TextButton(
                                onPressed: () {},
                                child: Text('Solve'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                SingleChildScrollView(
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
                              // side: BorderSide(
                              //     color: constellation == Get.find<ConstellationService>().constellations.first
                              //         ? Color(0xfffff8dc).withOpacity(0.6)
                              //         : Colors.transparent),
                            ),
                            margin: EdgeInsets.zero,
                            color: Colors.transparent,
                            elevation: selectedConstellation == constellation ? 4 : 0,
                            // shadowColor: Color(0xfffff8dc),
                            child: Stack(
                              children: [
                                SizedBox.square(
                                  dimension: 96,
                                  child: Image.memory(
                                    constellation.imageBytes!,
                                    fit: BoxFit.cover,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PuzzleTile extends StatelessWidget {
  const PuzzleTile({
    Key? key,
    required this.tile,
    required this.tileSize,
    required this.onTap,
    required this.renderedImage,
    required this.complete,
  }) : super(key: key);

  final Tile tile;
  final Size tileSize;
  final VoidCallback onTap;
  final ui.Image? renderedImage;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    if (tile.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: tileSize.width,
      height: tileSize.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.all(1.0),
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: PiecePainter(
            renderedImage,
            tile.originalPosition.x.toInt(),
            tile.originalPosition.y.toInt(),
            tileSize,
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: AnimatedDefaultTextStyle(
                child: Text('${tile.number}'),
                style: TextStyle(color: complete ? Colors.transparent : Colors.white.withOpacity(0.2)),
                duration: Duration(milliseconds: 500),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
