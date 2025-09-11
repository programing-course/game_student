# **06_エフェクト表示2**


**【player.dart】**

```dart

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; //⭐️追加
import 'game.dart';
import 'setting.dart';

class Player extends SpriteComponent
    with HasGameRef<MainGame>, KeyboardHandler {
  //速度の指定
  Vector2 velocity = Vector2.zero();
  //移動速度
  double moveSpeed = 200;
  //ジャンプ力
  double jumpForce = 500;

  //歩数計算
  int stepsTaken = 0;
  //移動距離
  double distanceMoved = 0.0;
  //一歩の距離
  final double stepDistance = 16.0;

  //⭐️ バトル中は Player 自身のキーボードを無効化
  bool keyboardEnabled = true;

  //⭐️ 選択中の見た目用
  bool isSelected = false;

  //⭐️
  int maxHp = 100;
  int hp = 100;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('ika2.png');
    size = Vector2(PLAYER_SIZE_X, PLAYER_SIZE_Y);
    // position = Vector2(100, 100);
    anchor = Anchor.center;
    priority = 10;
  }

  @override
  bool onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (scene != "battle") {
      if (event is KeyDownEvent) {
        //⭐️ バトル中 or 無効化時は Player 側で入力を処理しない
        if (!keyboardEnabled || scene == "battle") return false;

        //左矢印押した時
        if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
          moveLeft();
          //右矢印押した時
        } else if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
          moveRight();
          //上
        } else if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
          moveUp();
          // 下
        } else if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
          moveDown();
        }
      } else if (event is KeyUpEvent) {
        stopMovement();
      }
    }

    return true;
  }

  //省略

  //⭐️ ====== 攻撃 ======
  void attack() {
    gameRef.EffectRemove();
  }

  //⭐️ ====== 敵のダメージ ======
  void takeDamage(int damage) {
    hp = (hp - damage).clamp(0, maxHp);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 移動前の位置を記録
    final oldPosition = position.clone();

    // 現在の移動を反映
    position += velocity * dt;

    // 移動距離を加算
    distanceMoved += (position - oldPosition).length;

    // 歩数カウント処理d
    if (distanceMoved >= stepDistance) {
      int steps = (distanceMoved / stepDistance).floor();
      stepsTaken += steps;
      distanceMoved -= steps * stepDistance;

      // 100歩到達で戦闘シーンに遷移
      if (stepsTaken >= 100) {
        print("100歩進んだ");
        stepsTaken = 0;
        //⭐️ gameRef.AllRemove();
        //⭐️ scene = "battle";
        //⭐️ gameRef.objectRemove();
      }
    }

    //⭐️ position += velocity * dt;
  }

  //⭐️追加
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 選択中の枠表示
    if (isSelected) {
      final rect = size.toRect();
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(rect, paint);
    }
  }
```

**【game.dart】**

```dart

import 'package:flutter/services.dart'; //⭐️追加


//⭐️変数追加↓
Player? player1;
Player? player2;
int selectedIndex = 0; // 0: player1, 1: player2
bool _battleInitialized = false;

Player get selectedPlayer => (selectedIndex == 0 ? player1 : player2)!;

void _updateSelection(int idx) {
  selectedIndex = idx;
  if (player1 != null) player1!.isSelected = (idx == 0);
  if (player2 != null) player2!.isSelected = (idx == 1);
}
//⭐️追加↑

// ⭐️KeyboardEvents追加
class MainGame extends FlameGame
    with HasKeyboardHandlerComponents, KeyboardEvents {
  final BuildContext context;
  MainGame(this.context);

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

        //⭐️追加
        player1 = Player()
          ..keyboardEnabled = false
          ..position = Vector2(SCREENSIZE_X / 2 + 100, SCREENSIZE_Y - 200);

        player2 = Player()
          ..keyboardEnabled = false
          ..position = Vector2(SCREENSIZE_X / 2 + 400, SCREENSIZE_Y - 200);

        await world.add(player1!);
        await world.add(player2!);

        _updateSelection(0); // 最初は1Pを選択状態に
        //⭐️追加

        HpBar _Hp = HpBar(Hplist[0]);
        await world.add(_Hp);
        SpBar _Sp = SpBar(Hplist[1]);
        await world.add(_Sp);

        Button _button1 = Button(Buttonlist[0]);
        await world.add(_button1);

        Button _button2 = Button(Buttonlist[1]);
        await world.add(_button2);

        Button _button3 = Button(Buttonlist[2]);
        await world.add(_button3);

        // ⭐️コメントアウト
        // Effect _effect = Effect(Effectlist[0]);
        // await world.add(_effect);

        // Effect _effect1 = Effect(Effectlist[1]);
        // await world.add(_effect1);

        // Effect _effect2 = Effect(Effectlist[2]);
        // await world.add(_effect2);

        // SpriteEffect _effect3 = SpriteEffect(Effectlist[3]);
        // await world.add(_effect3);

        // SpriteEffect _effect4 = SpriteEffect(Effectlist[4]);
        // await world.add(_effect4);

        CameraOn = false;
        _battleInitialized = true;

        break;
      default:
    }

    //⭐️追加
    Future<void> EffectRemove() async {
      SpriteEffect _effect3 = SpriteEffect(Effectlist[3]);
      await world.add(_effect3);

      SpriteEffect _effect4 = SpriteEffect(Effectlist[4]);
      await world.add(_effect4);
    }

    @override
    void update(double dt) {
      super.update(dt);

      //⭐️ === battle中はカメラ固定＆境界処理スキップ ===
      if (scene == "battle") {
        // カメラは固定位置に（既存の else ブロックと同等）
        cameraComponent.viewfinder.position = Vector2(VIEW_X_START, VIEW_Y_START);
        cameraComponent.update(dt);
        return;
      }
    }

    @override
    KeyEventResult onKeyEvent(
        KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
      if (scene == "battle" && _battleInitialized) {
        if (event is KeyDownEvent) {
          // 数字キーで選択切替
          if (keysPressed.contains(LogicalKeyboardKey.digit1)) {
            _updateSelection(0);
          } else if (keysPressed.contains(LogicalKeyboardKey.digit2)) {
            _updateSelection(1);
            // Eキーで攻撃
          } else if (keysPressed.contains(LogicalKeyboardKey.keyE)) {
            selectedPlayer.attack();
          }
        }
        // battle中はここで完結
        return KeyEventResult.handled;
      }

      // それ以外（フィールド等）は従来通り（Player 側の KeyboardHandler に流す）
      return super.onKeyEvent(event, keysPressed);
    }
  }

```

