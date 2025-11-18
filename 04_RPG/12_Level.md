# **12_Level**

**【game.dart】**

```dart

abstract class LevelProvider {
  int get level;
}

```

**【player.dart】**


LevelProviderを追加

```dart

//⭐️ LevelProviderを追加
class Player extends SpriteAnimationComponent
    with HasGameRef<MainGame>, KeyboardHandler
    implements HealthProvider, SpProvider, LevelProvider {

Player(this.data);
  final CharacterData data;

  //速度の指定
  Vector2 velocity = Vector2.zero();
  //移動速度
  double moveSpeed = 200;

  // 歩数計算
  int stepsTaken = 0;
  // 移動距離
  double distanceMoved = 0.0;
  // 一歩の距離
  final double stepDistance = 16.0;

  // バトル中は Player 自身のキーボードを無効化
  bool keyboardEnabled = true;

  //　選択中の見た目用
  bool isSelected = false;

  int maxHp = 100;
  int hp = 100;

  int maxSp = 100;
  int sp = 100;

  @override
  int get currentHp => hp;

  @override
  int get currentSp => sp;

  //⭐️
  int lv = 1;
  int exp = 0;
  //⭐️
  @override
  int get level => lv;

```

**【game.dart】**


```dart

class KeySpy extends Component with KeyboardHandler {
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // ここは絶対にイベントを消費しない
    print('[KeySpy] $event keys=$keysPressed');
    return false;
  }
}

```

**【ui.dart】**

```dart

class LvLabel extends PositionComponent {
  LvLabel({
    required this.target,
    Vector2? offset,
    this.bg = const Color(0xFF222222),
    this.textColor = Colors.white,
    this.borderRadius = 4.0,
  }) {
    size = Vector2(34, 14); // 小さいパネル
    position = offset ?? Vector2.zero();
    anchor = Anchor.center;
    priority = 1000;

    _bgPaint.color = bg;

    _textPaint = TextPaint(
      style: TextStyle(
        color: textColor,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
        shadows: const [Shadow(blurRadius: 1, offset: Offset(1, 1))],
      ),
    );
  }

  final LevelProvider target;
  final Color bg;
  final Color textColor;
  final double borderRadius;

  final _bgPaint = Paint();
  late final TextPaint _textPaint;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 背景
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(rrect, _bgPaint);

    // "Lv X"
    final text = 'Lv ${target.level}';
    // パネル内で少し左上に
    _textPaint.render(
      canvas,
      text,
      Vector2(4, size.y / 2 - 6),
    );
  }
}

```

**【game.dart】**

```dart

player1.add(LvLabel(
  target: player1,
  offset: Vector2(0, -PLAYER_SIZE_Y / 2 - 24),
));

player2.add(LvLabel(
  target: player2,
  offset: Vector2(0, -PLAYER_SIZE_Y / 2 - 24),
));


```
