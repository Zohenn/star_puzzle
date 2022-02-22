import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:star_puzzle/constellation_progress.dart';
import 'package:star_puzzle/constellations/constellation.dart';
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
  ui.Image? skyImage;
  Rxn<Uint8List> imageBytes = Rxn<Uint8List>();

  Future loadImages() {
    return Future.wait([loadImage(), loadSkyImage()]);
  }

  Future loadImage() async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    final size = Get.find<BaseService>().constellationIconSize * MediaQuery.of(Get.context!).devicePixelRatio;
    final foregroundPainter = ConstellationAnimationPainter(Get.context!, constellationAnimation, 0.3, useCircles: true);
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

  Future loadSkyImage() async {
    ByteData bd = await rootBundle.load('assets/${constellation.skyFileName}');

    final Uint8List bytes = Uint8List.view(bd.buffer);
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    skyImage = (await codec.getNextFrame()).image;
    codec.dispose();
  }

  void loadProgress(ConstellationProgress constellationProgress) {
    solved.value = constellationProgress.solved;
    bestMoves.value = constellationProgress.bestMoves;
    bestTime.value = constellationProgress.bestTime;

    if(solved()){
      constellationAnimation.skipForward();
    }
  }
}

class ConstellationService extends GetxService {
  ConstellationService();

  final List<Constellation> _constellations = [leo, sagittarius];
  final List<ConstellationMeta> constellations = [];

  @override
  void onInit() {
    super.onInit();

    for(var constellation in _constellations){
      final constellationMeta = ConstellationMeta(constellation);
      constellations.add(constellationMeta);
    }
  }

  Future loadImages() {
    return Future.wait(constellations.map((e) => e.loadImages()));
  }
}
