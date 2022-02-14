import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:star_puzzle/services/constellation_service.dart';

class BaseService extends GetxService {
  late Future bootstrapFuture;
  final containerKey = GlobalKey();
  ui.Image? backgroundImage;

  @override
  void onInit() {
    super.onInit();

    bootstrapFuture = init();
  }

  Future init() async {
    await precacheImage(AssetImage('assets/night_sky.jpg'), Get.context!);
    ByteData bd = await rootBundle.load('assets/night_sky.jpg');

    final Uint8List bytes = Uint8List.view(bd.buffer);
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    backgroundImage = (await codec.getNextFrame()).image;
    codec.dispose();

    await Get.put(ConstellationService(containerKey)).initFuture;
  }
}