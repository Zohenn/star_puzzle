import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:star_puzzle/models/constellation.dart';
import 'package:star_puzzle/constellations/leo.dart';
import 'package:star_puzzle/constellations/sagittarius.dart';
import 'package:star_puzzle/models/constellation_progress.dart';

class ConstellationMeta {
  ConstellationMeta(this.constellation) : constellationAnimation = ConstellationAnimation.from(constellation);

  final Constellation constellation;
  ConstellationAnimation constellationAnimation;
  final bestMoves = RxnInt();
  final bestTime = RxnInt();
  final solved = false.obs;
  ui.Image? skyImage;

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
    return Future.wait(constellations.map((e) => e.loadSkyImage()));
  }

  @override
  void onClose() {
    for(var constellation in constellations){
      constellation.skyImage?.dispose();
    }

    super.onClose();
  }
}
