import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_puzzle/models/constellation.dart';
import 'package:star_puzzle/models/puzzle.dart';
import 'package:star_puzzle/services/constellation_service.dart';
import 'package:star_puzzle/utils/size_mixin.dart';
import 'package:star_puzzle/utils/star_path.dart';
import 'package:star_puzzle/utils/utils.dart';

const _shuffleAnimationDuration = Duration(milliseconds: 500);
const _moveAnimationDuration = Duration(milliseconds: 150);

class _ConstellationPuzzleGridController extends GetxController with GetTickerProviderStateMixin {
  _ConstellationPuzzleGridController(this.puzzle, this.onShuffleEnd, this.onComplete) {
    shuffleAnimationController =
        AnimationController(vsync: this, duration: kThemeChangeDuration * 3 + _shuffleAnimationDuration);
    for (var tile in puzzle.tiles) {
      shuffleAnimations[tile.number] = tile.originalPositionTween.animate(
        CurvedAnimation(
          parent: shuffleAnimationController,
          curve: Interval(
            kThemeChangeDuration.inMilliseconds * 2 / shuffleAnimationController.duration!.inMilliseconds,
            1,
            curve: Curves.easeInOut,
          ),
        ),
      );
      final animationController = AnimationController(vsync: this, duration: _moveAnimationDuration);
      animationController.addStatusListener(((status) {
        if (status == AnimationStatus.completed && puzzle.complete && !complete()) {
          complete.value = true;
          onComplete();
        }
      }));
      animationControllers[tile.number] = animationController;
      animations[tile.number] = animatePosition(tile.positionTween, animationController);
    }

    shuffleAnimationController.addStatusListener((status) {
      shuffleAnimationFinished.value = status == AnimationStatus.completed;
      if (shuffleAnimationFinished()) {
        onShuffleEnd();
      }
    });
    shuffleAnimationController.forward();
  }

  final Puzzle puzzle;
  final VoidCallback onShuffleEnd;
  final VoidCallback onComplete;

  late AnimationController shuffleAnimationController;
  final shuffleAnimations = <int, Animation<TilePosition>>{};
  final shuffleAnimationFinished = false.obs;
  final animationControllers = <int, AnimationController>{};
  final animations = <int, Animation<TilePosition>>{};
  final containerKey = GlobalKey();
  /// For some reason status listener sometimes gets called more than once on animation end,
  /// hence this variable is needed.
  final complete = false.obs;

  Animation<TilePosition> animatePosition(TilePositionTween tween, AnimationController controller) {
    return tween.animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  void onClose() {
    shuffleAnimationController.dispose();
    animationControllers.forEach((key, value) {
      value.dispose();
    });
    super.onClose();
  }
}

class ConstellationPuzzleGrid extends StatelessWidget with SizeMixin {
  const ConstellationPuzzleGrid({
    Key? key,
    required this.puzzle,
    required this.constellation,
    required this.onShuffleEnd,
    required this.onMove,
    required this.onComplete,
  }) : super(key: key);

