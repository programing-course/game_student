# **ゲージを作る**


**【setting.dart】**

```dart

class HpData {
  final int idx;
  final Color color1;
  final Color color2;
  final double size_x;
  final double size_y;
  final double pos_x;
  final double pos_y;
  final String background_img;

  HpData({
    required this.idx,
    required this.color1,
    required this.color2,
    required this.size_x,
    required this.size_y,
    required this.pos_x,
    required this.pos_y,
    required this.background_img,
  });
}

List<HpData> Hplist = [
  HpData(
    idx: 0,
    color1: Color.fromARGB(255, 255, 190, 130),
    color2: Color.fromARGB(255, 255, 255, 255),
    size_x: 200.0,
    size_y: 30.0,
    pos_x: SCREENSIZE_X / 2,
    pos_y: SCREENSIZE_Y - 150,
    background_img: "",
  ),
  HpData(
    idx: 0,
    color1: Color.fromARGB(255, 130, 176, 255),
    color2: Color.fromARGB(255, 255, 255, 255),
    size_x: 200.0,
    size_y: 30.0,
    pos_x: SCREENSIZE_X / 2,
    pos_y: SCREENSIZE_Y - 100,
    background_img: "",
  ),
];


```

**【ui.dart】**

```dart

import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'game.dart';
import 'setting.dart';

class HpBar extends RectangleComponent with HasGameRef<MainGame> {
  HpBar(this.data);
  final HpData data;

  @override
  Future<void> onLoad() async {
    position = Vector2(data.pos_x, data.pos_y);
    size = Vector2((PlayerHP * data.size_x / 10).toDouble(), data.size_y);
    paint = Paint()..color = data.color1;
    priority = 1000;
  }

  void renderHpBarButton(Canvas canvas) {
    final rect = Rect.fromLTWH(
      0,
      0,
      data.size_x,
      data.size_y,
    );
    final bgPaint = Paint()..color = data.color2;
    canvas.drawRect(rect, bgPaint);
  }

  @override
  void render(Canvas canvas) async {
    renderHpBarButton(canvas);
    super.render(canvas);
  }
}

class SpBar extends RectangleComponent with HasGameRef<MainGame> {
  SpBar(this.data);
  final HpData data;

  @override
  Future<void> onLoad() async {
    position = Vector2(data.pos_x, data.pos_y);
    size = Vector2((PlayerSP * data.size_x / 10).toDouble(), data.size_y);
    paint = Paint()..color = data.color1;
    priority = 1000;
  }

  void renderHpBarButton(Canvas canvas) {
    final rect = Rect.fromLTWH(
      0,
      0,
      data.size_x,
      data.size_y,
    );
    final bgPaint = Paint()..color = data.color2;
    canvas.drawRect(rect, bgPaint);
  }

  @override
  void render(Canvas canvas) async {
    renderHpBarButton(canvas);
    super.render(canvas);
  }
}


```

**【game.dart】**

```dart

double PlayerHP = 10;
double PlayerSP = 10;

bool CameraOn = true;

//省略

Future<void> objectRemove() async {
    await CameraRemove();

    // CameraBackScreen backscreen = CameraBackScreen();
    // await world.add(backscreen);

    print("===scene===${scene}");
    switch (scene) {
      case "main":
        for (int i = 0; i < 1; i++) {
          BackScreenImg _backscreenimg = BackScreenImg(BackGroundlist[1], i);
          await world.add(_backscreenimg);
        }

        player = Player();
        await world.add(player);

        CameraOn = true;

        break;
      case "battle":
        CameraBackScreen _backscreenimg = CameraBackScreen(BackGroundlist[2]);
        await world.add(_backscreenimg);

        player = Player();
        await world.add(player);

        HpBar _Hp = HpBar(Hplist[0]);
        await world.add(_Hp);
        SpBar _Sp = SpBar(Hplist[1]);
        await world.add(_Sp);

        CameraOn = false;

        break;
      default:
    }
  }

void update(double dt) {
    super.update(dt);

    print("===CameraOn===${CameraOn}");
    //⭐️カメラの追従するかしないか追加
    if (CameraOn && player.isMounted) {
      if (player.position.x <= VIEW_X_START &&
          player.position.y <= VIEW_Y_START) {
        //左上
        cameraComponent.viewfinder.position =
            Vector2(VIEW_X_START, VIEW_Y_START);
      } else if (player.position.x < VIEW_X_START &&
          player.position.y > VIEW_Y_START &&
          player.position.y < VIEW_Y_END) {
        //左真ん中
        cameraComponent.viewfinder.position =
            Vector2(VIEW_X_START, player.position.y);
      } else if (player.position.x <= VIEW_X_START &&
          player.position.y >= VIEW_Y_END) {
        //左下
        cameraComponent.viewfinder.position = Vector2(VIEW_X_START, VIEW_Y_END);
      } else if (player.position.x >= VIEW_X_END &&
          player.position.y <= VIEW_Y_START) {
        // 右上
        cameraComponent.viewfinder.position = Vector2(VIEW_X_END, VIEW_Y_START);
      } else if (player.position.x > VIEW_X_END &&
          player.position.y > VIEW_Y_START &&
          player.position.y < VIEW_Y_END) {
        // 右真ん中
        cameraComponent.viewfinder.position =
            Vector2(VIEW_X_END, player.position.y);
      } else if (player.position.x >= VIEW_X_END &&
          player.position.y >= VIEW_Y_END) {
        // 右下
        cameraComponent.viewfinder.position = Vector2(VIEW_X_END, VIEW_Y_END);
      } else if (player.position.x > VIEW_X_START &&
          player.position.x < VIEW_X_END &&
          player.position.y <= VIEW_Y_START) {
        // 真ん中上
        cameraComponent.viewfinder.position =
            Vector2(player.position.x, VIEW_Y_START);
      } else if (player.position.x > VIEW_X_START &&
          player.position.x < VIEW_X_END &&
          player.position.y > VIEW_Y_START &&
          player.position.y < VIEW_Y_END) {
        // 真ん中の真ん中
        cameraComponent.viewfinder.position =
            Vector2(player.position.x, player.position.y);
      } else if (player.position.x > VIEW_X_START &&
          player.position.x < VIEW_X_END &&
          player.position.y >= VIEW_Y_END) {
        // 真ん中の真ん中
        cameraComponent.viewfinder.position =
            Vector2(player.position.x, VIEW_Y_END);
      }
    //⭐️
    } else {
      cameraComponent.viewfinder.position = Vector2(VIEW_X_START, VIEW_Y_START);
    }

    //端に来たら止まる
    if (player.position.x < player.size.x / 2) {
      player.position.x = player.size.x / 2;
    }

    if (player.position.x > FIELD_SIZE_X - player.size.x / 2) {
      player.position.x = FIELD_SIZE_X - player.size.x / 2;
    }

    if (player.position.y < player.size.y / 2) {
      player.position.y = player.size.y / 2;
    }

    if (player.position.y > FIELD_SIZE_Y - player.size.y / 2) {
      player.position.y = FIELD_SIZE_Y - player.size.y / 2;
    }

    cameraComponent.update(dt);
  }

```
