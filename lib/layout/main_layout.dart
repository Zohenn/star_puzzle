import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_puzzle/layout/constellation_puzzle.dart';
import 'package:star_puzzle/services/base_service.dart';
import 'package:star_puzzle/services/constellation_service.dart';
import 'package:star_puzzle/size_mixin.dart';

class _MainLayoutController extends GetxController {
  final selectedConstellation = Rxn<ConstellationMeta>();

  @override
  void onInit() {
    super.onInit();

    selectedConstellation.value = Get.find<ConstellationService>().constellations[0];
    for (var constellation in Get.find<ConstellationService>().constellations) {
      constellation.solved.value = true;
      constellation.bestMoves.value = 1;
      constellation.bestTime.value = 0;
      constellation.constellationAnimation.skipForward();
    }
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
        global: false,
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
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: constellationIconPadding,
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
                                        child: Obx(
                                          () => Image.memory(
                                            constellation.imageBytes()!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
