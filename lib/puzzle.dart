import 'dart:math';

import 'dart:ui';

import 'package:flutter/animation.dart';

class TilePosition implements Comparable<TilePosition> {
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

  @override
  int compareTo(TilePosition other) {
    if (y < other.y) {
      return -1;
    } else if (y > other.y) {
      return 1;
    } else {
      if (x < other.x) {
        return -1;
      } else if (x > other.x) {
        return 1;
      } else {
        return 0;
      }
    }
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

  bool get correct {
    return originalPosition == _currentPosition;
  }

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

  bool get complete {
    return tiles.every((element) => element.correct);
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

  bool isSolvable() {
    final inversions = countInversions();

    if (size.isOdd) {
      return inversions.isEven;
    }

    final emptyTile = tiles.singleWhere((tile) => tile.isEmpty);
    final emptyRow = emptyTile.currentPosition.y.toInt();

    if (((size - emptyRow) + 1).isOdd) {
      return inversions.isEven;
    } else {
      return inversions.isOdd;
    }
  }

  /// Gives the number of inversions in a puzzle given its tile arrangement.
  ///
  /// An inversion is when a tile of a lower value is in a greater position than
  /// a tile of a higher value.
  int countInversions() {
    var count = 0;
    for (var a = 0; a < tiles.length; a++) {
      final tileA = tiles[a];
      if (tileA.isEmpty) {
        continue;
      }

      for (var b = a + 1; b < tiles.length; b++) {
        final tileB = tiles[b];
        if (_isInversion(tileA, tileB)) {
          count++;
        }
      }
    }
    return count;
  }

  /// Determines if the two tiles are inverted.
  bool _isInversion(Tile a, Tile b) {
    if (!b.isEmpty && a.number != b.number) {
      if (b.number < a.number) {
        return b.currentPosition.compareTo(a.currentPosition) > 0;
      } else {
        return a.currentPosition.compareTo(b.currentPosition) > 0;
      }
    }
    return false;
  }

  int getNumberOfCorrectTiles() {
    final _emptyTile = emptyTile;
    var numberOfCorrectTiles = 0;
    for (final tile in tiles) {
      if (tile != _emptyTile) {
        if (tile.currentPosition == tile.originalPosition) {
          numberOfCorrectTiles++;
        }
      }
    }
    return numberOfCorrectTiles;
  }
}
