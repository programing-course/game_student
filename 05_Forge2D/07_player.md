# **07_プレーヤー出す**

**①データ設定**

**【setting.dart】**

```dart

final PLAYER_SIZE_X = 60.0;
final PLAYER_SIZE_Y = 60.0;

```

**【player.dart】**

```dart

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flame/collisions.dart';
import 'setting.dart';
import 'crane_game.dart';

class Player extends SpriteAnimationComponent
    with HasGameRef<CraneGame>, KeyboardHandler, CollisionCallbacks {
  //速度の指定
  Vector2 velocity = Vector2.zero();
  //移動速度
  double moveSpeed = 200;

  //各方向のスプライト
  late SpriteAnimation leftAnimation;
  late SpriteAnimation rightAnimation;
  late SpriteAnimation stop_leftAnimation;
  late SpriteAnimation stop_rightAnimation;

  @override
  Future<void> onLoad() async {
    // sprite = await Sprite.load('ika2.png');

    //スプライトロード
    final leftSprites = [
      await gameRef.loadSprite('ika.png'),
    ];
    final rightSprites = [
      await gameRef.loadSprite('ika2.png'),
    ];
    final stop_leftSprites = [
      await gameRef.loadSprite('ika.png'),
      await gameRef.loadSprite('ika_up.png'),
    ];
    final stop_rightSprites = [
      await gameRef.loadSprite('ika2.png'),
      await gameRef.loadSprite('ika2_up.png'),
    ];

    //アニメーション（画像切り替え）
    leftAnimation = SpriteAnimation.spriteList(leftSprites, stepTime: 0.2);
    rightAnimation = SpriteAnimation.spriteList(rightSprites, stepTime: 0.2);

    stop_leftAnimation =
        SpriteAnimation.spriteList(stop_leftSprites, stepTime: 0.2);
    stop_rightAnimation =
        SpriteAnimation.spriteList(stop_rightSprites, stepTime: 0.2);

    //最初に表示するアニメーション
    animation = stop_rightAnimation;

    size = Vector2(PLAYER_SIZE_X, PLAYER_SIZE_Y);
    position = Vector2(FIELD_SIZE_X / 2, 100); //⭐️修正

    anchor = Anchor.center;
    priority = 10;
    add(RectangleHitbox());
  }

  //キーボード操作
  @override
  bool onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      //左矢印押した時
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        leftflg = true;
        rightflg = false;
        moveLeft();
        //右矢印押した時
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        leftflg = false;
        rightflg = true;
        moveRight();
        //スペースキー押した時
      }
    } else if (event is KeyUpEvent) {
      if (!keysPressed.contains(LogicalKeyboardKey.arrowLeft) &&
          !keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        stopMovement();
      }
    }
    return true;
  }

  // 左移動
  void moveLeft() {
    velocity.x = -moveSpeed;
    if (animation != leftAnimation) {
      animation = leftAnimation;
    }
  }

  // 右移動
  void moveRight() {
    velocity.x = moveSpeed;
    if (animation != rightAnimation) {
      animation = rightAnimation;
    }
  }

  // ストップ
  void stopMovement() {
    velocity.x = 0;
    if (leftflg) {
      animation = stop_leftAnimation;
    }
    if (rightflg) {
      animation = stop_rightAnimation;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (position.x < size.x / 2) {
      position.x = size.x / 2;
    }

    //⭐️追加
    if (position.x > FIELD_SIZE_X - size.x / 2) {
      position.x = FIELD_SIZE_X - size.x / 2;
    }

    //ポジションを変える
    position += velocity * dt;
  }
}


```

**【crane_game.dart】**

```dart

import 'package:flame/input.dart'; //⭐️追加

//省略

bool leftflg = false; //⭐️
bool rightflg = false; //⭐️

// ⭐️HasKeyboardHandlerComponents追加
class CraneGame extends Forge2DGame with HasKeyboardHandlerComponents {
  CraneGame() : super(gravity: Vector2(0, 10.0)); // 下向き重力

  final math.Random _rng = math.Random();
  bool _droppedOnce = false;
  late final Seesaw _seesaw;
  late final Player _player; //⭐️追加

  //省略

  Future<void> onLoad() async {
    
    final seesawData = seesawList[0];
    _seesaw = Seesaw(seesawData);
    await add(_seesaw);

    //⭐️追加
    _player = Player();
    add(_player);

    Box _box1 = Box(boxList[0]);
    add(_box1);

    Box _box2 = Box(boxList[1]);
    add(_box2);

    //省略
  }

  //省略

}

```