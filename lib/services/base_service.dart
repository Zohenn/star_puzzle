import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:star_puzzle/services/constellation_service.dart';

enum SolvingState {
  none,
  solving,
  animating,
  done,
}

class BaseService extends GetxService {
  late Future initFuture;
  ui.Image? backgroundImage;
  final solvingState = SolvingState.none.obs;

  final size = 3;
  final gridSize = const Size.square(300);
  Size get tileSize => gridSize / size.toDouble();

  final constellationIconSize = const Size.square(96);
  final constellationIconPadding = const EdgeInsets.symmetric(vertical: 24.0);

  @override
  void onInit() {
    super.onInit();

    initFuture = init();
  }

  Future init() async {
    await precacheImage(AssetImage('assets/night_sky.jpg'), Get.context!);
    // ByteData bd = await rootBundle.load('assets/night_sky.jpg');
    //
    // final Uint8List bytes = Uint8List.view(bd.buffer);
    // final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    // backgroundImage = (await codec.getNextFrame()).image;
    // codec.dispose();

    await Get.put(ConstellationService()).initFuture;
  }
}