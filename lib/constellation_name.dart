import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:star_puzzle/services/base_service.dart';
import 'package:star_puzzle/services/constellation_service.dart';
import 'package:star_puzzle/star_path.dart';
import 'package:star_puzzle/widgets/theme_provider.dart';

class _ConstellationNameController extends GetxController with GetTickerProviderStateMixin {
  _ConstellationNameController(this.constellation);

  final ConstellationMeta constellation;

  AnimationController? nameAnimationController;
  Animation? nameAnimation;
  Animation? starLeaveAnimation;
  Animation? starEntryLeaveTranslateAnimation;
  Animation? starEntryLeaveScaleAnimation;
  Animation? starRotateAnimation;

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
        Get.find<BaseService>().solvingState.value = SolvingState.done;
      }
    });
  }
}

class ConstellationName extends StatelessWidget {
  const ConstellationName({
    Key? key,
    required this.constellation,
  }) : super(key: key);

  final ConstellationMeta constellation;

  BaseService get baseService => Get.find<BaseService>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<_ConstellationNameController>(
      init: _ConstellationNameController(constellation),
      global: false,
      builder: (controller) => Obx(
        () => baseService.solvingState() == SolvingState.animating
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
                                      controller.starEntryLeaveTranslateAnimation!.value * constraints.maxWidth * 2,
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
            : Text(
                constellation.solved() ? constellation.constellation.name : 'Unknown',
                style: GoogleFonts.josefinSlab(
                  textStyle: Theme.of(context).textTheme.headline4!.copyWith(
                        color: (baseService.solvingState() == SolvingState.solving)
                            ? Colors.transparent
                            : (constellation.solved() ? cornsilk : Colors.white60),
                      ),
                ),
              ),
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
