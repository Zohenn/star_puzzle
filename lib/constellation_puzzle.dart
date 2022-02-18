import 'dart:async';
import 'dart:math';

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:star_puzzle/constellation_puzzle_grid.dart';
import 'package:star_puzzle/painters.dart';
import 'package:star_puzzle/puzzle.dart';
import 'package:star_puzzle/services/base_service.dart';
import 'package:star_puzzle/services/constellation_service.dart';
import 'package:star_puzzle/star_path.dart';
import 'package:star_puzzle/utils.dart';
import 'package:star_puzzle/widgets/background_image_renderer.dart';
import 'package:star_puzzle/widgets/child_position_notifier.dart';
import 'package:star_puzzle/widgets/theme_provider.dart';

import 'package:star_puzzle/constellation.dart';

class _ConstellationPuzzleController extends GetxController with GetTickerProviderStateMixin {
  _ConstellationPuzzleController(this.constellation);

  final ConstellationMeta constellation;
  final isSolving = false.obs;
  final puzzle = Rxn<Puzzle>();
  final moves = 0.obs;
  final elapsedSeconds = 0.obs;
  Stopwatch? stopwatch;
  Timer? elapsedSecondsTimer;
  Ticker? ticker;
  final previousTime = 0.obs;
  final isAnimatingConstellation = false.obs;
  AnimationController? nameAnimationController;
  Animation? nameAnimation;
  Animation? starLeaveAnimation;
  Animation? starEntryLeaveTranslateAnimation;
  Animation? starEntryLeaveScaleAnimation;
  Animation? starRotateAnimation;
  final showName = false.obs;

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
    elapsedSecondsTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      elapsedSeconds.value = stopwatch!.elapsedMilliseconds ~/ 1000;
    });
  }

  void cancelPuzzle() {
    stopwatch?.stop();
    elapsedSecondsTimer?.cancel();
  }

  void startAnimation() {
    final starEntryAnimationDuration = Duration(milliseconds: 300);
    final nameAnimationDuration = Duration(milliseconds: constellation.constellation.name.length * 100);
    final starLeaveAnimationDuration = Duration(milliseconds: 300);
    final fullNameAnimationDuration = starEntryAnimationDuration + nameAnimationDuration + starLeaveAnimationDuration;
    nameAnimationController = AnimationController(vsync: this, duration: fullNameAnimationDuration);
    starEntryLeaveTranslateAnimation = TweenSequence(
      [
        TweenSequenceItem(
          tween: Tween(begin: -1.0, end: 0.1),
          weight: starEntryAnimationDuration.inMilliseconds / fullNameAnimationDuration.inMilliseconds * 100,
        ),
        TweenSequenceItem(
          tween: ConstantTween(0.1),
          weight: nameAnimationDuration.inMilliseconds / fullNameAnimationDuration.inMilliseconds * 100,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 0.1, end: 1.0),
          weight: starLeaveAnimationDuration.inMilliseconds / fullNameAnimationDuration.inMilliseconds * 100,
        ),
      ],
    ).animate(nameAnimationController!);
    starEntryLeaveScaleAnimation = TweenSequence(
      [
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0),
          weight: starEntryAnimationDuration.inMilliseconds / fullNameAnimationDuration.inMilliseconds * 100,
        ),
        TweenSequenceItem(
          tween: ConstantTween(1.0),
          weight: nameAnimationDuration.inMilliseconds / fullNameAnimationDuration.inMilliseconds * 100,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0),
          weight: starLeaveAnimationDuration.inMilliseconds / fullNameAnimationDuration.inMilliseconds * 100,
        ),
      ],
    ).animate(nameAnimationController!);
    starRotateAnimation =
        Tween(begin: 0.0, end: constellation.constellation.name.length * 0.3).animate(nameAnimationController!);
    nameAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: nameAnimationController!,
        curve: Interval(
          starEntryAnimationDuration.inMilliseconds / fullNameAnimationDuration.inMilliseconds,
          (starEntryAnimationDuration.inMilliseconds + nameAnimationDuration.inMilliseconds) /
              fullNameAnimationDuration.inMilliseconds,
          curve: Curves.linear,
        ),
      ),
    );
    nameAnimationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onAnimationEnd();
      }
    });
    constellationAnimation.stars.first.shouldFill = true;
    ticker = Ticker((elapsed) {
      // constellationAnimation.skipForward();
      var finished = constellationAnimation.tick(elapsed.inMilliseconds - previousTime());
      previousTime.value = elapsed.inMilliseconds;
      if (finished) {
        ticker!.stop();
        constellation.loadImage();
        showName.value = true;
        nameAnimationController!.forward();
      }
    });
    ticker!.start();
    isAnimatingConstellation.value = true;
    Get.find<BaseService>().solvingState.value = SolvingState.animating;
  }

  void onAnimationEnd() {
    isAnimatingConstellation.value = false;
    Get.find<BaseService>().solvingState.value = SolvingState.done;
  }

  void onMove() {
    moves.value++;
  }

  void onComplete() {
    constellation.solved.value = true;
    stopwatch?.stop();
    elapsedSecondsTimer?.cancel();
    if (constellation.bestMoves() == null || moves() < constellation.bestMoves()!) {
      constellation.bestMoves.value = moves();
    }
    if (constellation.bestTime() == null || elapsedSeconds() < constellation.bestTime()!) {
      constellation.bestTime.value = elapsedSeconds();
    }
    isSolving.value = false;
    startAnimation();
  }

  @override
  void onClose() {
    stopwatch?.stop();
    elapsedSecondsTimer?.cancel();
    ticker?.dispose();
    nameAnimationController?.dispose();
    super.onClose();
  }
}

