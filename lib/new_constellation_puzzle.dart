import 'dart:math';

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
import 'package:star_puzzle/widgets/theme_provider.dart';

import 'package:star_puzzle/constellation.dart';

class _ConstellationPuzzleController extends GetxController with GetTickerProviderStateMixin {
  _ConstellationPuzzleController(this.constellation);

  final ConstellationMeta constellation;
  final isSolving = false.obs;
  final puzzle = Rxn<Puzzle>();
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

  ConstellationAnimation get constellationAnimation => constellation.constellationAnimation;

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
    starRotateAnimation = Tween(begin: 0.0, end: constellation.constellation.name.length * 0.3).animate(nameAnimationController!);
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
    nameAnimationController?.dispose();
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
                                          : (constellation.solved ? cornsilk : Colors.white60),
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
