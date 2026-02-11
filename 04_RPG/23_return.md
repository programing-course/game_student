# **23_return**

**①バトルフィールドからの戻り**

**【player.dart】**

```dart

Future<void> attack({int personaPower = 1}) async {
  //省略

    if (enemy == null || enemy.currentHp <= 0) {
      //⭐️追加
      await _announce('敵を倒した');
      gameRef.AllRemove();
      scene = "main";
      CameraOn = true;
      gameRef.objectRemove();
      return;
    }

    _updateSelection(0);

    await _announce('敵の攻撃');

    await Future.delayed(const Duration(seconds: 1));

    await _queueEnemyCounter();

    await Future.delayed(const Duration(seconds: 3));

    _updateSelection(1);
    await _announce('敵の攻撃');
    await Future.delayed(const Duration(seconds: 1));

    await _queueEnemyCounter();

    gameRef.AllRemove();
    scene = "main";
    CameraOn = true;  //⭐️追加
    gameRef.objectRemove();
  }

```

**②飛んだ場所に戻る**

**【game.dart】**

```dart

bool isPlayerActing = false;
bool isGuarding = false;

//⭐️追加
Vector2 PlayerPosition = Vector2.zero();


//省略

switch (scene) {
  case "main":
    for (int i = 0; i < 1; i++) {
      BackScreenImg _backscreenimg = BackScreenImg(BackGroundlist[1], i);
      await world.add(_backscreenimg);
    }
    player = Player("player1", PlayerList[0])
      ..position = Vector2(PlayerPosition.x, PlayerPosition.y); //⭐️追加

    await world.add(player);
    for (final itemData in FieldItemList) {
      if (itemInventory.containsKey(itemData.id)) continue;

      await world.add(FieldItem(itemData));
    }

    break;
  case "battle"

    //省略
}

//省略

    if (keysPressed.contains(LogicalKeyboardKey.keyE)) {
      _persona ??= Persona();
      world.add(_persona!); //⭐️world追加
      print("Persona added");
      return KeyEventResult.handled;
    }


```

**【player.dart】**

```dart

    if (distanceMoved >= stepDistance) {
      int steps = (distanceMoved / stepDistance).floor();
      stepsTaken += steps;
      distanceMoved -= steps * stepDistance;

      // 百歩で戦闘シーン
      if (stepsTaken >= 100) {
        print("100歩進んだ");
        stepsTaken = 0;
        PlayerPosition = Vector2(this.x, this.y); //⭐️追加
        gameRef.spawnEnemy();
        gameRef.AllRemove();
        scene = "battle";
        gameRef.objectRemove();
      }
    }

```