class ConstellationPuzzle extends StatelessWidget {
  ConstellationPuzzle({
    Key? key,
    required this.constellation,
    required this.gridSize,
  }) : super(key: key);

  final ConstellationMeta constellation;
  final Size gridSize;

  final baseService = Get.find<BaseService>();

  Widget getStateButton(_ConstellationPuzzleController controller, SolvingState solvingState) {
    switch (solvingState) {
      case SolvingState.none:
        return TextButton(
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
          onPressed: () => baseService.solvingState.value = SolvingState.none,
          child: const Text('Nice!'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<_ConstellationPuzzleController>(
      init: _ConstellationPuzzleController(constellation),
      global: false,
      builder: (controller) => Stack(
        key: controller.containerKey,
        children: [
          Positioned.fill(
            child: BackgroundImageRenderer(
              constellation: constellation,
              gridSize: gridSize,
              containerKey: controller.containerKey,
              gridKey: controller.gridKey,
            ),
          ),
          Positioned.fill(
            child: Obx(
              () => AnimatedContainer(
                color: baseService.solvingState() == SolvingState.solving ? Color(0x20ffffff) : Color(0x00ffffff),
                duration: kThemeChangeDuration,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24 * 2 + 96),
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
                                      SizedBox(height: 16),
                                      Text('BEST TIME', style: Theme.of(context).textTheme.caption),
                                      Obx(
                                        () => Text(
                                          !constellation.solved()
                                              ? 'unavailable'
                                              : formatSeconds(constellation.bestTime()!).toString(),
                                          style: GoogleFonts.poppins(),
                                        ),
                                      ),
                                      SizedBox(height: 16),
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
                                    constraints: BoxConstraints(minWidth: 94),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('MOVES', style: Theme.of(context).textTheme.caption),
                                        Obx(() => Text(controller.moves().toString(), style: GoogleFonts.poppins())),
                                        SizedBox(height: 16),
                                        Text('TIME', style: Theme.of(context).textTheme.caption),
                                        Obx(() => Text(controller.elapsedTime, style: GoogleFonts.poppins())),
                                        SizedBox(height: 16),
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
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(
                          () => controller.isAnimatingConstellation()
                              ? Stack(
                                  children: [
                                    Text(
                                      constellation.constellation.name,
                                      style: GoogleFonts.josefinSlab(
                                        textStyle: Theme.of(context).textTheme.headline4!.copyWith(
                                              color: Colors.transparent,
                                            ),
                                      ),
                                    ),
                                    Stack(
                                      fit: StackFit.passthrough,
                                      clipBehavior: Clip.none,
                                      children: [
                                        AnimatedBuilder(
                                          animation: controller.nameAnimation!,
                                          builder: (context, child) => ClipRect(
                                            child: ShaderMask(
                                              blendMode: BlendMode.srcIn,
                                              shaderCallback: (bounds) => LinearGradient(
                                                colors: [cornsilk, Colors.transparent],
                                                stops: [controller.nameAnimation!.value, 1],
                                              ).createShader(
                                                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                                              ),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                widthFactor: controller.nameAnimation!.value,
                                                child: Text(
                                                  constellation.constellation.name,
                                                  style: GoogleFonts.josefinSlab(
                                                    textStyle: Theme.of(context).textTheme.headline4!.copyWith(
                                                          color: cornsilk,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: LayoutBuilder(
                                              builder: (context, constraints) => AnimatedBuilder(
                                                animation: controller.nameAnimationController!,
                                                builder: (context, child) => Transform.translate(
                                                  offset: Offset(
                                                    constraints.maxWidth / 2 +
                                                        controller.starEntryLeaveTranslateAnimation!.value *
                                                            constraints.maxWidth *
                                                            2,
                                                    0,
                                                  ),
                                                  child: ClipRect(
                                                    child: Transform.scale(
                                                      scale: controller.starEntryLeaveScaleAnimation!.value,
                                                      child: child,
                                                    ),
                                                  ),
                                                ),
                                                child: AnimatedBuilder(
                                                  animation: controller.starRotateAnimation!,
                                                  builder: (context, child) => Transform.rotate(
                                                    angle: controller.starRotateAnimation!.value * 360 * pi / 180,
                                                    child: CustomPaint(
                                                      painter: StarPainter(),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Obx(
                                  () => AnimatedDefaultTextStyle(
                                    duration: kThemeChangeDuration,
                                    curve: Curves.easeInOut,
                                    style: GoogleFonts.josefinSlab(
                                      textStyle: Theme.of(context).textTheme.headline4!.copyWith(
                                            color: (controller.isSolving())
                                                ? Colors.transparent
                                                : (constellation.solved() ? cornsilk : Colors.white60),
                                          ),
                                    ),
                                    child: Text(
                                      constellation.solved() ? constellation.constellation.name : 'Unknown',
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(height: 16),
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
                                          gridSize: gridSize,
                                          onShuffleEnd: controller.startTimer,
                                          onMove: controller.onMove,
                                          onComplete: controller.onComplete,
                                        ),
                                      ),
                                    )
                                  : Obx(
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
                        SizedBox(height: 16),
                        // todo: make button impossible to tap when invisible
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
                const Expanded(
                  child: SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(getStarPath(size), Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
