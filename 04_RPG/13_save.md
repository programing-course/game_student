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

import 'package:shared_preferences/shared_preferences.dart';

//省略

  // ⭐️修正
  late final int _maxHp;
  int _hp = 0;

  @override
  int get currentHp => _hp;
  @override
  int get maxHp => _maxHp;

  // ⭐️Teki(this.data);
  Teki(this.data, {int? initialHp}) {
    _maxHp = data.hp;
    _hp = (initialHp ?? _maxHp).clamp(0, _maxHp);
  }

  //ランダムで呼びたいとき
  Teki.random() : data = randomEnemy();

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(data.imagePath);
    size = Vector2(TEKI_SIZE_X, TEKI_SIZE_Y);
    position = Vector2(data.pos_x, data.pos_y);
    anchor = Anchor.center;
    priority = 10;

    // ⭐️_hp = _maxHp;

    add(HpBar(
      target: this,
      barSize: Vector2(60, 8),
      offset: Vector2(0, -TEKI_SIZE_Y / 2 - 10),
    ));
  }

  void applyDamage(int dmg, {bool crit = false}) {
    _hp = (_hp - dmg).clamp(0, _maxHp);

    final parentToUse = parent ?? this;
    final worldPos = position + Vector2(0, -size.y / 2 - 8);

    parentToUse.add(DamagePopup(
      '-$dmg',
      color: crit ? Colors.amber : Colors.white,
      crit: crit,
      startOffset: worldPos -
          (parentToUse is PositionComponent
              ? (parentToUse as PositionComponent).position
              : Vector2.zero()),
      duration: 0.8,
      rise: 28,
    ));

    // ⭐️
    if (_hp <= 0) {
      removeFromParent();
      _clearSavedEnemy();
    } else {
      // 生きてるなら状態セーブ
      saveToPrefs();
    }
  }

  //⭐️一番下に追加
  
  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('enemy_idx', data.idx);
    await prefs.setInt('enemy_hp', _hp);
  }

  static Future<void> _clearSavedEnemy() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('enemy_idx');
    await prefs.remove('enemy_hp');
  }

  /// セーブがあればそれを復元、なければランダムで新規作成して返す
  static Future<Teki> loadOrRandom() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIdx = prefs.getInt('enemy_idx');
    final savedHp = prefs.getInt('enemy_hp');

    if (savedIdx == null) {
      // セーブデータなし → 新規ランダム敵
      final data = randomEnemy();
      return Teki(data); // initialHp 省略=フルHP
    } else {
      // セーブデータあり → 同じ敵＋残りHPを再現
      final data = EnemyList.firstWhere(
        (e) => e.idx == savedIdx,
        orElse: () => randomEnemy(),
      );
      final hp = (savedHp ?? data.hp).clamp(0, data.hp);
      return Teki(data, initialHp: hp);
    }
  }


```
