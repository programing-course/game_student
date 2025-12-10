# **15_guard**

**①Cキーでガード**

**【game.dart】**

```dart

  bool isPlayerActing = false;
  bool isGuarding = false; //⭐️追加

  //省略

  //⭐️KeyEventResult全体を↓に書き換え
  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // 先に子へ配信 → UI(Persona) が最優先で受ける
    final r = super.onKeyEvent(event, keysPressed);
    if (r == KeyEventResult.handled) return r;

    if (scene == "battle" && _battleInitialized) {
      if (event is KeyDownEvent) {
        if (keysPressed.contains(LogicalKeyboardKey.digit1)) {
          _updateSelection(0);
          return KeyEventResult.handled;
        } else if (keysPressed.contains(LogicalKeyboardKey.digit2)) {
          _updateSelection(1);
          return KeyEventResult.handled;
        } else if (keysPressed.contains(LogicalKeyboardKey.keyE)) {
          _persona ??= Persona(); // ← 多重追加防止
          add(_persona!);
          print("Persona added");
          return KeyEventResult.handled;
        } else if (keysPressed.contains(LogicalKeyboardKey.space)) {
          if (isPlayerActing) return KeyEventResult.handled;
          isPlayerActing = true;

          // attack() は async なので、Futureで切り離す
          selectedPlayer.attack().whenComplete(() {
            isPlayerActing = false;
          });

          return KeyEventResult.handled;
          // ⭐️追加
        } else if (event.logicalKey == LogicalKeyboardKey.keyC) {
          isGuarding = true;
          print("Guard!!");
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

```

**【player.dart】**


```dart
Future<void> attack({int personaPower = 1}) async {
    
    //省略

    await Future.delayed(const Duration(seconds: 4));

    final enemy = gameRef.currentEnemy; //⭐️追加

     //⭐️追加
    if (enemy == null || enemy.currentHp <= 0) {
      return;
    }

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


void _queueEnemyCounter() async {
    Future.delayed(const Duration(seconds: 1), () {
      if (scene != "battle") return;
      if (!isMounted) return;

      //敵がいない or 倒れてるなら攻撃しない
      final enemy = gameRef.currentEnemy;
      if (enemy == null || enemy.currentHp <= 0) {
        return;
      }

      gameRef.EffectRemove_player();
      const baseDamage = 12; //⭐️修正
      int damage = baseDamage; //⭐️追加

      if (isGuarding) {
        //⭐️ガード成功メッセージ
        _announceGuardSuccess();

        // SP回復
        selectedPlayer.recoverSP(10);

        // ダメージ半減
        damage = (damage / 2).round();

        // 1回の攻撃に対して1回だけ有効
        isGuarding = false;
      }
      selectedPlayer.applyDamage(damage);
      selectedPlayer.hitShake();

      selectedPlayer.savePlayerStatus();
    });
  }

  // ⭐️追加
  Future<void> _announceGuardSuccess() async {
    final a = BattleAnnouncement('ガード成功！', duration: 0.8);
    gameRef.add(a);
    await a.completed; // 消えるまで待つ必要なければ、この行は消してもOK
  }

  //省略

  // ⭐️最後に追加
  void recoverSP(int amount) {
    sp = (sp + amount).clamp(0, maxSp);
  }

```
