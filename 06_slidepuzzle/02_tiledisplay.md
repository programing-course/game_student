# **02_タイルを表示する**


**【slie_puzzle_game.dart】**

```dart

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import '../model/puzzle_model.dart';
import '../components/tile_component.dart';

class SlidePuzzleGame extends FlameGame {
  static const int gridSize = 4;

  late final PuzzleModel model = PuzzleModel(gridSize);
  bool _initialized = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    if (!_initialized && size.x > 0 && size.y > 0) {
      _initialized = true;
      _spawnTiles();
    }
  }

  void _spawnTiles() {
    final shortest = size.x < size.y ? size.x : size.y;
    final tileAreaSize = shortest * 0.9; // 少し余白
    final tileSize = tileAreaSize / gridSize;

    final offsetX = (size.x - tileAreaSize) / 2;
    final offsetY = (size.y - tileAreaSize) / 2;

    // PuzzleModelで作ったtilesを一つずつ描画
    for (final tile in model.tiles) {
      // title_modelのisEmptyをみている、空白の場合true　描画しないで次のタイルをみる
      if (tile.isEmpty) continue;

      final row = model.rowOf(tile.currentIndex);
      final col = model.colOf(tile.currentIndex);

      final pos = Vector2(
        offsetX + col * tileSize,
        offsetY + row * tileSize,
      );

      // タイルの表示
      add(
        TileComponent(
          value: tile.value,
          tileSize: tileSize * 0.9,
          position: pos + Vector2(tileSize * 0.05, tileSize * 0.05),
        ),
      );
    }
  }
}

```

**【puzzle_model.dart】**

```dart

import 'tile_model.dart';

class PuzzleModel {
  final int gridSize;
  late List<TileModel> tiles;

  PuzzleModel(this.gridSize) {
    _initTiles();
  }

  void _initTiles() {
    final total = gridSize * gridSize;

    tiles = List.generate(total, (i) {
      final value = (i + 1) % total; // 最後が 0（空白）
      return TileModel(
        correctIndex: i,
        currentIndex: i,
        value: value,
      );
    });

    print("tiles==${tiles}");
  }

  /// 空白タイル
  TileModel get emptyTile => tiles.firstWhere((t) => t.isEmpty);

  int get emptyIndex => emptyTile.currentIndex;

  int rowOf(int index) => index ~/ gridSize;
  int colOf(int index) => index % gridSize;

  /// 指定 index にいるタイルを取得
  TileModel tileAtIndex(int index) {
    return tiles.firstWhere((t) => t.currentIndex == index);
  }
}

```

**【tile_model.dart】**

```dart

class TileModel {
  /// 正解位置（0〜N*N-1）
  final int correctIndex;

  /// 今どこにいるか（0〜N*N-1）
  int currentIndex;

  /// 表示する数字（0 は空白）
  final int value;

  TileModel({
    required this.correctIndex,
    required this.currentIndex,
    required this.value,
  });

  bool get isEmpty => value == 0;

  bool get isInCorrectPosition => !isEmpty && currentIndex == correctIndex;
}

```

**【tile_component.dart】**

```dart

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class TileComponent extends PositionComponent {
  final int value;
  final double tileSize;

  TileComponent({
    required this.value,
    required this.tileSize,
    required Vector2 position,
  }) : super(
          size: Vector2.all(tileSize),
          position: position,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, tileSize, tileSize);

    // 影
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.shift(const Offset(3, 3)),
        const Radius.circular(10),
      ),
      Paint()..color = Colors.black.withOpacity(0.3),
    );

    // 本体
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()..color = Colors.blueAccent,
    );

    // 枠
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // 数字
    final textPainter = TextPainter(
      text: TextSpan(
        text: value.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final offset = Offset(
      (tileSize - textPainter.width) / 2,
      (tileSize - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);
  }
}


```