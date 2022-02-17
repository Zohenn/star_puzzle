import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:star_puzzle/constellation.dart';
import 'package:star_puzzle/constellations/leo.dart';
import 'package:star_puzzle/constellations/sagittarius.dart';
import 'package:star_puzzle/painters.dart';
import 'package:star_puzzle/services/base_service.dart';

class ConstellationMeta {
  ConstellationMeta(this.constellation) : constellationAnimation = ConstellationAnimation.from(constellation);

  final Constellation constellation;
  ConstellationAnimation constellationAnimation;
  final bestMoves = RxnInt();
  final bestTime = RxnInt();
  final solved = false.obs;
  ui.Image? image;
  Rxn<Uint8List> imageBytes = Rxn<Uint8List>();

  Future loadImage() async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    // todo: gridSize shouldn't be declared here
    final gridSize = Size(96, 96);
    final scale = MediaQuery.of(Get.context!).devicePixelRatio;
    final size = gridSize * scale;
    final foregroundPainter = ConstellationAnimationPainter(constellationAnimation, 0.3, useCircles: true);
    // backgroundPainter.paint(canvas, size);
    canvas.drawRect(Offset.zero & size, Paint()..color = Get.theme.backgroundColor);
    foregroundPainter.paint(canvas, size);
    image = await recorder.endRecording().toImage(size.width.floor(), size.height.floor());

    final byteData = await image!.toByteData(format: ui.ImageByteFormat.rawUnmodified);
    imageBytes.value = Uint8List.view(byteData!.buffer);
  }

  Future loadFinishedImage() async {
    constellationAnimation.skipForward();
    await loadImage();
  }
}

class ConstellationService extends GetxService {
  ConstellationService(this.containerKey);

  final List<Constellation> _constellations = [leo, sagittarius];
  final List<ConstellationMeta> constellations = [];
  final GlobalKey containerKey;
  Future? initFuture;

  @override
  void onInit() {
    super.onInit();

    initFuture = init();
  }

  Future init() async {
    await Future.wait(_constellations.map((e) {
      final constellationMeta = ConstellationMeta(e);
      constellations.add(constellationMeta);
      return constellationMeta.loadImage();
    }));
  }
}
