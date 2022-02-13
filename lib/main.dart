import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:star_puzzle/constellation.dart';
import 'package:star_puzzle/leo.dart';
import 'package:star_puzzle/puzzle.dart';
import 'package:star_puzzle/star_path.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
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
  late Ticker ticker;
  int previousTime = 0;
  final containerKey = GlobalKey();
  Puzzle puzzle = Puzzle(
    [
      Tile(TilePosition(0, 0), TilePosition(0, 0), false),
      Tile(TilePosition(0, 1), TilePosition(0, 1), false),
      Tile(TilePosition(0, 2), TilePosition(0, 2), false),
      Tile(TilePosition(1, 0), TilePosition(1, 0), false),
      Tile(TilePosition(1, 1), TilePosition(1, 1), false),
      Tile(TilePosition(1, 2), TilePosition(1, 2), false),
      Tile(TilePosition(2, 0), TilePosition(2, 0), false),
      Tile(TilePosition(2, 1), TilePosition(2, 1), false),
      Tile(TilePosition(2, 2), TilePosition(2, 2), true),
    ],
  );
  final animationControllers = <int, AnimationController>{};
  final animations = <int, Animation<TilePosition>>{};

  @override
  void initState() {
    super.initState();

    for (var tile in puzzle.tiles) {
      final animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 150));
      animationControllers[tile.number] = animationController;
      animations[tile.number] =
          tile.positionTween.animate(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));
    }

    loadImage();

    Future.delayed(Duration(milliseconds: 200), startAnimation);
  }

  Future<void> loadImage() async {
    ByteData bd = await rootBundle.load("assets/night_sky.jpg");

    final Uint8List bytes = Uint8List.view(bd.buffer);

    final ui.Codec codec = await ui.instantiateImageCodec(bytes);

    final ui.Image _image = (await codec.getNextFrame()).image;

    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    final backgroundPainter = ConstellationBackgroundPainter(_image, containerKey);
    final foregroundPainter = ConstellationAnimationPainter(constellationAnimation);
    final size = containerKey.currentContext!.size!;
    // final size = Size(900, 900);
    backgroundPainter.paint(canvas, size);
    foregroundPainter.paint(canvas, size);
    final _renderedImage = await recorder.endRecording().toImage(size.width.floor(), size.height.floor());

    setState(() {
      image = _image;
      renderedImage = _renderedImage;
    });
  }

  void startAnimation() {
    constellationAnimation.stars.first.shouldFill = true;
    ticker = Ticker((elapsed) {
      var finished = constellationAnimation.tick(elapsed.inMilliseconds - previousTime);
      previousTime = elapsed.inMilliseconds;
      if (!finished) {
        setState(() {});
      } else {
        ticker.stop();
      }
    });
    // ticker.start();
  }

  @override
  void dispose() {
    ticker.stop();
    ticker.dispose();
    animationControllers.forEach((key, value) {
      value.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/night_sky.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Color(0x20ffffff), BlendMode.screen),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  key: containerKey,
                  height: 300,
                  width: 300,
                  // child: CustomPaint(
                  //   painter: ConstellationBackgroundPainter(image, containerKey),
                  //   foregroundPainter: ConstellationAnimationPainter(constellationAnimation),
                  // ),
                  child: Stack(
                    children: [
                      for (var tile in puzzle.tiles)
                        AnimatedBuilder(
                          animation: animations[tile.number]!,
                          builder: (context, child) {
                            final position = animations[tile.number]!.value;
                            return Positioned(
                              top: position.x * 100,
                              left: position.y * 100,
                              child: child!,
                            );
                          },
                          child: PuzzleTile(
                            tile: tile,
                            onTap: () {
                              if (!puzzle.canMoveTile(tile)) {
                                return;
                              }
                              final updatedTiles = puzzle.moveTile(tile);
                              for (var tile in updatedTiles) {
                                final animationController = animationControllers[tile.number]!;
                                animations[tile.number] = tile.positionTween
                                    .animate(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));
                                animationController.reset();
                                animationController.forward();
                              }
                            },
                            renderedImage: renderedImage,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    constellationAnimation = ConstellationAnimation.from(leo);
                    constellationAnimation.stars.first.shouldFill = true;
                    if (!ticker.isTicking) {
                      previousTime = 0;
                      ticker.start();
                    }
                  },
                  child: Text('Reset'),
                ),
                TextButton(
                  onPressed: () {
                    constellationAnimation = ConstellationAnimation.from(leo);
                    setState(() {});
                  },
                  child: Text('Clear'),
                ),
                TextButton(onPressed: () => loadImage(), child: Text('Reload image')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PuzzleTile extends StatelessWidget {
  const PuzzleTile({
    Key? key,
    required this.tile,
    required this.onTap,
    required this.renderedImage,
  }) : super(key: key);

  final Tile tile;
  final VoidCallback onTap;
  final ui.Image? renderedImage;

  @override
  Widget build(BuildContext context) {
    if (tile.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 100,
      height: 100,
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
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text('${tile.number}', style: TextStyle(color: Colors.white.withOpacity(0.2))),
            ),
          ),
        ),
      ),
    );
  }
}

