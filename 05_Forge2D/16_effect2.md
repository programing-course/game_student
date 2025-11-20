# **16_effect2**

**①変数設定**

**【crane_game.dart】**


```dart

//⭐️ 新規追加
class FloatingScoreText extends PositionComponent {
  final String text;
  final Color baseColor;
  final double duration;

  double _elapsed = 0;
  late TextPaint _textPaint;

  FloatingScoreText({
    required this.text,
    required this.baseColor,
    this.duration = 1.0,
  }) {
    anchor = Anchor.center;
    _textPaint = TextPaint(
      style: TextStyle(
        color: baseColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        shadows: const [
          Shadow(blurRadius: 4, color: Colors.black54, offset: Offset(1, 1)),
        ],
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    _textPaint.render(canvas, text, Vector2.zero());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    // 上にふわっと動く
    position.y -= 20 * dt;

    // 徐々に透明になる
    final t = (_elapsed / duration).clamp(0.0, 1.0);
    final opacity = 1.0 - t;

    _textPaint = TextPaint(
      style: TextStyle(
        color: baseColor.withOpacity(opacity),
        fontSize: 18,
        fontWeight: FontWeight.bold,
        shadows: const [
          Shadow(blurRadius: 4, color: Colors.black54, offset: Offset(1, 1)),
        ],
      ),
    );

    if (_elapsed >= duration) {
      removeFromParent();
    }
  }
}


```

**【crane_game.dart】**

```dart

void _onMerged(Vector2 worldPos) {
    final bool within = (_gameTime - _lastMergeTime) <= kComboWindow;
    if (!within) combo = 0;

    final int bonus = combo * 5;
    final int addScore = 5 + bonus; // 今回増えた分
    score += addScore;
    combo += 1;
    _lastMergeTime = _gameTime;

    // ⭐️ 追加
    final ft = FloatingScoreText(
      text: '+$addScore',
      baseColor: Colors.yellowAccent,
      duration: 1.0,
    )
      ..position = worldPos.clone()
      ..priority = 100000; // 前面に

    add(ft);
  }

```

**【crane_game.dart】**

```dart

void _performMerge(Ball a, Ball b) {

    //省略

    // 旧ボールを削除 → 新規追加
    a.removeFromParent();
    b.removeFromParent();
    add(Ball(newData));

    _mergeQueued.removeAll([a, b]);

    //⭐️ _spawnMergeParticles(pos, newColor);

    _onMerged(pos);//⭐️追加
  }

  void _performMergeBox(Box a, Box b) {

    //省略

    a.removeFromParent();
    b.removeFromParent();
    add(Box(newData));

    _mergeQueuedBox.removeAll([a, b]);

    //⭐️ _spawnMergeParticles(pos, color);

    _onMerged(pos);//⭐️追加
  }

```
