import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:star_puzzle/constellation_puzzle_grid.dart';
import 'package:star_puzzle/painters.dart';
import 'package:star_puzzle/puzzle.dart';
import 'package:star_puzzle/services/constellation_service.dart';

class _ConstellationPuzzleController extends GetxController {
  final isSolving = false.obs;
  final puzzle = Rxn<Puzzle>();
}

class NewConstellationPuzzle extends StatelessWidget {
  const NewConstellationPuzzle({
    Key? key,
    required this.constellation,
    required this.gridSize,
    required this.onSolvingStateChanged,
  }) : super(key: key);

  final ConstellationMeta constellation;
  final Size gridSize;
  final void Function(bool) onSolvingStateChanged;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<_ConstellationPuzzleController>(
      init: _ConstellationPuzzleController(),
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
                    () => AnimatedDefaultTextStyle(
                      duration: kThemeChangeDuration,
                      curve: Curves.easeInOut,
                      style: GoogleFonts.josefinSlab(
                        textStyle: Theme.of(context).textTheme.headline4!.copyWith(
                              color: controller.isSolving()
                                  ? Colors.transparent
                                  : (constellation.solved ? Colors.white : Colors.white60),
                            ),
                      ),
                      child: Text(
                        constellation.solved ? constellation.constellation.name : 'Unknown',
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox.fromSize(
                    size: gridSize,
                    child: AnimatedCrossFade(
                      duration: kThemeChangeDuration,
                      crossFadeState: controller.isSolving() ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      firstChild: CustomPaint(
                        painter: ConstellationAnimationPainter(
                          constellation.constellationAnimation,
                          1,
                          starSize: constellation.constellation.starSize,
                        ),
                      ),
                      secondChild: ConstrainedBox(
                        constraints: BoxConstraints.tight(gridSize),
                        child: Obx(
                          () => ConstellationPuzzleGrid(
                            puzzle: controller.puzzle(),
                            constellation: constellation.constellation,
                            gridSize: gridSize,
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
                  SizedBox(height: 16),
                  // todo: make button impossible to tap when invisible
                  Obx(
                    () => AnimatedOpacity(
                      opacity: controller.isSolving() ? 0 : 1,
                      curve: Curves.easeInOut,
                      duration: kThemeChangeDuration,
                      child: TextButton(
                        onPressed: () {
                          if (!controller.isSolving()) {
                            controller.puzzle.value = Puzzle.generate(3);
                          }
                          // controller.puzzle = Puzzle([
                          //   for (var j = 0.0; j < 3; j++)
                          //     for (var i = 0.0; i < 3; i++)
                          //       Tile(TilePosition(i, j), TilePosition(i, j), i == 2 && j == 2),
                          // ]);
                          controller.isSolving.value = !controller.isSolving();
                          onSolvingStateChanged(controller.isSolving());
                        },
                        child: Text('Solve'),
                        style: ButtonStyle(
                          textStyle: MaterialStateProperty.all(TextStyle(fontSize: 18)),
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
