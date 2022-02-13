import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:star_puzzle/constellation.dart';
import 'package:star_puzzle/leo.dart';
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

class _MyHomePageState extends State<MyHomePage> {
  ui.Image? image;
  ConstellationAnimation constellationAnimation = ConstellationAnimation.from(leo);
  late Ticker ticker;
  int previousTime = 0;
  final containerKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    loadImage();

    Future.delayed(Duration(milliseconds: 200), startAnimation);
  }

  Future<void> loadImage() async {
    ByteData bd = await rootBundle.load("assets/night_sky.jpg");

    final Uint8List bytes = Uint8List.view(bd.buffer);

    final ui.Codec codec = await ui.instantiateImageCodec(bytes);

    final ui.Image _image = (await codec.getNextFrame()).image;

    setState(() => image = _image);
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
                  // decoration: BoxDecoration(border: Border.all()),
                  child: CustomPaint(
                    painter: ConstellationPainter(leo, image, containerKey),
                    foregroundPainter: ConstellationAnimationPainter(constellationAnimation),
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
                // Container(
                //   height: 150,
                //   width: 150,
                //   clipBehavior: Clip.hardEdge,
                //   decoration: BoxDecoration(),
                //   child: Transform.scale(
                //       scale: 25,
                //       child: Image.asset(
                //         'assets/wood.jpg',
                //         filterQuality: FilterQuality.high,
                //       )),
                // ),
                // Container(
                //   height: 100,
                //   width: 100,
                //   clipBehavior: Clip.hardEdge,
                //   decoration: BoxDecoration(),
                //   child: Transform.scale(
                //       scale: 1,
                //       child: Image.asset(
                //         'assets/wood_small.jpg',
                //         filterQuality: FilterQuality.high,
                //       )),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ConstellationPainter extends CustomPainter {
  ConstellationPainter(this.constellation, this.image, this.containerKey);

  final Constellation constellation;
  final ui.Image? image;
  final GlobalKey containerKey;

  final starPathSize = Size(12, 12);

  static const starSize = 0.03;

  static double get starShadowWidth => starSize * 0.25;

  static double get lineSize => starSize * 0.75;

  Offset sizeToOffset(Size size) => Offset(size.width, size.height);

  @override
  void paint(Canvas canvas, Size size) {
    // if (image != null) {
    //   // canvas.drawImageRect(
    //   //   image!,
    //   //   Offset(image!.width.toDouble() / 4, image!.width.toDouble() / 4) &
    //   //       Size(image!.width.toDouble() / 2, image!.height.toDouble() / 2),
    //   //   Offset.zero & size,
    //   //   Paint()
    //   //     ..colorFilter = ColorFilter.mode(Color(0xffe67404), BlendMode.modulate),
    //   // );
    //   final pieceSize = size / 3;
    //   for (var i = 0; i < 3; i++) {
    //     for (var j = 0; j < 3; j++) {
    //       canvas.saveLayer(Offset.zero & size, Paint());
    //       // final clipPath = Path();
    //       // clipPath.addRRect(RRect.fromRectAndRadius(Offset(pieceSize.width * i, pieceSize.height * j) & pieceSize, Radius.circular(6)));
    //       // canvas.clipPath(clipPath);
    //       var r = Offset(pieceSize.width * i, pieceSize.height * j) & pieceSize;
    //       canvas.drawImageRect(
    //         image!,
    //         Offset.zero & Size(image!.width.toDouble(), image!.height.toDouble()),
    //         Offset(pieceSize.width * i, pieceSize.height * j) & pieceSize,
    //         Paint()
    //           // ..colorFilter = ColorFilter.mode(Color(0xffe67404), BlendMode.modulate)
    //           ..strokeWidth = 1
    //           ..color = Colors.black,
    //       );
    //       var shadowWidth = 2;
    //       var path = Path();
    //       path.moveTo(r.left, r.bottom);
    //       path.lineTo(r.left + shadowWidth, r.bottom - shadowWidth);
    //       path.lineTo(r.right - shadowWidth, r.bottom - shadowWidth);
    //       path.lineTo(r.right, r.bottom);
    //       path.close();
    //       path.moveTo(r.left, r.top);
    //       path.lineTo(r.left + shadowWidth, r.top + shadowWidth);
    //       path.lineTo(r.left + 2, r.bottom - 2);
    //       path.lineTo(r.left, r.bottom);
    //       path.close();
    //       path.moveTo(r.right, r.top);
    //       path.lineTo(r.right - shadowWidth, r.top + shadowWidth);
    //       path.lineTo(r.right - shadowWidth, r.bottom - shadowWidth);
    //       path.lineTo(r.right, r.bottom);
    //       path.close();
    //       canvas.drawPath(
    //           path,
    //           Paint()
    //             ..color = Color(0xa0000000)
    //             ..blendMode = BlendMode.softLight);
    //       canvas.restore();
    //       path.reset();
    //       path.moveTo(r.left, r.top);
    //       path.lineTo(r.left + shadowWidth, r.top + shadowWidth);
    //       path.lineTo(r.right - shadowWidth, r.top + shadowWidth);
    //       path.lineTo(r.right, r.top);
    //       path.close();
    //       canvas.drawPath(
    //           path,
    //           Paint()
    //             ..color = Color(0x60ffffff)
    //             ..blendMode = BlendMode.hardLight);
    //     }
    //   }
    // }

    if (image != null) {
      final context = containerKey.currentContext!;
      final mq = MediaQuery.of(context);
      final screenSize = (mq.size) * mq.devicePixelRatio;
      final box = context.findRenderObject() as RenderBox;
      final pos = box.localToGlobal(Offset.zero);
      final scale = screenSize.height / image!.height;
      final srcSize = size * mq.devicePixelRatio * 1 / scale;
      final imageOffset =
          Offset(image!.width / 2 - srcSize.width / 2, pos.dy * mq.devicePixelRatio * 1 / scale);
      canvas.drawImageRect(image!, imageOffset & srcSize, Offset.zero & size, Paint());
    }

    final linePaint = Paint()
      ..color = Color(0x50ffffff)
      ..strokeWidth = (starPathSize / 5).width;
    for (var line in constellation.lines) {
      var firstStar = constellation.stars[line.start];
      var secondStar = constellation.stars[line.end];
      canvas.drawLine(
        firstStar.pos.toOffset(size),
        secondStar.pos.toOffset(size),
        linePaint,
      );
    }

    final starPaint = Paint()..color = Color(0xffffffff);
    for (var star in constellation.stars) {
      final starPath = getStarPath(starPathSize)
          .shift(star.pos.toOffset(size) - sizeToOffset(starPathSize) / 2);
      canvas.drawPath(starPath, starPaint);
    }

    // canvas.saveLayer(
    //     Offset.zero & size,
    //     Paint()
    //       ..color = Colors.white
    //       ..blendMode = BlendMode.softLight);

    // final starPaint = Paint()..color = Color(0xff000000);
    // for (var star in constellation.stars) {
    //   canvas.drawCircle(star.pos.toOffset(size), size.width * starSize, starPaint);
    // }
    //
    // final linePaint = Paint()
    //   ..color = Color(0xff000000)
    //   ..strokeWidth = size.width * lineSize;
    // for (var line in constellation.lines) {
    //   var firstStar = constellation.stars[line.start];
    //   var secondStar = constellation.stars[line.end];
    //   canvas.drawLine(
    //     firstStar.pos.toOffset(size),
    //     secondStar.pos.toOffset(size),
    //     linePaint,
    //   );
    // }
    //
    // canvas.restore();
    //
    // canvas.saveLayer(Offset.zero & size, Paint());
    //
    // final starShadowPaint = Paint()
    //   ..color = Color(0x80000000)
    //   ..strokeWidth = size.width * starShadowWidth
    //   ..style = PaintingStyle.stroke;
    // for (var star in constellation.stars) {
    //   canvas.drawCircle(
    //       star.pos.toOffset(size), size.width * starSize - size.width * starShadowWidth / 2, starShadowPaint);
    // }
    //
    // final lineShadowPaint = Paint()
    //   ..color = Color(0x80000000)
    //   ..strokeWidth = size.width * lineSize
    //   ..style = PaintingStyle.stroke;
    // for (var line in constellation.lines) {
    //   var firstStar = constellation.stars[line.start];
    //   var secondStar = constellation.stars[line.end];
    //   canvas.drawLine(
    //     firstStar.pos.toOffset(size),
    //     secondStar.pos.toOffset(size),
    //     lineShadowPaint,
    //   );
    // }
    //
    // final starShadowErasePaint = Paint()
    //   ..color = Color(0x80000000)
    //   ..blendMode = BlendMode.clear;
    // for (var star in constellation.stars) {
    //   canvas.drawCircle(
    //       star.pos.toOffset(size), size.width * starSize - size.width * starShadowWidth, starShadowErasePaint);
    // }
    //
    // final lineShadowErasePaint = Paint()
    //   ..color = Color(0x80000000)
    //   ..strokeWidth = size.width * lineSize - size.width * starShadowWidth * 2
    //   ..style = PaintingStyle.stroke
    //   ..blendMode = BlendMode.clear;
    // for (var line in constellation.lines) {
    //   var firstStar = constellation.stars[line.start];
    //   var secondStar = constellation.stars[line.end];
    //   canvas.drawLine(
    //     firstStar.pos.toOffset(size),
    //     secondStar.pos.toOffset(size),
    //     lineShadowErasePaint,
    //   );
    // }
    //
    // canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class ConstellationAnimationPainter extends CustomPainter {
  ConstellationAnimationPainter(this.constellation);

  final ConstellationAnimation constellation;

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()..color = Color(0xffFFF7D5);
    for (var star in constellation.stars) {
      canvas.drawCircle(star.pos.toOffset(size), size.width * ConstellationPainter.starSize * star.fill, starPaint);
    }

    final linePaint = Paint()
      ..color = Color(0xffFFF7D5)
      ..strokeWidth = size.width * ConstellationPainter.lineSize
      ..strokeCap = StrokeCap.round;
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
