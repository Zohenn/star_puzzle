import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_puzzle/constellation.dart';
import 'package:star_puzzle/puzzle.dart';
import 'package:star_puzzle/services/base_service.dart';
import 'package:star_puzzle/star_path.dart';
import 'package:star_puzzle/utils.dart';

final _shuffleAnimationDuration = Duration(milliseconds: 500);

class _ConstellationPuzzleGridController extends GetxController with GetTickerProviderStateMixin {
  _ConstellationPuzzleGridController(this.puzzle) {
    shuffleAnimationController =
        AnimationController(vsync: this, duration: kThemeChangeDuration + _shuffleAnimationDuration);
    for (var tile in puzzle.tiles) {
      shuffleAnimations[tile.number] = tile.originalPositionTween.animate(
        CurvedAnimation(
          parent: shuffleAnimationController,
          curve: Interval(
            kThemeChangeDuration.inMilliseconds / shuffleAnimationController.duration!.inMilliseconds,
            1,
            curve: Curves.easeInOut,
          ),
        ),
      );
      final animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 150));
      animationControllers[tile.number] = animationController;
      animations[tile.number] = animatePosition(tile.positionTween, animationController);
    }

    shuffleAnimationController.forward();
  }

  final Puzzle puzzle;
  late AnimationController shuffleAnimationController;
  final shuffleAnimations = <int, Animation<TilePosition>>{};
  final animationControllers = <int, AnimationController>{};
  final animations = <int, Animation<TilePosition>>{};

  Animation<TilePosition> animatePosition(TilePositionTween tween, AnimationController controller) {
    return tween.animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  void onClose() {
    print('disposed');
    shuffleAnimationController.dispose();
    animationControllers.forEach((key, value) {
      value.dispose();
    });
    super.onClose();
  }
}

class ConstellationPuzzleGrid extends StatelessWidget {
  const ConstellationPuzzleGrid({
    Key? key,
    required this.puzzle,
    required this.constellation,
    required this.gridSize,
  }) : super(key: key);

  final Puzzle? puzzle;
  final Constellation constellation;
  final Size gridSize;

  Size get tileSize => gridSize / 3;

  @override
  Widget build(BuildContext context) {
    if (puzzle == null) {
      return SizedBox.shrink();
    }
    return GetBuilder<_ConstellationPuzzleGridController>(
      init: _ConstellationPuzzleGridController(puzzle!),
      global: false,
      didUpdateWidget: (oldWidget, state) {
        if((oldWidget as GetBuilder<_ConstellationPuzzleGridController>).init!.puzzle != puzzle){
          state.controller = state.widget.init;
          state.controller?.onStart();
        }
      },
      builder: (controller) => Stack(
        fit: StackFit.expand,
        children: [
          for (var tile in puzzle!.tiles)
            AnimatedBuilder(
              animation: controller.shuffleAnimationController.isAnimating
                  ? controller.shuffleAnimations[tile.number]!
                  : controller.animations[tile.number]!,
              builder: (context, child) {
                final position = controller.shuffleAnimationController.isAnimating
                    ? controller.shuffleAnimations[tile.number]!.value
                    : controller.animations[tile.number]!.value;
                return Positioned(
                  left: position.x * tileSize.width,
                  top: position.y * tileSize.height,
                  child: child!,
                );
              },
              child: NewPuzzleTile(
                tile: tile,
                gridSize: gridSize,
                tileSize: tileSize,
                onTap: () {
                  if (!puzzle!.canMoveTile(tile) ||
                      controller.shuffleAnimationController.isAnimating ||
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
                },
                complete: false,
                constellation: constellation,
              ),
            ),
        ],
      ),
    );
  }
}

class NewPuzzleTile extends StatelessWidget {
  const NewPuzzleTile({
    Key? key,
    required this.tile,
    required this.gridSize,
    required this.tileSize,
    required this.onTap,
    required this.complete,
    required this.constellation,
  }) : super(key: key);

  final Tile tile;
  final Size gridSize;
  final Size tileSize;
  final VoidCallback onTap;
  final bool complete;
  final Constellation constellation;

  @override
  Widget build(BuildContext context) {
    if (tile.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: tileSize.width,
      height: tileSize.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.all(1.0),
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: NewPiecePainter(
            Get.find<BaseService>().backgroundImage,
            tile.originalPosition.x.toInt(),
            tile.originalPosition.y.toInt(),
            gridSize,
            constellation,
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: AnimatedDefaultTextStyle(
                child: Text('${tile.number}'),
                style: TextStyle(color: complete ? Colors.transparent : Colors.white.withOpacity(0.2)),
                duration: Duration(milliseconds: 500),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NewPiecePainter extends CustomPainter {
  NewPiecePainter(
    this.image,
    this.i,
    this.j,
    this.gridSize,
    this.constellation,
  );

  ui.Image? image;
  int i;
  int j;
  Size gridSize;
  Constellation constellation;

  Size get starPathSize => constellation.starSize != null ? Size.square(constellation.starSize!) : Size.square(12);

  Size get tileSize => gridSize / 3;

  @override
  void paint(Canvas canvas, Size size) {
    final Size paddingSize = Size(tileSize.width - size.width, tileSize.height - size.height);
    if (image != null) {
      canvas.drawRect(Offset.zero & size, Paint()..color = Color(0xff081229));
      final starPaint = Paint()..color = Colors.white;
      for (var star in constellation.stars) {
        final starPath = getStarPath(starPathSize).shift(
          star.pos.toOffset(gridSize) -
              sizeToOffset(starPathSize) / 2 -
              Offset(tileSize.width * i, tileSize.height * j) -
              (sizeToOffset(paddingSize) / 2),
        );
        canvas.drawPath(starPath, starPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
