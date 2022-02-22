// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'constellation_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConstellationProgressAdapter extends TypeAdapter<ConstellationProgress> {
  @override
  final int typeId = 0;

  @override
  ConstellationProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConstellationProgress()
      ..solved = fields[0] == null ? false : fields[0] as bool
      ..bestMoves = fields[1] as int?
      ..bestTime = fields[2] as int?;
  }

  @override
  void write(BinaryWriter writer, ConstellationProgress obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.solved)
      ..writeByte(1)
      ..write(obj.bestMoves)
      ..writeByte(2)
      ..write(obj.bestTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConstellationProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
