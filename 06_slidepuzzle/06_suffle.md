# **06_シャッフル**

**逆操作シャッフル**

“解ける盤面”から逆操作を繰り返すと. 
その結果も必ず“解ける盤面”

**【puzzle_model.dart】**

```dart

import 'package:flame/text.dart'; //⭐️追加

//⭐️追加
enum GameState {
  playing,
  cleared,
}

//省略

double tileSize = 0;
double offsetX = 0;
double offsetY = 0;

GameState gameState = GameState.playing; //⭐️追加

bool onTapUp(TapUpInfo info) {
    if (gameState != GameState.playing) return true; //⭐️追加
    if (isAnimating) return true;

    final widgetPos = info.eventPosition.widget;
    final tapPos = Vector2(widgetPos.x, widgetPos.y);
    final index = _positionToIndex(tapPos);

    if (index == null) return true;

    final moved = controller.tryMove(index);
    if (!moved) return true;

    _updateTilePositions();
    return true;
  }

void _updateTilePositions() async {
    
    //省略

    // 全タイル移動完了待ち
    await Future.wait(futures);

    isAnimating = false;

    _checkClear(); //⭐️追加
  }

  //⭐️追加
  void _checkClear() {
    if (!model.isSolved) return;

    gameState = GameState.cleared;
    _showClearEffect();
  }

  //⭐️追加
  void _showClearEffect() {
    final text = TextComponent(
      text: 'CLEAR!',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: size / 2,
    );

    add(text);

    // ちょっとだけスケールアニメーション
    text.add(
      ScaleEffect.to(
        Vector2.all(1.2),
        EffectController(
          duration: 0.3,
          reverseDuration: 0.3,
          curve: Curves.easeOutBack,
        ),
      ),
    );
  }

```

**【puzzle_model.dart】**

```dart

//⭐️追加
bool get isSolved {
  // 空白(0)以外のタイルが、みんな正しい位置にいるか？
  for (final tile in tiles) {
    if (tile.isEmpty) continue;
    if (!tile.isInCorrectPosition) return false;
  }
  return true;
}

```

**【puzzle_controller.dart】**

```dart

import 'dart:math'; //⭐️追加
import '../model/puzzle_model.dart';

class PuzzleController {
  final PuzzleModel model;
  final _rnd = Random(); //⭐️追加

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

  //⭐️追加
  void shuffle({int moves = 100}) {
    for (int i = 0; i < moves; i++) {
      final neighbors = _getMovableNeighbors();
      final chosen = neighbors[_rnd.nextInt(neighbors.length)];
      model.swapWithEmpty(chosen);
    }
  }

  //⭐️　追加空白の隣の index をすべて返す
  List<int> _getMovableNeighbors() {
    final e = model.emptyIndex;
    final size = model.gridSize;

    final list = <int>[];
    if (e - size >= 0) list.add(e - size);
    if (e + size < size * size) list.add(e + size);
    if (e % size != 0) list.add(e - 1);
    if (e % size != size - 1) list.add(e + 1);

    return list;
  }
}

```