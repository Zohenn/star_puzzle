import 'package:hive/hive.dart';

part 'constellation_progress.g.dart';

@HiveType(typeId: 0)
class ConstellationProgress {
  @HiveField(0, defaultValue: false)
  bool solved = false;

  @HiveField(1)
  int? bestMoves;

  @HiveField(2)
  int? bestTime;
}