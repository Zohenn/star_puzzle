import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_puzzle/views/constellation_puzzle/constellation_puzzle.dart';
import 'package:star_puzzle/views/constellation_puzzle/constellation_animation_painter.dart';
import 'package:star_puzzle/services/base_service.dart';
import 'package:star_puzzle/services/constellation_service.dart';
import 'package:star_puzzle/utils/size_mixin.dart';
import 'package:star_puzzle/views/info_dialog.dart';
import 'package:star_puzzle/views/sky_map.dart';
import 'package:star_puzzle/widgets/theme_provider.dart';

class _MainLayoutController extends GetxController {
  final selectedConstellation = Rxn<ConstellationMeta>();
  final constellationScrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();

    selectedConstellation.value = Get.find<ConstellationService>().constellations[0];
  }
}

class MainLayout extends StatelessWidget with SizeMixin {
  const MainLayout({Key? key}) : super(key: key);

  Size get constellationIconSize => baseService.constellationIconSize;

  EdgeInsets get constellationIconPadding => baseService.constellationIconPadding;

  List<ConstellationMeta> get constellations => Get.find<ConstellationService>().constellations;

  SolvingState get solvingState => baseService.solvingState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<_MainLayoutController>(
        init: _MainLayoutController(),
        builder: (controller) => DefaultTabController(
          length: constellations.length,
          initialIndex: constellations.indexOf(controller.selectedConstellation()!),
          child: Stack(
            children: [
              TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (var constellation in constellations)
                    ConstellationPuzzle(
                      constellation: constellation,
                    ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Obx(
                  () => AnimatedContainer(
                    duration: kThemeChangeDuration,
                    curve: Curves.easeInOut,
                    transform: Matrix4.translationValues(0, solvingState != SolvingState.none ? 96 + 2 * 24 : 0, 0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Card(
                            clipBehavior: Clip.hardEdge,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: EdgeInsets.zero,
                            color: Colors.transparent,
                            child: Stack(
                              children: [
                                SizedBox.fromSize(
                                  size: constellationIconSize,
                                  child: Image.asset(
                                    'assets/sky_map.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned.fill(
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: Builder(
                                      builder: (context) => InkWell(
                                        onTap: () async {
                                          final constellation = await Get.dialog<ConstellationMeta>(
                                              const SkyMap(openConstellationOnTap: true));
                                          if (constellation != null) {
                                            controller.selectedConstellation.value = constellation;
                                            DefaultTabController.of(context)!.index =
                                                constellations.indexOf(constellation);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Listener(
                            onPointerSignal: (event) {
                              if (event is PointerScrollEvent) {
                                final offset = event.scrollDelta.dy;
                                controller.constellationScrollController.jumpTo(
                                  controller.constellationScrollController.offset + constellationIconSize.width / 6 * offset.sign,
                                );
                              }
                            },
                            child: Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: constellationIconPadding,
                                controller: controller.constellationScrollController,
                                child: Row(
                                  children: [
                                    for (var constellation in constellations) ...[
                                      AnimatedContainer(
                                        duration: kThemeChangeDuration,
                                        curve: Curves.easeInOut,
                                        transform: Matrix4.translationValues(
                                            0, controller.selectedConstellation() == constellation ? -8 : 0, 0),
                                        child: Card(
                                          clipBehavior: Clip.hardEdge,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          margin: EdgeInsets.zero,
                                          color: Colors.transparent,
                                          elevation: controller.selectedConstellation() == constellation ? 4 : 0,
                                          child: Stack(
                                            children: [
                                              SizedBox.fromSize(
                                                size: constellationIconSize,
                                                child: ColoredBox(
                                                  color: Theme.of(context).backgroundColor,
                                                  child: RepaintBoundary(
                                                    child: CustomPaint(
                                                      isComplex: true,
                                                      painter: ConstellationAnimationPainter(
                                                          context, constellation.constellationAnimation, 0.3,
                                                          useCircles: true),
                                                    ),
                                                  ),
                                                ),
                                                // child: Obx(
                                                //   () => Image.memory(
                                                //     constellation.imageBytes()!,
                                                //     fit: BoxFit.cover,
                                                //   ),
                                                // ),
                                              ),
                                              Positioned.fill(
                                                child: AnimatedContainer(
                                                  duration: kThemeChangeDuration,
                                                  color: controller.selectedConstellation() == constellation
                                                      ? Colors.transparent
                                                      : Colors.white.withOpacity(0.1),
                                                ),
                                              ),
                                              Positioned.fill(
                                                child: Material(
                                                  type: MaterialType.transparency,
                                                  child: Builder(
                                                    builder: (context) => InkWell(
                                                      onTap: () {
                                                        controller.selectedConstellation.value = constellation;
                                                        DefaultTabController.of(context)!
                                                            .animateTo(constellations.indexOf(constellation));
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (constellation != constellations.last) const SizedBox(width: 16),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: SizedBox.fromSize(
                            size: constellationIconSize,
                            child: Material(
                              type: MaterialType.transparency,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: TextButton(
                                  child: Icon(Icons.info_outline, color: cornsilk),
                                  onPressed: () => Get.dialog(const InfoDialog()),
                                  style: Theme.of(context).textButtonTheme.style!.copyWith(
                                        padding: MaterialStateProperty.all(
                                          const EdgeInsets.all(12.0),
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
