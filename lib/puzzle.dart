import 'dart:math';

import 'dart:ui';

import 'package:flutter/animation.dart';

class TilePosition {
  TilePosition(this.x, this.y);

  final double x;
  final double y;

  int get index {
    return (x * 3 + y).toInt();
  }

  TilePosition copy() {
    return TilePosition(x, y);
  }

  Offset distanceTo(TilePosition other) {
    return Offset((x - other.x).toDouble(), (y - other.y).toDouble());
  }

  static TilePosition lerp(TilePosition a, TilePosition b, double t) {
    return TilePosition(lerpDouble(a.x, b.x, t)!, lerpDouble(a.y, b.y, t)!);
  }

  @override
  bool operator ==(Object other) {
    return other is TilePosition && other.runtimeType == TilePosition && other.x == x && other.y == y;
  }
}

class TilePositionTween extends Tween<TilePosition> {
  TilePositionTween({required TilePosition begin, required TilePosition end}) : super(begin: begin, end: end);

  @override
  TilePosition lerp(double t) => TilePosition.lerp(begin!, end!, t);
}

class Tile {
  Tile(this.originalPosition, this._currentPosition, this.isEmpty);

  final TilePosition originalPosition;
  TilePosition _currentPosition;
  final bool isEmpty;
  TilePosition? _lastPosition;
  TilePositionTween? _positionTween;

  int get number {
    return originalPosition.index + 1;
  }

  Offset distanceTo(Tile other) {
    return currentPosition.distanceTo(other.currentPosition);
  }

  TilePosition get currentPosition => _currentPosition;

  set currentPosition(TilePosition newPosition) {
    if (_currentPosition != newPosition) {
      _positionTween = TilePositionTween(begin: _currentPosition, end: newPosition);
    }
    _lastPosition = _currentPosition;
    _currentPosition = newPosition;
  }

  TilePositionTween get positionTween {
    _positionTween ??= TilePositionTween(begin: _lastPosition ?? currentPosition, end: currentPosition);
    return _positionTween!;
  }
}

class Puzzle {
  Puzzle(this.tiles);

  final List<Tile> tiles;

  int get size {
    return sqrt(tiles.length).floor();
  }

  Tile tileAt(int x, int y) {
    return tiles[x * 3 + y];
  }

  Tile get emptyTile {
    return tiles.firstWhere((element) => element.isEmpty);
  }

  bool canMoveTile(Tile tile) {
    final _emptyTile = emptyTile;
    return tile.currentPosition.x == _emptyTile.currentPosition.x ||
        tile.currentPosition.y == _emptyTile.currentPosition.y;
  }

  List<Tile> moveTile(Tile tile) {
    if (!canMoveTile(tile)) {
      return [];
    }

    final _emptyTile = emptyTile;
    Offset distance = tile.distanceTo(_emptyTile);
    final updatedTiles = <Tile>[];
    while (distance.distance > 1) {
      updatedTiles.addAll(
        moveTile(tileAt((_emptyTile.currentPosition.x + distance.dx.sign).toInt(),
            (_emptyTile.currentPosition.y + distance.dy.sign).toInt())),
      );
      distance = tile.distanceTo(_emptyTile);
    }

    final emptyTilePosition = _emptyTile.currentPosition.copy();
    final tilePosition = tile.currentPosition.copy();

    tile.currentPosition = emptyTilePosition;
    _emptyTile.currentPosition = tilePosition;

    tiles[tile.currentPosition.index] = tile;
    tiles[_emptyTile.currentPosition.index] = _emptyTile;

    return updatedTiles..add(tile);
  }
}