  final Puzzle? puzzle;
  final Constellation constellation;
  final VoidCallback onShuffleEnd;
  final VoidCallback onMove;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    if (puzzle == null) {
      return const SizedBox.shrink();
    }
    return GetBuilder<_ConstellationPuzzleGridController>(
      init: _ConstellationPuzzleGridController(puzzle!, onShuffleEnd, onComplete),
      tag: constellation.name,
      builder: (controller) => Obx(
        () => Stack(
          key: controller.containerKey,
          fit: StackFit.expand,
          children: [
            for (var tile in puzzle!.tiles)
              AnimatedBuilder(
                animation: !controller.shuffleAnimationFinished()
                    ? controller.shuffleAnimations[tile.number]!
                    : controller.animations[tile.number]!,
                builder: (context, child) {
                  final position = !controller.shuffleAnimationFinished()
                      ? controller.shuffleAnimations[tile.number]!.value
                      : controller.animations[tile.number]!.value;
                  return Positioned(
                    left: position.x * tileSize.width,
                    top: position.y * tileSize.height,
                    child: child!,
                  );
                },
                child: PuzzleTile(
                  tile: tile,
                  onTap: () {
                    if (controller.complete() ||
                        !puzzle!.canMoveTile(tile) ||
                        !controller.shuffleAnimationFinished() ||
                        controller.animationControllers.values.any((element) => element.isAnimating)) {
                      return;
                    }
                    final updatedTiles = puzzle!.moveTile(tile);
                    for (var tile in updatedTiles) {
                      final animationController = controller.animationControllers[tile.number]!;
                      controller.animations[tile.number] =
                          controller.animatePosition(tile.positionTween, animationController);
                      animationController.reset();
                      animationController.forward();
                    }
                    onMove();
                  },
                  complete: controller.complete(),
                  constellation: constellation,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PuzzleTile extends StatelessWidget with SizeMixin {
  const PuzzleTile({
    Key? key,
    required this.tile,
    required this.onTap,
    required this.complete,
    required this.constellation,
  }) : super(key: key);

  final Tile tile;
  final VoidCallback onTap;
  final bool complete;
  final Constellation constellation;

  @override
  Widget build(BuildContext context) {
    if (tile.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      width: tileSize.width,
      height: tileSize.height,
      decoration: BoxDecoration(
        borderRadius: complete ? BorderRadius.zero : BorderRadius.circular(8),
      ),
      clipBehavior: Clip.hardEdge,
      padding: complete ? EdgeInsets.zero : const EdgeInsets.all(1.0),
      duration: kThemeChangeDuration,
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: TilePainter(
            Get.find<ConstellationService>()
                .constellations
                .firstWhere((element) => element.constellation == constellation)
                .skyImage!,
            tile.originalPosition,
            constellation,
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: AnimatedDefaultTextStyle(
                child: Text('${tile.number}'),
                style: TextStyle(color: complete ? Colors.transparent : Colors.white.withOpacity(0.2)),
                duration: kThemeChangeDuration,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TilePainter extends CustomPainter with SizeMixin {
  TilePainter(
    this.image,
    this.position,
    this.constellation,
  );

  ui.Image image;
  TilePosition position;
  Constellation constellation;

  Size get starPathSize =>
      constellation.starSize != null ? Size.square(constellation.starSize!) : const Size.square(12);

  @override
  void paint(Canvas canvas, Size size) {
    final x = position.x.toInt(), y = position.y.toInt();
    final containerKey = Get.find<_ConstellationPuzzleGridController>(tag: constellation.name).containerKey;

    final Size paddingSize = Size(tileSize.width - size.width, tileSize.height - size.height);

    final context = containerKey.currentContext!;
    final box = context.findRenderObject() as RenderBox;
    final mqData = MediaQuery.of(context);
    final pos = box.localToGlobal(Offset.zero);
    final tilePos = pos + Offset(x * tileSize.width, y * tileSize.height) + sizeToOffset(paddingSize / 2);
    final _gridSize = box.size * mqData.devicePixelRatio;
    final scale = constellation.skyBoxSize.width / _gridSize.width;
    final boxFitOffset = constellation.skyBoxOffset - pos * mqData.devicePixelRatio * scale;
    final tileImageSize = (size * mqData.devicePixelRatio * scale);
    final tileImageOffset = (boxFitOffset + (tilePos * mqData.devicePixelRatio * scale));

    canvas.drawImageRect(
      image,
      tileImageOffset & tileImageSize,
      Offset.zero & size,
      Paint(),
    );

    final starPaint = Paint()..color = Colors.white;
    for (var star in constellation.stars) {
      final starPath = getStarPath(starPathSize).shift(
        star.pos.toOffset(gridSize) -
            sizeToOffset(starPathSize) / 2 -
            Offset(tileSize.width * x, tileSize.height * y) -
            (sizeToOffset(paddingSize) / 2),
      );
      canvas.drawPath(starPath, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
