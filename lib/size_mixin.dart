import 'dart:ui';

import 'package:get/get.dart';
import 'package:star_puzzle/services/base_service.dart';

mixin SizeMixin {
  BaseService get baseService => Get.find<BaseService>();

  Size get gridSize => baseService.gridSize;
  Size get tileSize => baseService.tileSize;
}