# **04_アニメーション**

アニメーションの書き方  

```dart

c.add(
  MoveToEffect(
    Vector2(目標位置x, 目標位置y),
    EffectController(duration: 0.15, curve: Curves.easeOut),
  ),
);

```

**【puzzle_model.dart】**

```dart

import 'dart:async'; //⭐️追加
import 'package:flame/effects.dart'; //⭐️追加
import 'package:flutter/material.dart'; //⭐️追加

//省略

bool isAnimating = false; //⭐️追加

//省略

//⭐️boolに変更
  bool onTapUp(TapUpInfo info) {
    if (isAnimating) return true;//⭐️追加

    final widgetPos = info.eventPosition.widget;
    final tapPos = Vector2(widgetPos.x, widgetPos.y);
    final index = _positionToIndex(tapPos);

    if (index == null) return true;//⭐️修正

    final moved = controller.tryMove(index);
    if (!moved) return true;//⭐️修正

    _updateTilePositions();
    return true;//⭐️追加
  }

//⭐️ async追加
void _updateTilePositions() async {
    //⭐️追加
    if (isAnimating) return;
    isAnimating = true;
    final futures = <Future>[];

    for (final c in children.whereType<TileComponent>()) {
      final tile = model.tiles.firstWhere((t) => t.value == c.value);

      final row = model.rowOf(tile.currentIndex);
      final col = model.colOf(tile.currentIndex);

      //⭐️ final newPos = Vector2(
      //⭐️   offsetX + col * tileSize,
      //⭐️   offsetY + row * tileSize,
      //⭐️ );

      //⭐️ c.position = newPos + Vector2(tileSize * 0.05, tileSize * 0.05);

      //⭐️追加
      final targetPos = Vector2(
            offsetX + col * tileSize,
            offsetY + row * tileSize,
          ) +
          Vector2(tileSize * 0.05, tileSize * 0.05);

      // アニメーション追加
      final effect = MoveToEffect(
        targetPos,
        EffectController(
          duration: 0.5,
          curve: Curves.easeOut,
        ),
      );

      // effect の完了を Future で受け取る
      final completer = Completer();
      effect.onComplete = () => completer.complete();
      futures.add(completer.future);

      c.add(effect);
    }

    // 全タイル移動完了待ち
    await Future.wait(futures);

    isAnimating = false;
  }

```

**【puzzle_controller.dart】**

```dart

import '../model/puzzle_model.dart';

class PuzzleController {
  final PuzzleModel model;

  PuzzleController(this.model);

  /// タップした index のタイルが空白の隣なら動かす
  bool tryMove(int index) {
    // 空白と同一なら意味なし
    if (index == model.emptyIndex) return false;

    // 空白の隣か？
    if (!_isNeighborOfEmpty(index)) return false;

    // モデルを更新（空白と入れ替え）
    model.swapWithEmpty(index);
    return true;
  }

  /// 空白の隣（上下左右）か？
  bool _isNeighborOfEmpty(int index) {
    final e = model.emptyIndex;
    final size = model.gridSize;

    final up = e - size;
    final down = e + size;
    final left = e - 1;
    final right = e + 1;

    return index == up ||
        index == down ||
        index == left ||
        index == right;
  }
}

```


tap → タップ座標 → index 変換  
　　↓  
PuzzleController.tryMove()  
　　↓  
PuzzleModel が更新される  
　　↓  
TileComponent の表示位置を更新  

**【puzzle_controller.dart】**

```dart

import '../model/puzzle_model.dart';

class PuzzleController {
  final PuzzleModel model;

  PuzzleController(this.model);

  /// タップした index のタイルが空白の隣なら動かす
  bool tryMove(int index) {
    // 空白と同一なら意味なし
    if (index == model.emptyIndex) return false;

    // 空白の隣か？
    if (!_isNeighborOfEmpty(index)) return false;

    // モデルを更新（空白と入れ替え）
    model.swapWithEmpty(index);
    return true;
  }

  /// 空白の隣（上下左右）か？
  bool _isNeighborOfEmpty(int index) {
    final e = model.emptyIndex;
    final size = model.gridSize;

    final up = e - size;
    final down = e + size;
    final left = e - 1;
    final right = e + 1;

    return index == up || index == down || index == left || index == right;
  }
}

```

**【slide_puzzle_game.dart】**

```dart

import 'package:flame/events.dart'; //⭐️追加
import 'puzzle_controller.dart'; //⭐️追加

//⭐️追加　TapDetector
class SlidePuzzleGame extends FlameGame with TapDetector {
  static const int gridSize = 4;

  late final PuzzleModel model = PuzzleModel(gridSize);
  late final PuzzleController controller = PuzzleController(model); //⭐️追加
  bool _initialized = false;

  //⭐️追加
  double tileSize = 0;
  double offsetX = 0;
  double offsetY = 0;

  //省略

  void _spawnTiles() {
    final shortest = size.x < size.y ? size.x : size.y;
    final tileAreaSize = shortest * 0.9; // 少し余白
    tileSize = tileAreaSize / gridSize; //⭐️修正

    offsetX = (size.x - tileAreaSize) / 2; //⭐️修正
    offsetY = (size.y - tileAreaSize) / 2; //⭐️修正

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

  
  // ----------------------
  //  ⭐️タップ処理
  // ----------------------
  @override
  void onTapUp(TapUpInfo info) {
    final widgetPos = info.eventPosition.widget;
    final tapPos = Vector2(widgetPos.x, widgetPos.y);
    final index = _positionToIndex(tapPos);

    if (index == null) return;

    final moved = controller.tryMove(index);
    if (!moved) return;

    _updateTilePositions();
  }

  /// タップ座標 → index 変換
  int? _positionToIndex(Vector2 pos) {
    final x = pos.x - offsetX;
    final y = pos.y - offsetY;

    if (x < 0 || y < 0) return null;
    if (x > tileSize * gridSize || y > tileSize * gridSize) return null;

    //タップしたタイルがどの行列にいるか
    final col = (x ~/ tileSize).clamp(0, gridSize - 1);
    final row = (y ~/ tileSize).clamp(0, gridSize - 1);

    return row * gridSize + col;
  }

  /// PuzzleModel の currentIndex に応じて TileComponent を動かす
  void _updateTilePositions() {
    for (final c in children.whereType<TileComponent>()) {
      final tile = model.tiles.firstWhere((t) => t.value == c.value);

      final row = model.rowOf(tile.currentIndex);
      final col = model.colOf(tile.currentIndex);

      final newPos = Vector2(
        offsetX + col * tileSize,
        offsetY + row * tileSize,
      );

      c.position = newPos + Vector2(tileSize * 0.05, tileSize * 0.05);
    }
  }

```