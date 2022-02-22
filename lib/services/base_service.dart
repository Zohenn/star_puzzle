import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:star_puzzle/constellation_progress.dart';
import 'package:star_puzzle/services/constellation_service.dart';

enum SolvingState {
  none,
  solving,
  animating,
  done,
}

class BaseService extends GetxService {
  late Future initFuture;
  late Box<ConstellationProgress> _box;
  final solvingState = SolvingState.none.obs;

  final size = 3;
  final gridSize = const Size.square(300);

  Size get tileSize => gridSize / size.toDouble();

  final constellationIconSize = const Size.square(96);
  final constellationIconPadding = const EdgeInsets.symmetric(vertical: 24.0);

  @override
  void onInit() {
    super.onInit();

    initFuture = init();
  }

  Future init() async {
    final task = await Future.delayed(20.milliseconds, () async {
      await Future.wait(
        [
          precacheImage(const AssetImage('assets/night_sky.jpg'), Get.context!),
          precacheImage(const AssetImage('assets/sky_map.jpg'), Get.context!),
          _openBox(),
        ],
      );
    });

    await task;

    final constellationService = Get.put(ConstellationService());
    _loadProgress();
    await constellationService.loadImages();
  }

  Future _openBox() async {
    _box = await Hive.openBox<ConstellationProgress>('stazzle');
  }

  void _loadProgress() {
    final constellationService = Get.find<ConstellationService>();
    for(var constellation in constellationService.constellations){
      final constellationProgress = _box.get(constellation.constellation.name);
      if(constellationProgress != null){
        constellation.loadProgress(constellationProgress);
      }
    }
  }

  void saveConstellationProgress(ConstellationMeta constellation) {
    final progress = ConstellationProgress();
    progress.solved = constellation.solved();
    progress.bestMoves = constellation.bestMoves();
    progress.bestTime = constellation.bestTime();
    _box.put(constellation.constellation.name, progress);
  }

  @override
  void onClose() {
    _box.close();
    super.onClose();
  }
}
