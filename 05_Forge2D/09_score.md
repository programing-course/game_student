# **09_スコアー表示**

**①変数設定**

**【crane_game.dart】**


```dart

import 'score.dart';// ⭐️追加

class CraneGame extends Forge2DGame with HasKeyboardHandlerComponents {

  // ⭐️追加
  double timeLeft = 60.0; // 秒（好きな制限時間に）
  bool isGameOver = false;
  double leftWeight = 0.0; // 左側総重量（kg扱い）
  double rightWeight = 0.0; // 右側総重量（kg扱い）
  double seesawAngleDeg = 0.0; // シーソー角度（度）

//省略

@override
  Future<void> onLoad() async {

  //省略

  //⭐️追加
    add(HudOverlay());
  }
```

**②タイマー設定**

**【crane_game.dart】**

```dart

@override
  void update(double dt) {
    super.update(dt);

    if (_carryPreview != null && _player.isMounted) {
      _carryPreview!.position = _player.position + Vector2(0, _carryOffsetY);
      _carryPreview!.priority = _player.priority + 1;
    }

    // ⭐️追加
    // === タイマー ===
    if (!isGameOver) {
      timeLeft -= dt;
      if (timeLeft <= 0) {
        timeLeft = 0;
        isGameOver = true;
        // 必要ならここでゲームオーバー演出や入力無効化など
      }
    }

    // ⭐️追加
    // === 左右の重さ集計 & 水平度 ===
    _recomputeWeightsAndAngle();

  }

  // ⭐️追加
  void _recomputeWeightsAndAngle() {
    // 水平度（角度）
    if (_seesaw.body != null) {
      seesawAngleDeg = _seesaw.body.angle * 180.0 / math.pi;
    } else {
      seesawAngleDeg = 0.0;
    }

    // 左右の重さ（シーソー幅内にある動的ボディのみ）
    final pivotX = _seesaw.data.centerX;
    final leftX = _seesaw.data.centerX - _seesaw.data.halfWidth;
    final rightX = _seesaw.data.centerX + _seesaw.data.halfWidth;

    double l = 0.0, r = 0.0;

    for (final c in children) {
      if (c is BodyComponent && c.body != null) {
        // Ball / Box だけ数える（他の地面やシーソー本体を除外）
        final isCountTarget = (c is Ball) || (c is Box);
        if (!isCountTarget) continue;

        final pos = c.body.worldCenter;
        // シーソーの横幅範囲内のみを対象
        if (pos.x < leftX || pos.x > rightX) continue;

        final mass = c.body.mass; // Forge2Dの質量(≒重さ)
        if (pos.x < pivotX) {
          l += mass;
        } else {
          r += mass;
        }
      }
    }

    leftWeight = l;
    rightWeight = r;
  }

```

**【score.dart】**

```dart

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'crane_game.dart';

class HudOverlay extends PositionComponent with HasGameRef<CraneGame> {
  late final TextComponent _timerText;
  late final TextComponent _weightText;
  late final TextComponent _angleText;

  final _textPaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontFeatures: [FontFeature.tabularFigures()], // 等幅っぽく
      shadows: [
        Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1))
      ],
    ),
  );

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

    addAll([_timerText, _weightText, _angleText]);
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
  }
}


```

**【seesaw.dart】**

```dart

extension SeesawAccessors on Seesaw {
  /// 中心座標（world）
  Vector2 get center => Vector2(data.centerX, data.centerY);

  /// 長さ・厚み（world）
  double get length => data.halfWidth * 2;
  double get thickness => data.halfHeight * 2;

  /// 上面Y座標（world）
  double get topY => data.centerY - data.halfHeight;

  /// 左右端X座標（world）
  double get leftX => data.centerX - data.halfWidth;
  double get rightX => data.centerX + data.halfWidth;

  ///⭐️ board の body にアクセスできるようにする
  Body get body => board.body;
}

```
