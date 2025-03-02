# **05_障害物を追加（図形を描画）**
（目安：1回）

## **この単元でやること**

1. 図形を描画してみよう
2. 複数のオブジェクトを作る
3. 当たり判定（オブジェクトを消す）ヒットボックス

## **1. 図形を描画しよう**

![object](img/05_object1-1.png)

**【game.dart】**

```dart

Future<void> objectRemove() async {
    await CameraRemove();

    //背景（worldを追加）
    CameraBackScreen backscreen = CameraBackScreen();
    await world.add(backscreen);
    //地面（worldを追加）
    Cameraground ground = Cameraground();
    await world.add(ground);
    //プレイヤー（インスタンスをグローバルに設定）
    player = Player();
    await world.add(player);

    //⭐️追加
    triangle _triangle = triangle();
    await world.add(_triangle);
}

```

**【object.dart】**

```dart

import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'game.dart';

class triangle extends RectangleComponent with HasGameRef<MainGame> {
  @override
  Future<void> onLoad() async {
    // print("triangle");
    paint = Paint()..color = Color.fromARGB(255, 211, 46, 46);

    anchor = Anchor.topCenter;
  }

  @override
  Future<void> render(Canvas canvas) async {
    super.render(canvas);
    final path = Path();
    path.moveTo(500, 400);
    path.lineTo(450, 500);
    path.lineTo(550, 500);
    path.close();
    canvas.drawPath(path, paint);

    // パスをキャンバスに描画
    canvas.drawPath(path, paint);
  }
}

```


![object](img/05_object1-2.png)

## **2. 複数のオブジェクトを作る**

![object](img/05_object2-3.png)

![object](img/05_object2-4.png)


１で作った三角形のオブジェクトは頂点の値がtriangleで指定されています  
同じような三角形を作る時、classを何個も作るのは大変

![object](img/05_object2-1.png)

<br><br><br>

**ベースになる設計図(class)を作成、描画データを設計図に渡し、オブジェクトを作成する**

![object](img/05_object2-2.png)



<br><br>

### **①データの設計図を作る**

**【setting.dart】**

三角形を作るためのデータ設計図（データクラス）

```dart

//コンストラクタ
class TriangleData {
  final int idx;
  final Color color;
  final double pos_x1;
  final double pos_y1;
  final double pos_x2;
  final double pos_y2;
  final double pos_x3;
  final double pos_y3;

  TriangleData({
    required this.idx,
    required this.color,
    required this.pos_x1,
    required this.pos_y1,
    required this.pos_x2,
    required this.pos_y2,
    required this.pos_x3,
    required this.pos_y3,
  });
}

//イニシャライザ
List<TriangleData> triangleList = [
  TriangleData(
    idx: 0,
    color: Color.fromARGB(255, 211, 46, 46),
    pos_x1: screenSize.x * 0.85,
    pos_y1: Y_GROUND_POSITION - 50,
    pos_x2: screenSize.x * 0.85 - 50,
    pos_y2: Y_GROUND_POSITION,
    pos_x3: screenSize.x * 0.85 + 50,
    pos_y3: Y_GROUND_POSITION,
  ),
  TriangleData(
    idx: 1,
    color: Color.fromARGB(255, 211, 46, 46),
    pos_x1: screenSize.x * 1.85,
    pos_y1: Y_GROUND_POSITION - 100,
    pos_x2: screenSize.x * 1.85 - 50,
    pos_y2: Y_GROUND_POSITION,
    pos_x3: screenSize.x * 1.85 + 50,
    pos_y3: Y_GROUND_POSITION,
  ),
  TriangleData(
    idx: 2,
    color: Color.fromARGB(255, 211, 46, 46),
    pos_x1: screenSize.x * 2.1,
    pos_y1: Y_GROUND_POSITION - 100,
    pos_x2: screenSize.x * 2.1 - 50,
    pos_y2: Y_GROUND_POSITION,
    pos_x3: screenSize.x * 2.1 + 50,
    pos_y3: Y_GROUND_POSITION,
  ),
];

```

### **②オブジェクトを作る　データを引数で渡す**

**【game.dart】**

作りたいオブジェクトのインデックス番号を指定する

