# **13_save**

**【pabspeck.yaml】**

```dart

shared_preferences: ^2.5.3

```

**【game.dart】**

```dart

switch (scene) {
      case "main":
        player = Player("player1", PlayerList[0]);//⭐️
        await world.add(player);
        break;
      case "battle":
      
        player1 = Player("player1", PlayerList[0])//⭐️
          ..keyboardEnabled = false
          ..position = Vector2(SCREENSIZE_X / 2 + 100, SCREENSIZE_Y - 200);

        player2 = Player("player2", PlayerList[1])//⭐️
          ..keyboardEnabled = false
          ..position = Vector2(SCREENSIZE_X / 2 + 400, SCREENSIZE_Y - 200);

        await world.add(player1!);
        await world.add(player2!);

        player1.loadStatus();
        player2.loadStatus();

        player1.add(HpBar(
          target: player1,
          barSize: Vector2(70, 10),
          offset: Vector2(0, -PLAYER_SIZE_Y / 2 - 12),
        ));
        player1.add(SpBar(
          target: player1,
          barSize: Vector2(70, 8),
          offset: Vector2(0, -PLAYER_SIZE_Y / 2), // HPのすぐ下あたり
        ));
        player2.add(HpBar(
          target: player2,
          barSize: Vector2(70, 10),
          offset: Vector2(0, -PLAYER_SIZE_Y / 2 - 12),
        ));
        player2.add(SpBar(
          target: player2,
          barSize: Vector2(70, 8),
          offset: Vector2(0, -PLAYER_SIZE_Y / 2),
        ));
        player1.add(LvLabel(
          target: player1,
          offset: Vector2(0, -PLAYER_SIZE_Y / 2 - 24),
        ));

        player2.add(LvLabel(
          target: player2,
          offset: Vector2(0, -PLAYER_SIZE_Y / 2 - 24),
        ));

        _updateSelection(0);

        Button _button1 = Button(Buttonlist[0]);
        await world.add(_button1);

        Button _button2 = Button(Buttonlist[1]);
        await world.add(_button2);

        Button _button3 = Button(Buttonlist[2]);
        await world.add(_button3);

        //⭐️ final enemydata = randomEnemy();
        //⭐️ final teki = Teki(enemydata);
        //⭐️ currentEnemy = teki;
        //⭐️ await world.add(teki);

        spawnEnemy();

        CameraOn = false;
        _battleInitialized = true;

        break;
      default:
    }

    //省略

    //⭐️ 追加
    Future<void> spawnEnemy() async {
      final teki = await Teki.loadOrRandom();
      currentEnemy = teki;
      await world.add(teki);
    }

```

**【player.dart】**


```dart

class Player extends SpriteAnimationComponent
    with HasGameRef<MainGame>, KeyboardHandler
    implements HealthProvider, SpProvider, LevelProvider {
  Player(this.id, this.data); //⭐️
  final CharacterData data;
  final String id; //⭐️


  //省略


  void _queueEnemyCounter() async {
    Future.delayed(const Duration(seconds: 1), () {
      if (scene != "battle") return;
      if (!isMounted) return;

      gameRef.EffectRemove_player();
      const damage = 12;
      selectedPlayer.applyDamage(damage);
      selectedPlayer.hitShake();

      selectedPlayer.savePlayerStatus();//⭐️
    });
  }

  //省略

  if (stepsTaken >= 100) {
    print("100歩進んだ");
    stepsTaken = 0;
    gameRef.spawnEnemy();//⭐️
    // gameRef.AllRemove();
    // scene = "battle";
    // gameRef.objectRemove();
  }

  //⭐️下に追加

  Future<void> savePlayerStatus() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('${id}_hp', hp);
    await prefs.setInt('${id}_sp', sp);
    await prefs.setInt('${id}_lv', lv);
    await prefs.setInt('${id}_exp', exp);
  }

  Future<void> loadStatus() async {
    final prefs = await SharedPreferences.getInstance();

    hp = prefs.getInt('${id}_hp') ?? maxHp;
    sp = prefs.getInt('${id}_sp') ?? maxSp;
    lv = prefs.getInt('${id}_lv') ?? 1;
    exp = prefs.getInt('${id}_exp') ?? 0;
  }

```

**【teki.dart】**

```dart



```
