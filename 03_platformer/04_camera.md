# **04_カメラの追従**
（目安：1回）

## **この単元でやること**

1. カメラコンポーネントの追加
2. 追従位置の調整

## **1. カメラコンポーネントの追加**

![camera](img/04_camera1-1.png)

**①カメラコンポーネントの設定**

**【game.dart】**

```dart

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/input.dart';
import 'package:flame/camera.dart'; //⭐️追加
import 'package:flame/components.dart'; //⭐️追加

class MainGame extends FlameGame with HasKeyboardHandlerComponents {
  final BuildContext context;
  MainGame(this.context);

  // カメラコンポーネントの追加
  late final CameraComponent cameraComponent; //⭐️追加
  Player player = Player(); //⭐️追加

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    screenSize = size;
  }


@override
  Future<void> onLoad() async {
    super.onLoad();

    //⭐️ worldの一部を切り取ってカメラに表示する
    cameraComponent = CameraComponent(
      world: world,
    );
    //⭐️
    await add(cameraComponent);

    await objectRemove();
  }

```

**②worldにオブジェクトをaddするように変更**

今まで表示していたフィールド(world)の上にカメラフィールドが重なっているので、オブジェクトをworldにaddする

※フィールドが１つの場合はworldを省略できる

**【game.dart】**

```dart

  // オブジェクトを作る関数
  Future<void> objectRemove() async {
    // ⭐️
    await CameraRemove();

    //⭐️ 背景（worldを追加）
    CameraBackScreen backscreen = CameraBackScreen();
    await world.add(backscreen);
    //⭐️  地面（worldを追加）
    Cameraground ground = Cameraground();
    await world.add(ground);
    //⭐️ プレイヤー（インスタンスをグローバルに設定）
    player = Player();
    await world.add(player);
  }

```

**③カメラの基準値を設定**

**【game.dart】**

objectRemove()の下に追加

```dart
import 'setting.dart'; //⭐️追加

//省略

//⭐️ カメラの設定位置（objectRemove()関数の下に追加）
Future<void> CameraRemove() async {
viewfinder.anchor =
    Anchor(CAMERA_POSITION_X, CAMERA_POSITION_Y);

cameraComponent.viewport = FixedSizeViewport(size.x, size.y);
}

@override
  void update(double dt) {
    super.update(dt);

    //⭐️カメラの追従
    cameraComponent.viewfinder.position =
        Vector2(player.position.x, Y_GROUND_POSITION);

    cameraComponent.update(dt);
  }


```

**【setting.dart】**

```dart

final CAMERA_POSITION_X = 0.3; //⭐️追加
final CAMERA_POSITION_Y = 0.8; //⭐️追加

```

![camera](img/04_camera1-2.png)


|  コンポーネント  |  説明  | 使用方法  |
| :---- | :---- | ---- |
| viewfinder.anchor | カメラの中心位置 | 追従するオブジェクトを表示させたい場所に指定
| viewfinder.position | カメラの中心をどこに追従させるか |  Playerのpositionに指定

![camera](img/04_camera1-3.png)

## **2. 追従位置の調整**

カメラの追従範囲に入ってから追従させる


![camera](img/04_camera1-4.png)

**【setting.dart】**

```dart

final VIEW_X_START = screenSize.x * CAMERA_POSITION_X;
final VIEW_X_END = FIELD_SIZE_X - screenSize.x * (1 - CAMERA_POSITION_X);


```

**【game.dart】**

```dart

if (player.position.x > VIEW_X_START && player.position.x < VIEW_X_END) {
      print("player追従");
      //プレイヤーに追従する
      cameraComponent.viewfinder.position =
          Vector2(player.position.x, Y_GROUND_POSITION);
    } else {
      if (player.position.x > VIEW_X_END) {
        // 範囲外になったら追従しない
        cameraComponent.viewfinder.position =
            Vector2(VIEW_X_END, Y_GROUND_POSITION);
      } else {
        // 範囲まで追従しない
        cameraComponent.viewfinder.position =
            Vector2(VIEW_X_START, Y_GROUND_POSITION);
      }
    }


```

実行してプレーヤーを右に動かそう  
途中から動いているように見えない・・・

**背景をグラデーションにして動いていることを確認**

**【player.dart】**

```dart

@override
void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final paint = Paint()
    ..shader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
        Color.fromARGB(255, 0, 149, 119),
        Color.fromARGB(255, 203, 249, 240)
    ], // 好きな色に変更
    ).createShader(rect);

    canvas.drawRect(rect, paint);
}

```
