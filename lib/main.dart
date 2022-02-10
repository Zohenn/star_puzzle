import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:star_puzzle/constellation.dart';
import 'package:star_puzzle/leo.dart';

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

  @override
  void initState() {
    super.initState();

    loadImage();

    Future.delayed(Duration(milliseconds: 200), startAnimation);
  }

  Future<void> loadImage() async {
    ByteData bd = await rootBundle.load("assets/wood.jpg");

    final Uint8List bytes = Uint8List.view(bd.buffer);

    final ui.Codec codec = await ui.instantiateImageCodec(bytes);

    final ui.Image _image = (await codec.getNextFrame()).image;

    setState(() => image = _image);
  }

  void startAnimation() {
    constellationAnimation.stars.first.shouldFill = true;
    ticker = Ticker((d) {
      var finished = constellationAnimation.tick();
      if (!finished) {
        setState(() {});
      } else {
        ticker.stop();
      }
    });
    ticker.start();
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
      appBar: AppBar(
        title: Text('demo'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 300,
                width: 300,
                decoration:
                    BoxDecoration(border: Border.all(), image: DecorationImage(image: AssetImage('assets/wood.jpg'))),
                child: CustomPaint(
                  painter: ConstellationPainter(leo, image),
                  foregroundPainter: ConstellationAnimationPainter(constellationAnimation),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  constellationAnimation = ConstellationAnimation.from(leo);
                  constellationAnimation.stars.first.shouldFill = true;
                  if (!ticker.isTicking) {
                    ticker.start();
                  }
                },
                child: Text('Reset'),
              ),
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
    );
  }
}

class ConstellationPainter extends CustomPainter {
  ConstellationPainter(this.constellation, this.image);

  final Constellation constellation;
  final ui.Image? image;

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      canvas.drawImageRect(
          image!, Offset.zero & Size(image!.width.toDouble(), image!.height.toDouble()), Offset.zero & size, Paint());
    }

    canvas.saveLayer(
        Offset.zero & size,
        Paint()
          ..color = Colors.white
          ..blendMode = BlendMode.softLight);

    final starPaint = Paint()..color = Color(0xff222222);
    for (var star in constellation.stars) {
      canvas.drawCircle(star.pos.toOffset(size), size.width / 50, starPaint);
    }

    final linePaint = Paint()
      ..color = Color(0xff222222)
      ..strokeWidth = size.width / 75;
    for (var line in constellation.lines) {
      var firstStar = constellation.stars[line.start];
      var secondStar = constellation.stars[line.end];
      canvas.drawLine(
        firstStar.pos.toOffset(size),
        secondStar.pos.toOffset(size),
        linePaint,
      );
    }

    canvas.restore();
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
    final starPaint = Paint()..color = Colors.white;
    for (var star in constellation.stars) {
      canvas.drawCircle(star.pos.toOffset(size), size.width / 50 * star.fill, starPaint);
    }

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width / 75
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
