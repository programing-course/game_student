# **14_Level2**

**①expを表示**

**【game.dart】**

```dart

  player1.add(LvLabel(
    target: player1,
    target2: player1, //⭐️追加
    offset: Vector2(0, -PLAYER_SIZE_Y / 2 - 24),
  ));

  player2.add(LvLabel(
    target: player2,
    target2: player2, //⭐️追加
    offset: Vector2(0, -PLAYER_SIZE_Y / 2 - 24),
  ));

  //⭐️一番下に追加
  abstract class experienceProvider {
    int get experience;
  }

```

**【ui.dart】**


```dart
class LvLabel extends PositionComponent {
  LvLabel({
    required this.target,
    required this.target2, //⭐️
    Vector2? offset,
    this.bg = const Color(0xFF222222),
    this.textColor = Colors.white,
    this.borderRadius = 4.0,
  }) {
    size = Vector2(34, 14); // 小さいパネル
    position = offset ?? Vector2.zero();
    anchor = Anchor.center;
    priority = 1000;

    _bgPaint.color = bg;

    _textPaint = TextPaint(
      style: TextStyle(
        color: textColor,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
        shadows: const [Shadow(blurRadius: 1, offset: Offset(1, 1))],
      ),
    );
  }

  final LevelProvider target;
  final experienceProvider target2; //⭐️
  final Color bg;
  final Color textColor;
  final double borderRadius;

  final _bgPaint = Paint();
  late final TextPaint _textPaint;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 背景
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(rrect, _bgPaint);

    // "Lv X"
    final text = 'Lv ${target.level}　exp ${target2.experience}'; //⭐️
    // パネル内で少し左上に
    _textPaint.render(
      canvas,
      text,
      Vector2(4, size.y / 2 - 6),
    );
  }
}

```

**敵がいない or 倒れてるなら攻撃しない**

**【player.dart】**

```Dart

void _queueEnemyCounter() async {
    Future.delayed(const Duration(seconds: 1), () {
      if (scene != "battle") return;
      if (!isMounted) return;

      //⭐️ 敵がいない or 倒れてるなら攻撃しない
      final enemy = gameRef.currentEnemy;
      if (enemy == null || enemy.currentHp <= 0) {
        return;
      }

      gameRef.EffectRemove_player();
      const damage = 12;
      selectedPlayer.applyDamage(damage);
      selectedPlayer.hitShake();

      selectedPlayer.savePlayerStatus();
    });
  }


```

**敵を倒したら経験値を上げる**

**【teki.dart】**

```dart

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

    if (_hp <= 0) {
      selectedPlayer.addExp(10); // ⭐️

      // ⭐️
      if (gameRef.currentEnemy == this) {
        gameRef.currentEnemy = null;
      }

      _clearSavedEnemy();

      removeFromParent();
    } else {
      // 生きてるなら状態セーブ
      saveToPrefs();
    }
  }

```

**【player.dart】**

```dart

//⭐️追加
  void addExp(int amount) {
    exp += amount;
    // 100ごとにレベルアップ
    while (exp >= 100) {
      exp -= 100;
      lv++;
    }

    // セーブもしておく
    savePlayerStatus();
  }

  //省略

  Future<void> loadStatus() async {
    final prefs = await SharedPreferences.getInstance();

    final savedHp = prefs.getInt('${id}_hp'); //⭐️
    hp = savedHp ?? maxHp; //⭐️

    //⭐️
    if (hp <= 0) {
      hp = maxHp;
      // ついでにセーブデータも更新しておくと安全
      await prefs.setInt('${id}_hp', hp);
    }
    sp = prefs.getInt('${id}_sp') ?? maxSp;
    lv = prefs.getInt('${id}_lv') ?? 1;
    exp = prefs.getInt('${id}_exp') ?? 0;
  }

```

**プレーヤーの復活**

```Dart

void applyDamage(int dmg, {bool crit = false}) {
    hp = (hp - dmg).clamp(0, maxHp);
    add(
      DamagePopup(
        '-$dmg',
        color: crit ? Colors.amber : Colors.white,
        crit: crit,
        startOffset: Vector2(0, -size.y / 2 - 8),
        duration: 0.8,
        rise: 28,
      ),
    );
    if (hp <= 0) {
      _clearSavedPlayerStatus(); //⭐️
      removeFromParent();
    }
  }

//一番下に追加
Future<void> _clearSavedPlayerStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${id}_hp');
    await prefs.remove('${id}_sp');
    await prefs.remove('${id}_lv');
    await prefs.remove('${id}_exp');
}

```

**ペルソナの攻撃力**

**【player.dart】**

```dart

  //⭐️引数追加
  Future<void> attack({int personaPower = 1}) async {
    await gameRef.EffectRemove();

    final enemyAtk = gameRef.currentEnemy?.data.attack;
    //⭐️ final damage = enemyAtk ?? data.attack;

    //⭐️ プレイヤー攻撃力 × ペルソナ攻撃力
    final baseAttack = data.attack;
    print("baseAttack==${baseAttack}");
    print("personaPower==${personaPower}");

    final damage = baseAttack * personaPower;

    _updateSelection(0);
    await _announce('プレーヤー１の攻撃');
    for (final teki in gameRef.world.children.whereType<Teki>()) {
      print("①");
      teki.applyDamage(damage);
      teki.hitShake();
    }

    await Future.delayed(const Duration(seconds: 3));

    _updateSelection(1);
    await _announce('プレーヤー２の攻撃');

    await Future.delayed(const Duration(seconds: 2));

    await gameRef.EffectRemove();

    for (final teki in gameRef.world.children.whereType<Teki>()) {
      print("②");
      teki.applyDamage(damage);
      teki.hitShake();
    }

    await Future.delayed(const Duration(seconds: 4));

    _updateSelection(0);
    await _announce('敵の攻撃');

    await Future.delayed(const Duration(seconds: 1));

    // 敵の攻撃
    _queueEnemyCounter();

    await Future.delayed(const Duration(seconds: 3));

    _updateSelection(1);
    await _announce('敵の攻撃');
    await Future.delayed(const Duration(seconds: 1));

    // 敵の攻撃
    _queueEnemyCounter();
  }

```

**【ui.dart】**

```dart

  void _enter() async {
    // 今選ばれているペルソナ名
    final personaName = options[selectedIndex]; //⭐️追加

    // 対応する攻撃力（なければ1）
    final personaPower = PersonaAttackMap[personaName] ?? 1; //⭐️追加

    // プレーヤー攻撃力 × ペルソナ攻撃力 で攻撃
    await selectedPlayer.attack(personaPower: personaPower); //⭐️修正

    selectedPlayer.addSP(10); //⭐️追加
  }

```
