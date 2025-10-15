# **08_攻撃**

**【game.dart】**

プレーヤーと敵の頭上にゲージを表示する

```dart

case "battle":
    CameraBackScreen _backscreenimg = CameraBackScreen(BackGroundlist[2]);
    await world.add(_backscreenimg);

    player1 = Player()
      ..keyboardEnabled = false
      ..position = Vector2(SCREENSIZE_X / 2 + 100, SCREENSIZE_Y - 200);

    player2 = Player()
      ..keyboardEnabled = false
      ..position = Vector2(SCREENSIZE_X / 2 + 400, SCREENSIZE_Y - 200);

    await world.add(player1!);
    await world.add(player2!);

    //⭐️ HPバー（non-nullなのでそのまま渡せる）
    player1.add(HpBar(
      target: player1,
      barSize: Vector2(70, 10),
      offset: Vector2(0, -PLAYER_SIZE_Y / 2 - 12),
    ));
    player2.add(HpBar(
      target: player2,
      barSize: Vector2(70, 10),
      offset: Vector2(0, -PLAYER_SIZE_Y / 2 - 12),
    ));

    _updateSelection(0);

    //⭐️ HpBar _Hp = HpBar(Hplist[0]);
    //⭐️ await world.add(_Hp);
    //⭐️ SpBar _Sp = SpBar(Hplist[1]);
    //⭐️ await world.add(_Sp);

    //省略

    //⭐️game.dartの最後に追加
    abstract class HealthProvider {
      int get currentHp;
      int get maxHp;
    }

```

**【ui.dart】**

今あるHpBarクラスを全てコメントアウト

```dart

class HpBar extends PositionComponent {
  HpBar({
    required this.target,
    required this.barSize,
    this.bg = const Color(0xFF333333),
    this.fg = const Color(0xFFE74C3C),
    this.borderRadius = 2.0,
    Vector2? offset,
  }) {
    size = barSize;
    position = offset ?? Vector2.zero();
    priority = 1000;
    anchor = Anchor.center;
    _bgPaint.color = bg;
    _fgPaint.color = fg;
  }

  final HealthProvider target;
  final Vector2 barSize;
  final Color bg;
  final Color fg;
  final double borderRadius;

  final _bgPaint = Paint();
  final _fgPaint = Paint();

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 背景
    final bgRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, barSize.x, barSize.y),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(bgRRect, _bgPaint);

    // 残量
    final ratio = target.maxHp == 0 ? 0.0 : target.currentHp / target.maxHp;
    final w = (barSize.x * ratio).clamp(0, barSize.x).toDouble();
    final fgRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, barSize.y),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(fgRRect, _fgPaint);
  }
}

```

**【player.dart】**

```dart

import 'teki.dart'; //⭐️追加

//省略

int maxHp = 100;
int hp = 100;

//⭐️追加
@override
int get currentHp => hp;

//省略

//⭐️ 修正
void attack() async{
    await gameRef.EffectRemove();

    const damage = 12;
    for (final teki in gameRef.world.children.whereType<Teki>()) {
      teki.applyDamage(damage);
      teki.hitShake();
    }
  }

```

**【teki.dart】**

```dart

//⭐️　implements HealthProviderを追加
class Teki extends SpriteComponent 
with HasGameRef<MainGame>, KeyboardHandler
implements HealthProvider {
  final CharacterData data;

  late final int _maxHp = data.hp;
  int _hp = 0;

  //⭐️ 追加
  @override
  int get currentHp => _hp;
  @override
  int get maxHp => _maxHp;

  Teki(this.data);
  Teki.random() : data = randomEnemy();

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(data.imagePath);
    size = Vector2(TEKI_SIZE_X, TEKI_SIZE_Y);
    position = Vector2(data.pos_x, data.pos_y);
    anchor = Anchor.center;
    priority = 10;

    //⭐️追加
    _hp = _maxHp;

    //⭐️追加
    add(HpBar(
      target: this, // ← これでOKになる
      barSize: Vector2(60, 8),
      offset: Vector2(0, -TEKI_SIZE_Y / 2 - 10),
    ));
  }
  
  //⭐️追加
  void applyDamage(int dmg) {
    _hp = (_hp - dmg).clamp(0, _maxHp);
    if (_hp <= 0) {
      removeFromParent();
    }
  }


  void hitShake({
    double amount = 8,
    int times = 3,
    double oneShakeSec = 0.05,
  }) {
    add(
      MoveEffect.by(
        Vector2(0, -amount),
        EffectController(
          duration: oneShakeSec,
          alternate: true,
          repeatCount: times,
          curve: Curves.easeOut,
        ),
      ),
    );
  }
}

```

### 敵からの攻撃

**【setting.dart】**

