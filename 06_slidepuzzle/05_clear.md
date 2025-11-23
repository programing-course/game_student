# **0５_クリア**

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

