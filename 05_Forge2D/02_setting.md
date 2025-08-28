# **02_データセット**

**①データ設定**

**【setting.dart】**

```dart

import 'package:flutter/material.dart';
import 'crane_game.dart';

final FIELD_SIZE_X = screenSize.x;
final FIELD_SIZE_Y = screenSize.y;

//コンストラクタ
class BoxData {
  final int idx;
  final Color color;
  final double pos_x;
  final double pos_y;
  final double size_x;
  final double size_y;
  final double density;
  final double gravityScale;
  final double friction;
  final double restitution;
  final String item_img;

  BoxData(
      {required this.idx,
      required this.color,
      required this.pos_x,
      required this.pos_y,
      required this.size_x,
      required this.size_y,
      required this.density,
      required this.gravityScale,
      required this.friction,
      required this.restitution,
      required this.item_img});
}

//イニシャライザ
List<BoxData> boxList = [
  BoxData(
    idx: 0,
    color: Color.fromARGB(255, 211, 46, 46),
    pos_x: 50,
    pos_y: 50,
    size_x: 10.0,
    size_y: 10.0,
    density: 50.0,
    gravityScale: 5.0,
    friction: 0.5,
    restitution: 0.3,
    item_img: "",
  ),
  BoxData(
    idx: 1,
    color: Color.fromARGB(255, 211, 46, 46),
    pos_x: 150,
    pos_y: 50,
    size_x: 20.0,
    size_y: 20.0,
    density: 50.0,
    gravityScale: 10.0,
    friction: 0.5,
    restitution: 0.5,
    item_img: "",
  ),
];


```


**【crane_game.dart】**

```dart

import 'package:flame_forge2d/flame_forge2d.dart';
import 'ground.dart';
import 'box.dart';
import 'setting.dart'; //⭐️追加

late Vector2 screenSize; //⭐️追加

class CraneGame extends Forge2DGame {
  CraneGame() : super(gravity: Vector2(0, 10.0));

  //⭐️追加
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
  }
}



```

**【box.dart】**

```dart

import 'package:flame_forge2d/flame_forge2d.dart';
import 'dart:ui'; //⭐️追加
import 'setting.dart'; //⭐️追加

class Box extends BodyComponent {
  //⭐️final Vector2 position;
  //⭐️Box(this.position);

  Box(this.data);
  final BoxData data;

  @override
  Body createBody() {
    // bodyの種類、初期値を設定
    final bodyDef = BodyDef()
      ..type = BodyType.dynamic  //重力の影響を受けて動く static,kinematic
      ..position = Vector2(data.pos_x, data.pos_y); //⭐️

    // Boxの型を定義
    final shape = PolygonShape()..setAsBoxXY(data.size_x, data.size_y); //⭐️

    // 摩擦や密度を設定
    final fixtureDef = FixtureDef(shape)
      ..density = data.density //⭐️密度、大きいほど重くなる
      ..friction = data.friction //⭐️摩擦係数、1に近いと滑りにくい
      ..restitution = data.restitution; //⭐️反発係数（0=跳ねない, 1=完全反発）

    // worldに登録
    final body = world.createBody(bodyDef)..createFixture(fixtureDef);

    return body;
  }

   //⭐️追加
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = data.color;
    final halfWidth = data.size_x;
    final halfHeight = data.size_y;

    // 中心を原点にして四角を描画
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset.zero, width: halfWidth * 2, height: halfHeight * 2),
      paint,
    );
  }

  @override
  void update(double dt) {
    if (data.gravityScale != 1.0) {
      final g = world.gravity; // World 全体の重力ベクトル
      final m = body.mass;
      // 追加でかけたい重力 = (scale - 1) * m * g
      final extraForce = g.clone()..scale((data.gravityScale - 1.0) * m);
      body.applyForce(
        extraForce,
        point: body.worldCenter, // 必要なら起床させる（APIにある場合）
      );
    }
  }
}


```
