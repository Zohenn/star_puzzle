import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_puzzle/services/constellation_service.dart';
import 'package:star_puzzle/widgets/theme_provider.dart';

class _SkyMapController extends GetxController with GetTickerProviderStateMixin {
  final showBoundaries = false.obs;
  AnimationController? animationController;

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(vsync: this, duration: 500.milliseconds);
  }

  void animate() {
    animationController!.forward(from: 0);
  }

  @override
  void onClose() {
    animationController?.dispose();
    super.onClose();
  }
}

class SkyMap extends StatelessWidget {
  const SkyMap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<_SkyMapController>(
      init: _SkyMapController(),
      global: false,
      builder: (controller) => Dialog(
        clipBehavior: Clip.hardEdge,
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: AspectRatio(
          aspectRatio: 3660 / 2160,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/sky_map.jpg',
                fit: BoxFit.contain,
              ),
              Obx(
                () => CustomPaint(
                  painter: SkyMapConstellationPainter(
                    showBoundaries: controller.showBoundaries(),
                    animationController: controller.animationController!,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => controller.showBoundaries.value = !controller.showBoundaries(),
                      child: Text('text'),
                    ),
                    TextButton(
                      onPressed: () => controller.animate(),
                      child: Text('animate'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SkyMapConstellationPainter extends CustomPainter {
  SkyMapConstellationPainter({
    required this.showBoundaries,
    required this.animationController,
  }) : super(repaint: animationController);

  final bool showBoundaries;
  final AnimationController animationController;

  @override
  void paint(Canvas canvas, Size size) {
    final constellations = Get.find<ConstellationService>().constellations;

    // canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white.withOpacity(0.2));
    Path? firstBoundariesPath;

    for (var constellation in constellations) {
      var boundaries = constellation.constellation.boundaries;
      if (boundaries != null) {
        final boundariesPath = Path();
        final beginningOffset = boundaries.first.toOffset(size);
        boundariesPath.moveTo(beginningOffset.dx, beginningOffset.dy);
        for (var position in boundaries.skip(1)) {
          final offset = position.toOffset(size);
          boundariesPath.lineTo(offset.dx, offset.dy);
        }
        boundariesPath.close();
        // boundariesPath.addRect(boundariesPath.getBounds().topLeft & Size(boundariesPath.getBounds().size.width / 2, boundariesPath.getBounds().size.height));
        final revealBoxWidth = constellation == constellations.first ? animationController.value : 1;
        canvas.drawPath(
          Path.combine(
              PathOperation.difference,
              boundariesPath,
              Path()
                ..addRect(boundariesPath.getBounds().topLeft &
                    Size(boundariesPath.getBounds().size.width * revealBoxWidth,
                        boundariesPath.getBounds().size.height))),
          Paint()
            ..style = PaintingStyle.fill
            ..color = Colors.black,
        );
        canvas.drawPath(
          boundariesPath,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = cornsilk.withOpacity(0.4),
        );

        if (constellation == constellations.first) {
          firstBoundariesPath = boundariesPath;
        }
      }
    }

    final backgroundPath = Path()..fillType = PathFillType.evenOdd;
    backgroundPath.addRect(Offset.zero & size);
    backgroundPath.addPath(firstBoundariesPath!, Offset.zero);
    canvas.drawPath(backgroundPath, Paint()..color = Colors.white.withOpacity(0.2));
  }

  @override
  bool shouldRepaint(covariant SkyMapConstellationPainter oldDelegate) => false;
}
