import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_puzzle/services/constellation_service.dart';
import 'package:star_puzzle/widgets/theme_provider.dart';
import 'package:touchable/touchable.dart';

class _SkyMapController extends GetxController with GetTickerProviderStateMixin {
  _SkyMapController(this.revealConstellation);

  final ConstellationMeta? revealConstellation;
  AnimationController? animationController;
  TransformationController? transformationController;
  final mousePosition = Rxn<Offset>();

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(vsync: this, duration: 1.seconds);

    if (revealConstellation != null) {
      animationController!.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(1.seconds, () {
            if (Get.isDialogOpen!) {
              Get.back();
            }
          });
        }
      });
      Future.delayed(500.milliseconds, () {
        animate();
      });

      if(Get.size.width <= 700){
        const double scale = 2.5;
        final width = (Get.size.width - 2 * 40);
        final height = width / (3660 / 2160);
        final boundaries = revealConstellation!.constellation.boundaries!;
        double minX = 1, minY = 1;
        double maxX = 0, maxY = 0;
        for(var point in boundaries){
          if(point.x < minX){
            minX = point.x;
          }else if(point.x > maxX){
            maxX = point.x;
          }

          if(point.y < minY){
            minY = point.y;
          } else if(point.y > maxY){
            maxY = point.y;
          }
        }
        final boundaryWidth = (maxX - minX) * width;
        final boundaryHeight = (maxY - minY) * height;
        final offsetX = minX * width - (width / 2) / scale + boundaryWidth / 2;
        final offsetY = minY * height - (height / 2) / scale + boundaryHeight / 2;
        final translateX = -(max(0.0, min(offsetX * scale, width * scale - width)));
        final translateY = -(max(0.0, min(offsetY * scale, height * scale - height)));
        print('$width $height $translateX $translateY');
        // print('${width * scale} ${height * scale} ${translateX * scale} ${translateY * scale}');
        transformationController = TransformationController(Matrix4.diagonal3Values(scale, scale, 1)..setTranslationRaw(translateX, translateY, 0));
      }
    }
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
  const SkyMap({
    Key? key,
    this.revealConstellation,
    this.openConstellationOnTap = false,
  }) : super(key: key);

  final ConstellationMeta? revealConstellation;
  final bool openConstellationOnTap;

  void _onConstellationTap(ConstellationMeta constellationMeta) {
    if (constellationMeta.solved()) {
      Get.back(result: constellationMeta);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<_SkyMapController>(
      init: _SkyMapController(revealConstellation),
      builder: (controller) => Dialog(
        clipBehavior: Clip.hardEdge,
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            InteractiveViewer(
              transformationController: controller.transformationController,
              child: AspectRatio(
                aspectRatio: 3660 / 2160,
                child: MouseRegion(
                  onHover: (hoverEvent) => controller.mousePosition.value = hoverEvent.localPosition,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/sky_map.jpg',
                        fit: BoxFit.contain,
                      ),
                      Obx(
                        () {
                          controller.mousePosition();
                          return CanvasTouchDetector(
                            builder: (context) => CustomPaint(
                              painter: SkyMapConstellationPainter(
                                context: context,
                                revealConstellation: revealConstellation,
                                animationController: controller.animationController!,
                                onConstellationTap: openConstellationOnTap ? _onConstellationTap : null,
                                mousePosition: controller.mousePosition(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  'Use scroll to zoom and RMB to pan',
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkyMapConstellationPainter extends CustomPainter {
  SkyMapConstellationPainter({
    required this.context,
    this.revealConstellation,
    required this.animationController,
    this.onConstellationTap,
    this.mousePosition,
  }) : super(repaint: animationController);

  final BuildContext context;
  final ConstellationMeta? revealConstellation;
  final AnimationController animationController;
  final void Function(ConstellationMeta)? onConstellationTap;
  final Offset? mousePosition;

  @override
  void paint(Canvas _canvas, Size size) {
    final canvas = TouchyCanvas(context, _canvas);
    final constellations = Get.find<ConstellationService>().constellations;

    Path? revealBoundariesPath;

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
        final revealBoxWidth =
            constellation == revealConstellation ? animationController.value : (constellation.solved() ? 1 : 0);
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
          onTapDown: (details) {
            onConstellationTap?.call(constellation);
          },
          paintStyleForTouch: PaintingStyle.fill,
        );

        if (constellation == revealConstellation) {
          revealBoundariesPath = boundariesPath;
        }

        if (constellation.solved() && revealConstellation == null && mousePosition != null) {
          if (boundariesPath.contains(mousePosition!)) {
            canvas.drawPath(
              boundariesPath,
              Paint()
                ..style = PaintingStyle.fill
                ..color = Colors.white.withOpacity(0.2),
              onTapDown: (details) {
                onConstellationTap?.call(constellation);
              },
            );
          }
        }
      }
    }

    if (revealBoundariesPath != null) {
      final backgroundPath = Path()..fillType = PathFillType.evenOdd;
      backgroundPath.addRect(Offset.zero & size);
      backgroundPath.addPath(revealBoundariesPath, Offset.zero);
      canvas.drawPath(backgroundPath, Paint()..color = Colors.white.withOpacity(0.2));
    }
  }

  @override
  bool shouldRepaint(covariant SkyMapConstellationPainter oldDelegate) {
    return mousePosition != oldDelegate.mousePosition;
  }
}
