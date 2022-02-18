import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:star_puzzle/constellation.dart';
import 'package:star_puzzle/constellation_puzzle.dart';
import 'package:star_puzzle/services/constellation_service.dart';
import 'package:star_puzzle/utils.dart';
import 'package:star_puzzle/widgets/child_position_notifier.dart';

class _BackgroundImageRendererController extends GetxController {
  _BackgroundImageRendererController(this.constellation);

  final ConstellationMeta constellation;
  final position = Rxn<Offset>();
  final containerKey = GlobalKey();
}

class BackgroundImageRenderer extends StatelessWidget {
  const BackgroundImageRenderer({
    Key? key,
    required this.constellation,
    required this.gridSize,
    required this.containerKey,
    required this.gridKey,
  }) : super(key: key);

  final ConstellationMeta constellation;
  final Size gridSize;
  final GlobalKey containerKey;
  final GlobalKey gridKey;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<_BackgroundImageRendererController>(
      init: _BackgroundImageRendererController(constellation),
      global: false,
      builder: (controller) => Builder(builder: (context) {
        if (gridKey.currentContext == null) {
          WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {});
        }
        return ColoredBox(
          key: controller.containerKey,
          color: Colors.transparent,
          child: CustomPaint(
            painter: ConstellationSkyBackgroundPainter(
              constellation.skyImage,
              constellation.constellation.skyBoxOffset,
              constellation.constellation.skyBoxSize ?? Size(750, 750),
              MediaQuery.of(context),
              containerKey,
              gridKey,
            ),
          ),
        );
      }),
    );
  }
}

class ConstellationSkyBackgroundPainter extends CustomPainter {
  ConstellationSkyBackgroundPainter(
      this.image, this.boxOffset, this.boxSize, this.mqData, this.containerKey, this.gridKey);

  final ui.Image? image;
  final Offset boxOffset;
  final Size boxSize;
  final MediaQueryData mqData;
  final GlobalKey containerKey;
  final GlobalKey gridKey;

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null && gridKey.currentContext != null) {
      final context = gridKey.currentContext!;
      final box = context.findRenderObject() as RenderBox;
      final pos =
          box.localToGlobal(Offset.zero, ancestor: containerKey.currentContext!.findRenderObject() as RenderBox);
      final gridSize = box.size * mqData.devicePixelRatio;
      final scale = boxSize.width / gridSize.width;
      canvas.drawImageRect(
          image!,
          (boxOffset - pos * mqData.devicePixelRatio * scale) & (size * mqData.devicePixelRatio * scale),
          Offset.zero & size,
          Paint());
    }
  }

  @override
  bool shouldRepaint(covariant ConstellationSkyBackgroundPainter oldDelegate) {
    return true;
    // return oldDelegate.image != image;
  }
}
