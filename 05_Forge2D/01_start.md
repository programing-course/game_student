# **01_クレーンゲームをつくろう**

**①ディレクトリ構成**

lib  
  -gameフォルダ  
  　--crane_game.dart  
  　--ground.dart  
  　--box.dart  
  -main.dart  

**【main.dart】**

```dart

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/crane_game.dart';

void main() {
  runApp(GameWidget(game: CraneGame()));
}



```

**【crane_game.dart】**

```dart

import 'package:flame_forge2d/flame_forge2d.dart';
import 'ground.dart';
import 'box.dart';

class CraneGame extends Forge2DGame {
  CraneGame() : super(gravity: Vector2(0, 10.0)); // 下向き重力

  @override
  Future<void> onLoad() async {
    add(Ground());
    add(Box(Vector2(50, 50))); // 位置は(x, y)
  }
}



```

**【ground.dart】**

```dart

import 'package:flame_forge2d/flame_forge2d.dart';

class Ground extends BodyComponent {
  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBoxXY(100, 1); // 幅20、高さ2

    final fixtureDef = FixtureDef(shape)..friction = 0.5;

    final bodyDef = BodyDef()
      ..position = Vector2(50, 500) // 画面下の位置
      ..type = BodyType.static;

    final body = world.createBody(bodyDef)..createFixture(fixtureDef);

    return body;
  }
}


```

**【box.dart】**

```dart

import 'package:flame_forge2d/flame_forge2d.dart';

class Box extends BodyComponent {
  final Vector2 position;

  Box(this.position);

  @override
  Body createBody() {
    // bodyの種類、初期値を設定
    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = position;

    // Boxの型を定義
    final shape = PolygonShape()..setAsBoxXY(10.0, 10.0); // 2x2の正方形

    // 摩擦や密度を設定
    final fixtureDef = FixtureDef(shape)
      ..density = 1.0
      ..friction = 0.5;

    // worldに登録
    final body = world.createBody(bodyDef)..createFixture(fixtureDef);

    return body;
  }

  @override
  void update(double dt) {
    // 毎フレーム呼ばれる（ゲームロジックを書く）
  }
}


```