```dart

//⭐️　引数にデータを渡す
triangle _triangle = triangle(triangleList[0]);
    await world.add(_triangle);

//⭐️ もう一つ作る
triangle _triangle1 = triangle(triangleList[1]);
    await world.add(_triangle1);
```

### **③受け取ったデータを元にオブジェクトを作る**

**【object.dart】**

```dart

import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'game.dart';
import 'setting.dart';

class triangle extends RectangleComponent with HasGameRef<MainGame> {
    //⭐️　データ受け取り
  triangle(this.data);
  final TriangleData data;

  @override
  Future<void> onLoad() async {
    // print("triangle");
    //⭐️ dataに置き換える
    paint = Paint()..color = data.color;

    anchor = Anchor.topCenter;
  }

  @override
  Future<void> render(Canvas canvas) async {
    super.render(canvas);
    final path = Path();
    //⭐️ dataに置き換える
    path.moveTo(data.pos_x1, data.pos_y1);
    path.lineTo(data.pos_x2, data.pos_y2);
    path.lineTo(data.pos_x3, data.pos_y3);
    path.close();
    canvas.drawPath(path, paint);

    // パスをキャンバスに描画
    canvas.drawPath(path, paint);
  }
}

```

<br><br>

## **3.当たり判定**

プレーヤーとオブジェクトが当たったらプレーヤーを先頭に戻す

<br><br>

**onCollision関数の流れと当たり判定の範囲Hitbox**

![object](img/05_object3-1.png)

<br><br>

![object](img/05_object3-2.png)

**【game.dart】**

```dart

// ⭐️HasCollisionDetectionをミックスイン
class MainGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {


```

**【player.dart】**

```dart

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flame/collisions.dart'; //⭐️追加
import 'game.dart';
import 'setting.dart';
import 'object.dart'; //⭐️追加

//⭐️CollisionCallbacksを追加
class Player extends SpriteAnimationComponent
    with HasGameRef<MainGame>, KeyboardHandler, CollisionCallbacks {

    //省略

    @override
    Future<void> onLoad() async {
        //省略
    
        //⭐️あたり判定範囲
        add(RectangleHitbox());
    }

    //⭐️追加（update関数の上に追加）
    @override
    // 当たった瞬間の処理（敵に当たった瞬間消える、スコアが減るなど）
    void onCollisionStart(
        Set<Vector2> intersectionPoints,
        PositionComponent other,
    ) {
        // 障害物に当たったら
        if (other is triangle) {
        // プレーヤーを消す
        removeFromParent();
        }
    }

    @override
    // 当たっている間の処理（壁に当たっている間動かないなど）
    void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {}

    @override
    // 当たり終わった時の処理
    void onCollisionEnd(PositionComponent other) {}
    //⭐️ここまで

    //省略

    //⭐️一番下に追加
    // 消えた時の処理
    @override
    Future<void> onRemove() async {
        // もう一回表示
        await gameRef.objectRemove();

        super.onRemove();
    }

}

```

**【object.dart】**

```dart

import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';//⭐️追加
import 'package:flame/components.dart';
import 'game.dart';
import 'setting.dart';

//⭐️CollisionCallbacksをミックスイン
class triangle extends RectangleComponent
    with HasGameRef<MainGame>, CollisionCallbacks {
        triangle(this.data);
  final TriangleData data;

  @override
  Future<void> onLoad() async {
    // print("triangle");
    //settingデータを設定
    paint = Paint()..color = data.color;

    anchor = Anchor.topCenter;
    
    // ⭐️当たり判定用範囲
    add(PolygonHitbox([
      Vector2(data.pos_x1, data.pos_y1),
      Vector2(data.pos_x2, data.pos_y2),
      Vector2(data.pos_x3, data.pos_y3),
    ])
      ..collisionType = CollisionType.passive);
  }

    //省略

}

```

オブジェクトに当たるとすぐに先頭に戻ってしまう・・・

### **時間差で戻る演出**

**【player.dart】**

```dart
@override
  Future<void> onLoad() async {
    //省略


    size = Vector2(PLAYER_SIZE_X, PLAYER_SIZE_Y);
    //⭐️　PLAYER_SIZE_Y / 2　→　100に変更
    position =
        Vector2(PLAYER_SIZE_X / 2, Y_GROUND_POSITION - 100);
    anchor = Anchor.center;
    priority = 10;
    add(RectangleHitbox());
  }
```