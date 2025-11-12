# **14_SCORE**

**①変数設定**

**【crane_game.dart】**


```dart

@override
  void update(double dt) {
    super.update(dt);

    _gameTime += dt;//⭐️追加

    if (_carryPreview != null && _player.isMounted) {
      _carryPreview!.position = _player.position + Vector2(0, _carryOffsetY);
      _carryPreview!.priority = _player.priority + 1;
    }

    // === タイマー ===
    if (!isGameOver) {
      timeLeft -= dt;
      if (timeLeft <= 0) {
        timeLeft = 0;
        isGameOver = true;
        // 必要ならここでゲームオーバー演出や入力無効化など
      }
    }

    // === 左右の重さ集計 & 水平度 ===
    _recomputeWeightsAndAngle();
  }

  //省略

  void _performMerge(Ball a, Ball b) {
    
    //省略

    a.removeFromParent();
    b.removeFromParent();
    add(Ball(newData));

    _mergeQueued.removeAll([a, b]);

    _onMerged(); //⭐️追加
  }

  //省略

  void _performMergeBox(Box a, Box b) {
    
    //省略

    a.removeFromParent();
    b.removeFromParent();
    add(Box(newData));

    _mergeQueuedBox.removeAll([a, b]);

    _onMerged();  //⭐️追加
  }

  //⭐️追加 === Scoring & Combo ===
  int score = 0;
  int combo = 0;

  double _gameTime = 0; // 累積時間(秒)
  double _lastMergeTime = -1e9; // 最後に合体した時刻
  static const double kComboWindow = 2.0; // 2秒以内ならコンボ継続

  void _onMerged() {
    final bool within = (_gameTime - _lastMergeTime) <= kComboWindow;
    if (!within) combo = 0; // 間が空いたらコンボリセット

    final int bonus = combo * 5; // いまのコンボ数に応じたボーナス
    score += 5 + bonus; // 基本5pt + コンボボーナス
    combo += 1; // 次の合体に向けてコンボ段階アップ
    _lastMergeTime = _gameTime;
  }

```

**【score.dart】**


```dart

class HudOverlay extends PositionComponent with HasGameRef<CraneGame> {
  late final TextComponent _timerText;
  late final TextComponent _weightText;
  late final TextComponent _angleText;
  late final TextComponent _scoreText;  //⭐️追加
  late final TextComponent _comboText;  //⭐️追加

  @override
  Future<void> onLoad() async {
    priority = 100000; // 一番前に

    _timerText = TextComponent(text: '', textRenderer: _textPaint)
      ..anchor = Anchor.topLeft
      ..position = Vector2(10, 10);

    _weightText = TextComponent(text: '', textRenderer: _textPaint)
      ..anchor = Anchor.topLeft
      ..position = Vector2(10, 34);

    _angleText = TextComponent(text: '', textRenderer: _textPaint)
      ..anchor = Anchor.topLeft
      ..position = Vector2(10, 58);

    //⭐️追加
    _scoreText = TextComponent(text: '', textRenderer: _textPaint)
      ..anchor = Anchor.topLeft
      ..position = Vector2(10, 82);

    //⭐️追加
    _comboText = TextComponent(text: '', textRenderer: _textPaint)
      ..anchor = Anchor.topLeft
      ..position = Vector2(10, 106);

    //⭐️追加　_scoreTextと _comboText
    addAll([_timerText, _weightText, _angleText, _scoreText, _comboText]);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final t = gameRef.timeLeft;
    final mm = (t ~/ 60).toString().padLeft(2, '0');
    final ss = (t % 60).floor().toString().padLeft(2, '0');

    _timerText.text = '⏱  $mm:$ss';
    _weightText.text = '⚖️  L ${gameRef.leftWeight.toStringAsFixed(1)}  |  '
        'R ${gameRef.rightWeight.toStringAsFixed(1)}';
    _angleText.text = '📐  ${gameRef.seesawAngleDeg.toStringAsFixed(1)}°';

    //⭐️追加
    _scoreText.text = '💯  SCORE: ${gameRef.score}';
    _comboText.text = gameRef.combo > 0 ? '🔥  COMBO: ${gameRef.combo}x' : '';
  }
```