class ConstellationBackgroundPainter extends CustomPainter {
  ConstellationBackgroundPainter(this.image, this.containerKey);

  final ui.Image? image;
  final GlobalKey containerKey;

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      final context = containerKey.currentContext!;
      final mq = MediaQuery.of(context);
      final screenSize = (mq.size) * mq.devicePixelRatio;
      final box = context.findRenderObject() as RenderBox;
      final pos = box.localToGlobal(Offset.zero);
      final scale = screenSize.height / image!.height;
      final srcSize = size * mq.devicePixelRatio * 1 / scale;
      final imageOffset = Offset(image!.width / 2 - srcSize.width / 2, pos.dy * mq.devicePixelRatio * 1 / scale);
      canvas.drawImageRect(image!, imageOffset & srcSize, Offset.zero & size, Paint());
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class ConstellationAnimationPainter extends CustomPainter {
  ConstellationAnimationPainter(this.constellation);

  final ConstellationAnimation constellation;

  static const starPathSize = Size(12, 12);

  static Offset sizeToOffset(Size size) => Offset(size.width, size.height);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Color(0x30ffffff)
      ..strokeWidth = (starPathSize / 5).width;
    for (var line in constellation.lines) {
      var firstStar = constellation.stars[line.start];
      if (line.shouldFill) {
        var secondStar = constellation.stars[line.end];
        var firstStarOffset = firstStar.pos.toOffset(size);
        var secondStarOffset = secondStar.pos.toOffset(size);
        canvas.drawLine(
          firstStarOffset,
          firstStarOffset + (secondStarOffset - firstStarOffset) * line.fill,
          linePaint,
        );
      }
    }

    // final starPaint = Paint()..color = Color(0xffFFF7D5);
    final starPaint = Paint()..color = Color(0xffffffff);
    for (var star in constellation.stars) {
      final starPath = getStarPath(starPathSize).shift(star.pos.toOffset(size) - sizeToOffset(starPathSize) / 2);
      if (star.fill != 0 && star.fill != 1) {
        canvas.save();
        canvas.translate(star.pos.toOffset(size).dx, star.pos.toOffset(size).dy);
        canvas.rotate(star.fill * pi);
        canvas.scale(sin(star.fill * pi) * 0.5 + 1);
        canvas.translate(-star.pos.toOffset(size).dx, -star.pos.toOffset(size).dy);
      }
      canvas.drawShadow(starPath, Color(0xffffffff), star.fill * 2, true);
      canvas.drawPath(starPath, starPaint);
      if (star.fill != 0 && star.fill != 1) {
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class PiecePainter extends CustomPainter {
  PiecePainter(
    this.image,
    this.i,
    this.j,
  );

  ui.Image? image;
  late int i;
  late int j;

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      // paintImage(canvas: canvas, rect: Offset.zero & size, image: image!, fit: BoxFit.scaleDown);
      canvas.drawImageRect(image!, Offset(j.toDouble(), i.toDouble()) * 100 & Size(100, 100), Offset.zero & size,
          Paint()..filterQuality = FilterQuality.high);
      // canvas.drawAtlas(
      //   image!,
      //   [RSTransform.fromComponents(rotation: 0, scale: 100 / 300, anchorX: 0, anchorY: 0, translateX: 0, translateY: 0)],
      //   [Rect.fromLTWH(j * 300, i * 300, 300, 300)],
      //   [],
      //   BlendMode.src,
      //   null,
      //   Paint(),
      // );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
