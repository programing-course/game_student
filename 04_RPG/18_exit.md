# **18_exit**

**①バトル終了後フィールドに戻る**

**【player.dart】**

```dart

  Future<void> attack({int personaPower = 1}) async {
    //省略

    _updateSelection(0);
    await _announce('敵の攻撃');

    await Future.delayed(const Duration(seconds: 1));

    //　⭐️await追加
    await _queueEnemyCounter();

    await Future.delayed(const Duration(seconds: 3));

    _updateSelection(1);
    await _announce('敵の攻撃');
    await Future.delayed(const Duration(seconds: 1));

    //　⭐️await追加
    await _queueEnemyCounter();

    //　⭐️追加
    gameRef.AllRemove();
    scene = "main";
    CameraOn = true;
    gameRef.objectRemove();
  }

  //⭐️void→Future<void>に修正
  Future<void> _queueEnemyCounter() async {
    //省略
  }

  //省略

  void update(double dt) {
    super.update(dt);

    // 移動前の位置を記録
    final oldPosition = position.clone();

    // 現在の移動を反映
    position += velocity * dt;

    // 移動距離を加算
    distanceMoved += (position - oldPosition).length;

    // 歩数カウント処理
    if (distanceMoved >= stepDistance) {
      int steps = (distanceMoved / stepDistance).floor();
      stepsTaken += steps;
      distanceMoved -= steps * stepDistance;

      // 百歩で戦闘シーン
      if (stepsTaken >= 100) {
        print("100歩進んだ");
        stepsTaken = 0;
        //⭐️コメントアウト復活
        gameRef.AllRemove();
        scene = "battle";
        gameRef.objectRemove();
      }
    }

    //ポジションを変える
    // position += velocity * dt;
  }


```