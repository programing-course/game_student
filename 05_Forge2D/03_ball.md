# **03_ボールを表示**

**①データ設定**

**【setting.dart】**

```dart

class BallData {
  final int idx;
  final Color color;
  final double pos_x; // world 座標
  final double pos_y; // world 座標
  final double radius; // 半径（world 座標）
  final double density; // 密度
  final double gravityScale; // 1.0 で通常重力
  final double friction; // 摩擦
  final double restitution; // 反発
  final String item_img; // 将来スプライトで使う場合に利用

  const BallData({
    required this.idx,
    required this.color,
    required this.pos_x,
    required this.pos_y,
    required this.radius,
    required this.density,
    required this.gravityScale,
    required this.friction,
    required this.restitution,
    required this.item_img,
  });
}

const List<BallData> ballList = [
  BallData(
    idx: 0,
    color: Colors.red,
    pos_x: 80,
    pos_y: 40,
    radius: 8.0,
    density: 10.0,
    gravityScale: 1.0,
    friction: 0.4,
    restitution: 0.6, // よく弾む
    item_img: "",
  ),
  BallData(
    idx: 1,
    color: Colors.blue,
    pos_x: 200,
    pos_y: 40,
    radius: 12.0,
    density: 20.0,
    gravityScale: 1.5,
    friction: 0.3,
    restitution: 0.8, // さらに弾む
    item_img: "",
  ),
];


```

**【ball.dart】**

```dart

// ball.dart
import 'dart:ui';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'setting.dart';

class Ball extends BodyComponent {
  Ball(this.data);
  final BallData data;

  @override
  Body createBody() {
    // 物体の基本設定
    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = Vector2(data.pos_x, data.pos_y)
      ..fixedRotation = false; // 回転させたい場合は false（デフォルト）

    // 円形 Shape（半径は world 座標）
    final shape = CircleShape()..radius = data.radius;

    // 物性（密度・摩擦・反発）
    final fixtureDef = FixtureDef(shape)
      ..density = data.density
      ..friction = data.friction
      ..restitution = data.restitution;

    // world に登録
    final body = world.createBody(bodyDef)..createFixture(fixtureDef);
    return body;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // 可変重力（Box と同じロジック）
    if (data.gravityScale != 1.0) {
      final g = world.gravity;
      final m = body.mass;
      final extraForce = g.clone()..scale((data.gravityScale - 1.0) * m);
      body.applyForce(extraForce, point: body.worldCenter);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // 中心を原点として円を描く
    final paint = Paint()..color = data.color;
    canvas.drawCircle(Offset.zero, data.radius, paint);
  }
}



```

**【crane_game.dart】**

```dart

import 'package:flame_forge2d/flame_forge2d.dart';
import 'ground.dart';
import 'box.dart';
import 'setting.dart';
import 'ball.dart'; //⭐️追加

late Vector2 screenSize;

class CraneGame extends Forge2DGame {
  CraneGame() : super(gravity: Vector2(0, 10.0));

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    screenSize = size;
  }

  @override
  Future<void> onLoad() async {
    add(Ground());
    //add(Box(Vector2(50, 50)));

    Box _box1 = Box(boxList[0]);
    add(_box1);

    Box _box2 = Box(boxList[1]);
    add(_box2);

    Ball _ball = Ball(ballList[0]);
    add(_ball);
  }
}



```