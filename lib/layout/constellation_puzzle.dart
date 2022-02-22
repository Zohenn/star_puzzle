import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:star_puzzle/layout/constellation_name.dart';
import 'package:star_puzzle/layout/constellation_puzzle_grid.dart';
import 'package:star_puzzle/painters.dart';
import 'package:star_puzzle/puzzle.dart';
import 'package:star_puzzle/services/base_service.dart';
import 'package:star_puzzle/services/constellation_service.dart';
import 'package:star_puzzle/size_mixin.dart';
import 'package:star_puzzle/layout/star_info.dart';
import 'package:star_puzzle/sky_map.dart';
import 'package:star_puzzle/star_path.dart';
import 'package:star_puzzle/utils.dart';
import 'package:star_puzzle/widgets/background_image_renderer.dart';

import 'package:star_puzzle/constellations/constellation.dart';
import 'package:touchable/touchable.dart';

class _ConstellationPuzzleController extends GetxController with GetTickerProviderStateMixin {
  _ConstellationPuzzleController(this.constellation);

  final ConstellationMeta constellation;
  final isSolving = false.obs;
  final puzzle = Rxn<Puzzle>();
  final moves = 0.obs;
  final elapsedSeconds = 0.obs;
  bool? firstSolve;
  Stopwatch? stopwatch;
  Timer? elapsedSecondsTimer;
  Ticker? ticker;
  final previousTime = 0.obs;
  final showName = false.obs;
  final selectedStar = Rxn<Star>();
  AnimationController? selectedStarAnimationController;

  final containerKey = GlobalKey();
  final gridKey = GlobalKey();

  ConstellationAnimation get constellationAnimation => constellation.constellationAnimation;

  String get elapsedTime => formatSeconds(elapsedSeconds());

  void initPuzzle() {
    // puzzle.value = Puzzle.generate(3);
    var list = [1, 2, 3, 4, 5, 6, 7, 9, 8];
    TilePosition numberToPosition(int i) {
      return TilePosition(i % 3, (i ~/ 3).toDouble());
    }

    var tiles = [
      for (var i = 0; i < 9; i++) Tile(numberToPosition(list[i] - 1), numberToPosition(i), list[i] == 9),
    ];
    puzzle.value = Puzzle(
      tiles,
    );
    moves.value = 0;
    elapsedSeconds.value = 0;
  }

  void startTimer() {
    stopwatch = Stopwatch()..start();
    elapsedSecondsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedSeconds.value = stopwatch!.elapsedMilliseconds ~/ 1000;
    });
  }

  void cancelPuzzle() {
    stopwatch?.stop();
    elapsedSecondsTimer?.cancel();
  }

  void startAnimation() {
    constellationAnimation.stars.first.shouldFill = true;
    ticker = Ticker((elapsed) {
      // constellationAnimation.skipForward();
      var finished = constellationAnimation.tick(elapsed.inMilliseconds - previousTime());
      previousTime.value = elapsed.inMilliseconds;
      if (finished) {
        ticker!.stop();
        constellation.loadImage();
        showName.value = true;
      }
    });
    ticker!.start();
    Get.find<BaseService>().solvingState.value = SolvingState.animating;
  }

  void onMove() {
    moves.value++;
  }

  void onComplete() {
    firstSolve = !constellation.solved();
    constellation.solved.value = true;
    stopwatch?.stop();
    elapsedSecondsTimer?.cancel();
    if (constellation.bestMoves() == null || moves() < constellation.bestMoves()!) {
      constellation.bestMoves.value = moves();
    }
    if (constellation.bestTime() == null || elapsedSeconds() < constellation.bestTime()!) {
      constellation.bestTime.value = elapsedSeconds();
    }
    Get.find<BaseService>().saveConstellationProgress(constellation);
    isSolving.value = false;
    if (firstSolve!) {
      startAnimation();
    } else {
      Get.find<BaseService>().solvingState.value = SolvingState.done;
    }
  }

  void _onStarTap(Star star) {
    selectedStar.value = selectedStar() == star ? null : star;
    if (selectedStar.value != null) {
      selectedStarAnimationController ??= AnimationController(vsync: this, duration: const Duration(seconds: 1));
      selectedStarAnimationController!.forward(from: 0);
      selectedStarAnimationController!.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          selectedStarAnimationController!.forward(from: 0);
        }
      });
    } else {
      selectedStarAnimationController!.reset();
    }
  }

  void Function(Star star)? get onStarTap {
    if (!constellation.solved() || Get.find<BaseService>().solvingState() != SolvingState.none) {
      return null;
    }

    return _onStarTap;
  }

  @override
  void onClose() {
    stopwatch?.stop();
    elapsedSecondsTimer?.cancel();
    ticker?.dispose();
    selectedStarAnimationController?.dispose();
    super.onClose();
  }
}

class ConstellationPuzzle extends StatelessWidget with SizeMixin {
  const ConstellationPuzzle({
    Key? key,
    required this.constellation,
  }) : super(key: key);

  final ConstellationMeta constellation;

  double get constellationIconBarHeight =>
      baseService.constellationIconPadding.along(Axis.vertical) + baseService.constellationIconSize.height;

