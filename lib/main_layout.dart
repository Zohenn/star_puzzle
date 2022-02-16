import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_puzzle/constellation_puzzle.dart';
import 'package:star_puzzle/services/base_service.dart';
import 'package:star_puzzle/services/constellation_service.dart';

class _MainLayoutController extends GetxController {
  final selectedConstellation = Rxn<ConstellationMeta>();

  @override
  void onInit() {
    super.onInit();

    selectedConstellation.value = Get.find<ConstellationService>().constellations.first;
  }
}

class MainLayout extends StatelessWidget {
  MainLayout({Key? key}) : super(key: key);

  final gridSize = Size(300, 300);
  final size = 3;

  List<ConstellationMeta> get constellations => Get.find<ConstellationService>().constellations;

  SolvingState get solvingState => Get.find<BaseService>().solvingState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: constellations.length,
        initialIndex: 0,
        child: GetBuilder<_MainLayoutController>(
          init: _MainLayoutController(),
          global: false,
          builder: (controller) => Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/night_sky.jpg',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
              Positioned.fill(
                child: Obx(
                  () => AnimatedContainer(
                    color: solvingState == SolvingState.solving ? Color(0x20ffffff) : Color(0x00ffffff),
                    duration: kThemeChangeDuration,
                  ),
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (var constellation in constellations)
                          ConstellationPuzzle(
                            constellation: constellation,
                            gridSize: gridSize,
                          ),
                      ],
                    ),
                  ),
                  Obx(
                    () => AnimatedContainer(
                      duration: kThemeChangeDuration,
                      curve: Curves.easeInOut,
                      transform: Matrix4.translationValues(0, solvingState != SolvingState.none ? 96 + 2 * 24 : 0, 0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(vertical: 24),
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
                                      SizedBox.square(
                                        dimension: 96,
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
