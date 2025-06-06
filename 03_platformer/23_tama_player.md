# **23_弾を出す**

## **この単元でやること**

1. プレーヤーから弾を出す
2. 効果音をつける

## **1. プレーヤーから弾を出す**

![tama](img/23_tama1-1.png)
![tama](img/23_tama1-2.png)

### **①位置データを作成**

**【setting.dart】**

新しくTamaDataをつくる

```dart

class TamaData {
  final int idx;
  final Color color;
  final double radius;
  final double pos_x;
  final double pos_y;
  final double velocity_x;
  final double velocity_y;
  final double gravity;
  final String background_img;

  TamaData({
    required this.idx,
    required this.color,
    required this.radius,
    required this.pos_x,
    required this.pos_y,
    required this.velocity_x,
    required this.velocity_y,
    required this.gravity,
    required this.background_img,
  });
}

List<TamaData> TamaDatalist = [
  TamaData(
    idx: 0,
    color: Color.fromARGB(255, 255, 174, 0),
    radius: 10,
    pos_x: 0,
    pos_y: 0,
    velocity_x: 500,
    velocity_y: 300,
    gravity: 800,
    background_img: "", //SpriteComponent使う場合
  )
];

```

### **②オブジェクト作成**

**【tama.dart】新規作成**

```dart

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'game.dart';
import 'setting.dart';

class Playertama extends CircleComponent
    with HasGameRef<MainGame>, KeyboardHandler, CollisionCallbacks {
  Playertama(this.data);
  final TamaData data;

  Vector2 velocity = Vector2.zero();
  double speed_x = 0;
  double speed_y = 0;

  @override
  Future<void> onLoad() async {
    //①プレーヤーの位置から発射する
    position = Vector2(gameRef.player.position.x, gameRef.player.position.y);
    radius = data.radius;
    paint = Paint()..color = data.color;
    await add(CircleHitbox(radius: data.radius));
    await super.onLoad();
  }

  @override
  void update(double delta) {

    // ②斜め上に飛ばす
    speed_x = data.velocity_x;
    speed_y = -data.velocity_y;

    // ③重力加速度をY方向速度に加算
    speed_y += data.gravity * delta;

    // 位置を更新
    position.x += speed_x * delta;
    position.y += speed_y * delta;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
  }
}

```

このままだと斜め上に飛んでいってしまう・・・  

**【tama.dart】**

```dart

class Playertama extends CircleComponent
    with HasGameRef<MainGame>, KeyboardHandler, CollisionCallbacks {
  Playertama(this.data);
  final TamaData data;

  Vector2 velocity = Vector2.zero();
  double speed_x = 0;
  double speed_y = 0;
  double bounceFactor = 0.7; //⭐️追加
  bool hasFired = false;  //⭐️追加

  @override
  Future<void> onLoad() async {
    //①プレーヤーの位置から発射する
    position = Vector2(gameRef.player.position.x, gameRef.player.position.y);
    radius = data.radius;
    paint = Paint()..color = data.color;
    await add(CircleHitbox(radius: data.radius));
    await super.onLoad();
  }

  @override
  void update(double delta) {

    // ⭐️斜め上に飛ばす（最初だけ）
    if (!hasFired) {
      speed_x = data.velocity_x;
      speed_y = -data.velocity_y;
      hasFired = true;
    }

    // ③重力加速度をY方向速度に加算
    speed_y += data.gravity * delta;

    // 位置を更新
    position.x += speed_x * delta;
    position.y += speed_y * delta;

  }

}

```

地面でバウンドさせる  

**【tama.dart】**

```dart

class Playertama extends CircleComponent
    with HasGameRef<MainGame>, KeyboardHandler, CollisionCallbacks {
  
  //省略

  @override
  void update(double delta) {

    // 斜め上に飛ばす（最初だけ）
    if (!hasFired) {
      speed_x = data.velocity_x;
      speed_y = -data.velocity_y;
      hasFired = true;
    }

    // ③重力加速度をY方向速度に加算
    speed_y += data.gravity * delta;

    // 位置を更新
    position.x += speed_x * delta;
    position.y += speed_y * delta;

    // ⭐️④地面でバウンド
    if (position.y >= Y_GROUND_POSITION) {
      position.y = Y_GROUND_POSITION; // 地面に位置を補正
      speed_y = -speed_y * bounceFactor; // 反発上へ少しスピードを落とす

      if (speed_y.abs() < 50) {
        speed_y = 0;
      }
    }

    // ⭐️枠外に行ったら消す
    if (position.y < 0 ||
        position.x < 0 ||
        position.x > FIELD_SIZE_X ||
        position.y > FIELD_SIZE_Y) {
      removeFromParent();
    }
  }

}

```

左を向いても右にでてしまう・・・  
左右に出るようにする

**【player.dart】**  

方向フラグをグローバル変数にする player.dartからgame.dartに移す

```dart

class Player extends SpriteAnimationComponent
    with HasGameRef<MainGame>, KeyboardHandler, CollisionCallbacks {
  
  //省略

  //各方向のスプライト
  late SpriteAnimation leftAnimation;
  late SpriteAnimation rightAnimation;
  late SpriteAnimation stop_leftAnimation;
  late SpriteAnimation stop_rightAnimation;

  //⭐️方向フラグ　コメントアウト
  // bool leftflg = false;
  // bool rightflg = false;

  //省略

```

**【game.dart】**

```dart

//省略

//最高記録
double recordTime = 0.0;
// ステージ管理
int currentStage = 0;
// 弾を出す
bool ptama = false;
// ⭐️ここに移動
bool leftflg = false;
bool rightflg = false;

TimerComponent? timerComponent;

class MainGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {

//省略

```

**【tama.dart】**

```dart

void update(double delta) {

    if (!hasFired) {
        //⭐️左右の判定
        if (leftflg) {
          speed_x = -data.velocity_x;
          speed_y = -data.velocity_y;
        } else if (rightflg) {
          speed_x = data.velocity_x;
          speed_y = -data.velocity_y;
        }
      hasFired = true;
    }

    //省略
  }

```

障害物に当たったら消す  
敵に当たったら消す　敵も消す

```dart

@override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    //⭐️障害物に当たったら消す
    if (other is triangle) {
      removeFromParent();
    }

    //⭐️敵に当たったら消す
    if (other is Teki) {
      removeFromParent();
      other.removeFromParent();
    }
  }


```


