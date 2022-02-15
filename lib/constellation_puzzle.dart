import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:star_puzzle/painters.dart';
import 'package:star_puzzle/puzzle.dart';

class ConstellationPuzzle extends StatelessWidget {
  const ConstellationPuzzle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox.fromSize(
              key: containerKey,
              size: gridSize,
              child: showAnimation
                  ? CustomPaint(
                painter: ConstellationAnimationPainter(constellationAnimation, 1),
              )
                  : Stack(
                children: [
                  for (var tile in puzzle.tiles)
                    AnimatedBuilder(
                      animation: animations[tile.number]!,
                      builder: (context, child) {
                        final position = animations[tile.number]!.value;
                        return Positioned(
                          left: position.x * tileSize.width,
                          top: position.y * tileSize.height,
                          child: child!,
                        );
                      },
                      child: PuzzleTile(
                        tile: tile,
                        tileSize: tileSize,
                        onTap: () {
                          if (!puzzle.canMoveTile(tile) ||
                              animationControllers.values.any((element) => element.isAnimating)) {
                            return;
                          }
                          final updatedTiles = puzzle.moveTile(tile);
                          for (var tile in updatedTiles) {
                            final animationController = animationControllers[tile.number]!;
                            animations[tile.number] =
                                animatePosition(tile.positionTween, animationController);
                            animationController.reset();
                            animationController.forward();
                          }
                        },
                        renderedImage: renderedImage,
                        complete: complete,
                      ),
                    ),
                ],
              ),
            ),
            // SizedBox(height: 16),
            // // TextButton(onPressed: () => loadImage(), child: Text('Reload image')),
            // TextButton(
            //   onPressed: () => setState(() {
            //     complete = !complete;
            //     for (var tile in puzzle.tiles) {
            //       tile.currentPosition = tile.originalPosition.copy();
            //       final animationController = animationControllers[tile.number]!;
            //       animations[tile.number] =
            //           animatePosition(tile.positionTween, animationController);
            //       animationController.value = 1.0;
            //     }
            //     setState(() {});
            //     Future.delayed(Duration(milliseconds: 600), () {
            //       setState(() {
            //         showAnimation = complete;
            //         startAnimation();
            //       });
            //     });
            //   }),
            //   child: Text('Complete'),
            // ),
          ],
        ),
      ),
    );
  }
}

class PuzzleTile extends StatelessWidget {
  const PuzzleTile({
    Key? key,
    required this.tile,
    required this.tileSize,
    required this.onTap,
    required this.renderedImage,
    required this.complete,
  }) : super(key: key);

  final Tile tile;
  final Size tileSize;
  final VoidCallback onTap;
  final ui.Image? renderedImage;
  final bool complete;

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
          painter: PiecePainter(
            renderedImage,
            tile.originalPosition.x.toInt(),
            tile.originalPosition.y.toInt(),
            tileSize,
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