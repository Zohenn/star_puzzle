import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:star_puzzle/bootstrap.dart';
import 'package:star_puzzle/constellation.dart';
import 'package:star_puzzle/constellations/leo.dart';
import 'package:star_puzzle/painters.dart';
import 'package:star_puzzle/puzzle.dart';
import 'package:star_puzzle/services/constellation_service.dart';
import 'package:star_puzzle/widgets/star_loader.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
  ConstellationAnimation constellationAnimation = ConstellationAnimation.from(leo);
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
  bool complete = false;
  bool showAnimation = false;

  final gridSize = Size(300, 300);
  final size = 3;

  Size get tileSize => gridSize / size.toDouble();

  @override
  void initState() {
    super.initState();

    puzzle = Puzzle.generate(size);

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
    constellationAnimation = ConstellationAnimation.from(leo);
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
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/night_sky.jpg', fit: BoxFit.cover)),
          Positioned.fill(
            child: AnimatedContainer(
              color: complete ? Color(0x00ffffff) : Color(0x20ffffff),
              duration: Duration(milliseconds: 500),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox.fromSize(
                          key: containerKey,
                          size: gridSize,
                          child: showAnimation
                              ? CustomPaint(
                                  painter: ConstellationAnimationPainter(constellationAnimation, 1),
                                )
                              : Stack(
                                  children: [
                                    for (var tile in puzzle.tiles)
                                      AnimatedBuilder(
                                        animation: animations[tile.number]!,
                                        builder: (context, child) {
                                          final position = animations[tile.number]!.value;
                                          return Positioned(
                                            left: position.y * tileSize.height,
                                            top: position.x * tileSize.width,
                                            child: child!,
                                          );
                                        },
                                        child: PuzzleTile(
                                          tile: tile,
                                          tileSize: tileSize,
                                          onTap: () {
                                            if (!puzzle.canMoveTile(tile) ||
                                                animationControllers.values.any((element) => element.isAnimating)) {
                                              return;
                                            }
                                            final updatedTiles = puzzle.moveTile(tile);
                                            for (var tile in updatedTiles) {
                                              final animationController = animationControllers[tile.number]!;
                                              animations[tile.number] =
                                                  animatePosition(tile.positionTween, animationController);
                                              animationController.reset();
                                              animationController.forward();
                                            }
                                          },
                                          renderedImage: renderedImage,
                                          complete: complete,
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                        SizedBox(height: 16),
                        // TextButton(onPressed: () => loadImage(), child: Text('Reload image')),
                        // TextButton(
                        //   onPressed: () => setState(() {
                        //     complete = !complete;
                        //     Future.delayed(Duration(milliseconds: 600), () {
                        //       setState(() {
                        //         showAnimation = complete;
                        //         startAnimation();
                        //       });
                        //     });
                        //   }),
                        //   child: Text('Complete'),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    for (var constellation in Get.find<ConstellationService>().constellations) ...[
                      Card(
                        clipBehavior: Clip.hardEdge,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        margin: EdgeInsets.zero,
                        color: Colors.transparent,
                        elevation: 4,
                        child: SizedBox.square(
                          dimension: 72,
                          child: Image.memory(constellation.imageBytes!, fit: BoxFit.cover,),
                        ),
                      ),
                      if(constellation != Get.find<ConstellationService>().constellations.last)
                        SizedBox(width: 16),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
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
