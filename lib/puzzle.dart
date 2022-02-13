import 'dart:math';

import 'dart:ui';

class TilePosition {
  TilePosition(this.x, this.y);

  final int x;
  final int y;

  int get index {
    return x * 3 + y;
  }

  TilePosition copy() {
    return TilePosition(x, y);
  }

  Offset distanceTo(TilePosition other){
    return Offset((x - other.x).toDouble(), (y - other.y).toDouble());
  }
}

class Tile {
  Tile(this.originalPosition, this.currentPosition, this.isEmpty);

  TilePosition originalPosition;
  TilePosition currentPosition;
  final bool isEmpty;

  int get number {
    return originalPosition.index + 1;
  }

  Offset distanceTo(Tile other){
    return currentPosition.distanceTo(other.currentPosition);
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

  void moveTile(Tile tile) {
    if (!canMoveTile(tile)) {
      return;
    }

    final _emptyTile = emptyTile;
    Offset distance = tile.distanceTo(_emptyTile);
    while(distance.distance > 1){
      moveTile(tileAt((_emptyTile.currentPosition.x + distance.dx.sign).toInt(), (_emptyTile.currentPosition.y + distance.dy.sign).toInt()));
      distance = tile.distanceTo(_emptyTile);
    }

    final emptyTilePosition = _emptyTile.currentPosition.copy();
    final tilePosition = tile.currentPosition.copy();

    tile.currentPosition = emptyTilePosition;
    _emptyTile.currentPosition = tilePosition;

    tiles[tile.currentPosition.index] = tile;
    tiles[_emptyTile.currentPosition.index] = _emptyTile;
  }
}