  Widget getStateButton(_ConstellationPuzzleController controller, SolvingState solvingState) {
    switch (solvingState) {
      case SolvingState.none:
        return TextButton(
          key: const ValueKey('solve'),
          onPressed: () {
            if (!controller.isSolving()) {
              controller.initPuzzle();
            } else {
              controller.cancelPuzzle();
            }
            controller.isSolving.value = true;
            baseService.solvingState.value = SolvingState.solving;
          },
          child: const Text('Solve'),
        );
      case SolvingState.solving:
        return TextButton(
          key: const ValueKey('back'),
          onPressed: () {
            controller.cancelPuzzle();
            controller.isSolving.value = false;
            baseService.solvingState.value = SolvingState.none;
          },
          child: const Text('Go back'),
        );
      case SolvingState.animating:
        return const Opacity(
          opacity: 0,
          child: TextButton(
            onPressed: null,
            child: Text(''),
          ),
        );
      case SolvingState.done:
        return TextButton(
          key: const ValueKey('ok'),
          onPressed: () async {
            if (controller.firstSolve!) {
              await Get.dialog(SkyMap(revealConstellation: constellation), barrierDismissible: false);
            }
            baseService.solvingState.value = SolvingState.none;
          },
          child: const Text('Nice!'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<_ConstellationPuzzleController>(
      init: _ConstellationPuzzleController(constellation),
      tag: constellation.constellation.name,
      builder: (controller) => Stack(
        key: controller.containerKey,
        children: [
          Positioned.fill(
            child: BackgroundImageRenderer(
              constellation: constellation,
              containerKey: controller.containerKey,
              gridKey: controller.gridKey,
            ),
          ),
          Positioned.fill(
            child: Obx(
              () => AnimatedContainer(
                color: baseService.solvingState() == SolvingState.solving
                    ? Colors.white.withOpacity(0.12)
                    : Colors.transparent,
                duration: kThemeChangeDuration,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: constellationIconBarHeight,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Obx(
                      () => AnimatedSwitcher(
                        duration: kThemeChangeDuration,
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        child: baseService.solvingState() == SolvingState.none
                            ? Obx(
                                () => Opacity(
                                  opacity: constellation.solved() ? 1 : 0,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('FEWEST MOVES', style: Theme.of(context).textTheme.caption),
                                      Obx(
                                        () => Text(
                                          !constellation.solved()
                                              ? 'unavailable'
                                              : constellation.bestMoves().toString(),
                                          style: GoogleFonts.poppins(),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text('BEST TIME', style: Theme.of(context).textTheme.caption),
                                      Obx(
                                        () => Text(
                                          !constellation.solved()
                                              ? 'unavailable'
                                              : formatSeconds(constellation.bestTime()!).toString(),
                                          style: GoogleFonts.poppins(),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              )
                            : Obx(
                                () => AnimatedOpacity(
                                  opacity: baseService.solvingState() == SolvingState.animating ? 0 : 1,
                                  duration: kThemeChangeDuration,
                                  curve: Curves.easeInOut,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(minWidth: 94),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('MOVES', style: Theme.of(context).textTheme.caption),
                                        Obx(() => Text(controller.moves().toString(), style: GoogleFonts.poppins())),
                                        const SizedBox(height: 16),
                                        Text('TIME', style: Theme.of(context).textTheme.caption),
                                        Obx(() => Text(controller.elapsedTime, style: GoogleFonts.poppins())),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                          return Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            fit: StackFit.loose,
                            children: <Widget>[
                              ...previousChildren,
                              if (currentChild != null) currentChild,
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(
                          () => ConstellationName(
                            constellation: constellation,
                            animate: controller.showName(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox.fromSize(
                          key: controller.gridKey,
                          size: gridSize,
                          child: Obx(
                            () => AnimatedSwitcher(
                              duration: kThemeChangeDuration,
                              child: controller.isSolving()
                                  ? ConstrainedBox(
                                      constraints: BoxConstraints.tight(gridSize),
                                      child: Obx(
                                        () => ConstellationPuzzleGrid(
                                          puzzle: controller.puzzle(),
                                          constellation: constellation.constellation,
                                          onShuffleEnd: controller.startTimer,
                                          onMove: controller.onMove,
                                          onComplete: controller.onComplete,
                                        ),
                                      ),
                                    )
                                  : Obx(
                                      () {
                                        controller.previousTime();
                                        controller.selectedStar();
                                        constellation.solved();
                                        baseService.solvingState();
                                        return CanvasTouchDetector(
                                          builder: (context) => CustomPaint(
                                            painter: ConstellationAnimationPainter(
                                              context,
                                              constellation.constellationAnimation,
                                              1,
                                              starSize: constellation.constellation.starSize,
                                              onStarTap: controller.onStarTap,
                                              selectedStar: controller.selectedStar(),
                                              selectedStarAnimationController:
                                                  controller.selectedStarAnimationController,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                              layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                                return Stack(
                                  alignment: Alignment.center,
                                  fit: StackFit.passthrough,
                                  children: <Widget>[
                                    ...previousChildren,
                                    if (currentChild != null) currentChild,
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButtonTheme(
                          data: TextButtonThemeData(
                            style: Theme.of(context).textButtonTheme.style!.copyWith(
                                  textStyle: MaterialStateProperty.all(
                                      Theme.of(context).textTheme.button!.copyWith(fontSize: 18)),
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16)),
                                ),
                          ),
                          child: Obx(
                            () => AnimatedSwitcher(
                                duration: kThemeChangeDuration,
                                switchInCurve: Curves.easeInOut,
                                switchOutCurve: Curves.easeInOut,
                                child: getStateButton(controller, baseService.solvingState())),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => AnimatedSwitcher(
                      duration: kThemeChangeDuration,
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      child: constellation.solved() && baseService.solvingState() == SolvingState.none
                          ? Obx(() => StarInfo(star: controller.selectedStar()))
                          : const SizedBox.shrink(),
                      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                        return Stack(
                          alignment: Alignment.topLeft,
                          children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
