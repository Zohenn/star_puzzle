import 'package:flutter/material.dart';

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