```dart

EffectData(
    idx: 5,
    color: Colors.transparent,
    size_x: 192, size_y: 192, // 6倍拡大表示
    pos_x: SCREENSIZE_X / 2 + 100,
    pos_y: SCREENSIZE_Y - 200,
    count: 0,
    background_img: "",
    type: EffectType.spriteSlash, // 任意のスプライト系タイプ
    spriteImage: 'YellowEffect.png', // 32x32タイルのシート
    frameCount: 3, // 3コマ使う
    stepTime: 0.1, // 速めのアニメ
    frameWidth: 32,
    frameHeight: 32,
    startRow: 0, // 行モード：2行目
    startCol: 2, // 4列目からスタート（0始まり）
    delaySec: 0.1,
  ),
  EffectData(
    idx: 6,
    color: Colors.transparent,
    size_x: 192, size_y: 192, // 6倍拡大表示
    pos_x: SCREENSIZE_X / 2 + 100,
    pos_y: SCREENSIZE_Y - 200,
    count: 0,
    background_img: "",
    type: EffectType.spriteSlash, // 任意のスプライト系タイプ
    spriteImage: 'GreenEffect.png', // 32x32タイルのシート
    stepTime: 0.1, // 速めのアニメ
    frames: [
      // i=0: 32x32
      SpriteFrameSpec(sx: 2 * 32, sy: 2 * 32, sw: 32, sh: 48),
      SpriteFrameSpec(sx: 3 * 32, sy: 2 * 32, sw: 32, sh: 48),
      SpriteFrameSpec(sx: 4 * 32, sy: 2 * 32, sw: 32, sh: 48),
    ],
    delaySec: 0.3,
  ),
  EffectData(
    idx: 7,
    color: Colors.transparent,
    size_x: 192, size_y: 192, // 6倍拡大表示
    pos_x: SCREENSIZE_X / 2 + 400,
    pos_y: SCREENSIZE_Y - 200,
    count: 0,
    background_img: "",
    type: EffectType.spriteSlash, // 任意のスプライト系タイプ
    spriteImage: 'YellowEffect.png', // 32x32タイルのシート
    frameCount: 3, // 3コマ使う
    stepTime: 0.1, // 速めのアニメ
    frameWidth: 32,
    frameHeight: 32,
    startRow: 0, // 行モード：2行目
    startCol: 2, // 4列目からスタート（0始まり）
    delaySec: 0.1,
  ),
  EffectData(
    idx: 8,
    color: Colors.transparent,
    size_x: 192, size_y: 192, // 6倍拡大表示
    pos_x: SCREENSIZE_X / 2 + 400,
    pos_y: SCREENSIZE_Y - 200,
    count: 0,
    background_img: "",
    type: EffectType.spriteSlash, // 任意のスプライト系タイプ
    spriteImage: 'GreenEffect.png', // 32x32タイルのシート
    stepTime: 0.1, // 速めのアニメ
    frames: [
      // i=0: 32x32
      SpriteFrameSpec(sx: 2 * 32, sy: 2 * 32, sw: 32, sh: 48),
      SpriteFrameSpec(sx: 3 * 32, sy: 2 * 32, sw: 32, sh: 48),
      SpriteFrameSpec(sx: 4 * 32, sy: 2 * 32, sw: 32, sh: 48),
    ],
    delaySec: 0.3,
  )

```

**【player.dart】**

```dart

import 'package:flame/effects.dart';//⭐️追加
import 'package:flutter/animation.dart';//⭐️追加

//省略

  void attack() async {
    await gameRef.EffectRemove();

    const damage = 12;
    for (final teki in gameRef.world.children.whereType<Teki>()) {
      teki.applyDamage(damage);
      teki.hitShake();
    }

    _queueEnemyCounter();//⭐️追加
  }

  //⭐️追加
  void _queueEnemyCounter() {
    Future.delayed(const Duration(seconds: 1), () {
      // 戦闘シーン中/対象が存在する時だけ実行
      if (scene != "battle") return;
      if (!isMounted) return;

      // 反撃対象は現在選択中のプレイヤー
      gameRef.EffectRemove_player();
      const damage = 12;
      selectedPlayer.applyDamage(damage);
      selectedPlayer.hitShake();
    });
  }

  //⭐️追加
  void applyDamage(int dmg) {
    hp = (hp - dmg).clamp(0, maxHp);
    if (hp <= 0) {
      removeFromParent();
    }
  }

  //省略

  //⭐️追加 最後についか

  void hitShake({
    double amount = 8,
    int times = 3,
    double oneShakeSec = 0.05,
  }) {
    add(
      MoveEffect.by(
        Vector2(0, -amount),
        EffectController(
          duration: oneShakeSec,
          alternate: true,
          repeatCount: times,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

```

**【game.dart】**

```dart

  Future<void> EffectRemove_player() async {
    if (selectedPlayer == player1) {
      SpriteEffect _effect5 = SpriteEffect(Effectlist[5]);
      await world.add(_effect5);

      SpriteEffect _effect6 = SpriteEffect(Effectlist[6]);
      await world.add(_effect6);
    } else {
      SpriteEffect _effect7 = SpriteEffect(Effectlist[7]);
      await world.add(_effect7);

      SpriteEffect _effect8 = SpriteEffect(Effectlist[8]);
      await world.add(_effect8);
    }
  }

```