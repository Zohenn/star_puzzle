import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:star_puzzle/constellation_puzzle_grid.dart';
import 'package:star_puzzle/painters.dart';
import 'package:star_puzzle/puzzle.dart';
import 'package:star_puzzle/services/base_service.dart';
import 'package:star_puzzle/services/constellation_service.dart';

import 'constellation.dart';

class _ConstellationPuzzleController extends GetxController {
  _ConstellationPuzzleController(this.constellation);

  final ConstellationMeta constellation;
  final isSolving = false.obs;
  final puzzle = Rxn<Puzzle>();
  Ticker? ticker;
  final previousTime = 0.obs;
  final isAnimatingConstellation = false.obs;
  final showName = false.obs;

  ConstellationAnimation get constellationAnimation => constellation.constellationAnimation;

  void startAnimation() {
    constellationAnimation.stars.first.shouldFill = true;
    ticker = Ticker((elapsed) {
      var finished = constellationAnimation.tick(elapsed.inMilliseconds - previousTime());
      previousTime.value = elapsed.inMilliseconds;
      if (finished) {
        ticker!.stop();
        constellation.loadImage();
        showName.value = true;
      }
    });
    ticker!.start();
    isAnimatingConstellation.value = true;
    Get.find<BaseService>().solvingState.value = SolvingState.animating;
  }

  void onAnimationEnd() {
    isAnimatingConstellation.value = false;
    Get.find<BaseService>().solvingState.value = SolvingState.none;
  }

  void onComplete() {
    constellation.solved = true;
    isSolving.value = false;
    startAnimation();
  }

  @override
  void onClose() {
    ticker?.dispose();
    super.onClose();
  }
}

class NewConstellationPuzzle extends StatelessWidget {
  NewConstellationPuzzle({
    Key? key,
    required this.constellation,
    required this.gridSize,
  }) : super(key: key);

  final ConstellationMeta constellation;
  final Size gridSize;

  final baseService = Get.find<BaseService>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<_ConstellationPuzzleController>(
      init: _ConstellationPuzzleController(constellation),
      global: false,
      builder: (controller) => Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Obx(
                () => AnimatedOpacity(
                  opacity: controller.isSolving() ? 1 : 0,
                  duration: kThemeChangeDuration,
                  curve: Curves.easeInOut,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MOVES', style: Theme.of(context).textTheme.caption),
                      Text('0'),
                      SizedBox(height: 16),
                      Text('TIME', style: Theme.of(context).textTheme.caption),
                      Text('0:00'),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                    () => controller.isAnimatingConstellation()
                        ? AnimatedDefaultTextStyle(
                            duration: kThemeChangeDuration * 3,
                            curve: Curves.easeInOut,
                            style: GoogleFonts.josefinSlab(
                              textStyle: Theme.of(context).textTheme.headline4!.copyWith(
                                    color: controller.showName() ? Colors.white : Colors.transparent,
                                  ),
                            ),
                            child: Text(
                              constellation.constellation.name,
                            ),
                            onEnd: controller.onAnimationEnd,
                          )
                        : Obx(
                            () => AnimatedDefaultTextStyle(
                              duration: kThemeChangeDuration,
                              curve: Curves.easeInOut,
                              style: GoogleFonts.josefinSlab(
                                textStyle: Theme.of(context).textTheme.headline4!.copyWith(
                                      color: (controller.isSolving())
                                          ? Colors.transparent
                                          : (constellation.solved ? Colors.white : Colors.white60),
                                    ),
                              ),
                              child: Text(
                                constellation.solved ? constellation.constellation.name : 'Unknown',
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 16),
                  SizedBox.fromSize(
                    size: gridSize,
                    child: Obx(
                      () => AnimatedCrossFade(
                        duration: kThemeChangeDuration,
                        crossFadeState: controller.isSolving() ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        firstChild: Obx(
                          () {
                            controller.previousTime();
                            return CustomPaint(
                              painter: ConstellationAnimationPainter(
                                constellation.constellationAnimation,
                                1,
                                starSize: constellation.constellation.starSize,
                              ),
                            );
                          },
                        ),
                        secondChild: ConstrainedBox(
                          constraints: BoxConstraints.tight(gridSize),
                          child: Obx(
                            () => ConstellationPuzzleGrid(
                              puzzle: controller.puzzle(),
                              constellation: constellation.constellation,
                              gridSize: gridSize,
                              onComplete: controller.onComplete,
                            ),
                          ),
                        ),
                        layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
                          return Stack(
                            clipBehavior: Clip.none,
                            fit: StackFit.passthrough,
                            children: <Widget>[
                              Positioned.fill(
                                key: bottomChildKey,
                                child: bottomChild,
                              ),
                              Positioned.fill(
                                key: topChildKey,
                                child: topChild,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // todo: make button impossible to tap when invisible
                  Obx(
                    () => AnimatedOpacity(
                      opacity: baseService.solvingState() != SolvingState.none ? 0 : 1,
                      curve: Curves.easeInOut,
                      duration: kThemeChangeDuration,
                      child: TextButton(
                        onPressed: () {
                          if (!controller.isSolving()) {
                            // controller.puzzle.value = Puzzle.generate(3);
                            var list = [1, 2, 3, 4, 5, 6, 7, 9, 8];
                            TilePosition numberToPosition(int i) {
                              return TilePosition(i % 3, (i ~/ 3).toDouble());
                            }

                            var tiles = [
                              for (var i = 0; i < 9; i++)
                                Tile(numberToPosition(list[i] - 1), numberToPosition(i), list[i] == 9),
                            ];
                            controller.puzzle.value = Puzzle(
                              tiles,
                            );
                            // controller.puzzle.value = Puzzle([
                            //   for (var j = 0.0; j < 3; j++)
                            //     for (var i = 0.0; i < 3; i++)
                            //       Tile(TilePosition(i, j), TilePosition(i, j), i == 2 && j == 2),
                            // ]);
                          }
                          controller.isSolving.value = !controller.isSolving();
                          baseService.solvingState.value =
                              controller.isSolving() ? SolvingState.solving : SolvingState.none;
                        },
                        child: Text('Solve'),
                        style: ButtonStyle(
                          textStyle:
                              MaterialStateProperty.all(Theme.of(context).textTheme.button!.copyWith(fontSize: 18)),
                          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 8, horizontal: 16)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
