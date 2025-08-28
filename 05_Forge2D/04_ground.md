# **04_地面の設定**

**①データ設定**

**【setting.dart】**

```dart

class GroundData {
  final double pos_x; // 中心X座標
  final double pos_y; // 中心Y座標
  final double width; // 幅
  final double height; // 高さ
  final double friction; // 摩擦係数

  const GroundData({
    required this.pos_x,
    required this.pos_y,
    required this.width,
    required this.height,
    required this.friction,
  });
}

// Ground の初期設定例
const List<GroundData> groundList = [
  GroundData(
    pos_x: 350,
    pos_y: 400,
    width: 300,
    height: 10,
    friction: 0.1,
  ),
];


```

**【ground.dart】**

```dart

import 'package:flame_forge2d/flame_forge2d.dart';
import 'setting.dart';

class Ground extends BodyComponent {
  final GroundData data;//⭐️追加

  Ground(this.data);//⭐️追加

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBoxXY(data.width, data.height); //⭐️修正

    final fixtureDef = FixtureDef(shape)..friction = data.friction;⭐️修正

    final bodyDef = BodyDef()
      ..position = Vector2(data.pos_x, data.pos_y) //⭐️修正
      ..type = BodyType.static; // 地面は動かない

    final body = world.createBody(bodyDef)..createFixture(fixtureDef);
    return body;
  }
}



```

**【crane_game.dart】**

```dart

import 'package:flame_forge2d/flame_forge2d.dart';
import 'ground.dart';
import 'box.dart';
import 'setting.dart';
import 'ball.dart';

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
    //⭐️add(Ground());
    //add(Box(Vector2(50, 50)));
    
    //⭐️追加
    Ground _bround = Ground(groundList[0]);
    add(_bround);

    Box _box1 = Box(boxList[0]);
    add(_box1);

    Box _box2 = Box(boxList[1]);
    add(_box2);

    Ball _ball = Ball(ballList[0]);
    add(_ball);

    Ball _ball1 = Ball(ballList[1]);
    add(_ball1);
  }
}



```