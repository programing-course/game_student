# **07_敵の表示**

**【setting.dart】**

```dart

import 'dart:math' show Random;

final TEKI_SIZE_X = 100.0;
final TEKI_SIZE_Y = 100.0;


enum Skill {
  fireball,
  heal,
  guard,
  slash,
  // 必要なら増やす
}

class CharacterData {
  final int idx; // 任意の識別子（UI位置合わせ等に使いたければ）
  final double pos_x;
  final double pos_y;
  final String imagePath; // 画像ファイル名（assets/images 配下想定）
  final Skill skill; // スキル
  final int hp; // 体力
  final int defense; // 防御力
  final int attack; // 攻撃力
  final List<String> materials; // 所持/ドロップ素材

  CharacterData({
    required this.idx,
    required this.pos_x,
    required this.pos_y,
    required this.imagePath,
    required this.skill,
    required this.hp,
    required this.defense,
    required this.attack,
    this.materials = const [],
  });
}

// ---- 敵データ（必要に応じて増やす）----
final List<CharacterData> EnemyList = [
  CharacterData(
    idx: 0,
    pos_x: SCREENSIZE_X * 0.5,
    pos_y: 300,
    imagePath: 'tako.png',
    skill: Skill.slash,
    hp: 60,
    defense: 8,
    attack: 12,
    materials: ['ink', 'tentacle'],
  ),
  CharacterData(
    idx: 1,
    pos_x: SCREENSIZE_X * 0.5,
    pos_y: 300,
    imagePath: 'kani.png',
    skill: Skill.guard,
    hp: 80,
    defense: 14,
    attack: 8,
    materials: ['shell', 'claw'],
  ),
  CharacterData(
    idx: 2,
    pos_x: SCREENSIZE_X * 0.5,
    pos_y: 300,
    imagePath: 'ika.png',
    skill: Skill.fireball,
    hp: 50,
    defense: 6,
    attack: 16,
    materials: ['ink', 'fin'],
  ),
];

// ---- プレイヤーデータ（例：選択式の初期ジョブなどを想定）----
final List<CharacterData> PlayerList = [
  CharacterData(
    idx: 0,
    pos_x: SCREENSIZE_X * 0.5,
    pos_y: 300,
    imagePath: 'ika2.png',
    skill: Skill.slash,
    hp: 100,
    defense: 10,
    attack: 15,
    materials: [],
  ),
  CharacterData(
    idx: 1,
    pos_x: SCREENSIZE_X * 0.5,
    pos_y: 300,
    imagePath: 'ika2.png',
    skill: Skill.fireball,
    hp: 80,
    defense: 6,
    attack: 20,
    materials: [],
  ),
];

final _rand = Random();

CharacterData randomEnemy() {
  return EnemyList[_rand.nextInt(EnemyList.length)];
}

```

**【teki.dart】**

```dart

import 'package:flame/components.dart';
import 'game.dart';
import 'setting.dart';

class Teki extends SpriteComponent with HasGameRef<MainGame>, KeyboardHandler {
  final CharacterData data;

  Teki(this.data);

  // ランダム生成で呼びたい時
  Teki.random() : data = randomEnemy();

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(data.imagePath);
    size = Vector2(TEKI_SIZE_X, TEKI_SIZE_Y);
    position = Vector2(data.pos_x, data.pos_y);
    anchor = Anchor.center;
    priority = 10;
  }
}


```

**【game.dart】**

```dart

import 'teki.dart';

// ⭐️ランダムで表示
Teki teki = Teki.random();
await world.add(teki);

// ⭐️固定で表示
Teki teki1 = Teki(EnemyList[0]); // タコを生成
await world.add(teki1);

```

**【teki.dart】**

**アニメーションを追加**

```dart

import 'package:flutter/animation.dart';


class Teki extends SpriteComponent with HasGameRef<MainGame>, KeyboardHandler {
  final CharacterData data;

  Teki(this.data);
  Teki.random() : data = randomEnemy();

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(data.imagePath);
    size = Vector2(TEKI_SIZE_X, TEKI_SIZE_Y);
    position = Vector2(data.pos_x, data.pos_y);
    anchor = Anchor.center;
    priority = 10;
  }

  //⭐️ 追加
  void hitShake({
    double amount = 8,
    int times = 3,
    double oneShakeSec = 0.05,
  }) {
    add(
      MoveEffect.by(
        Vector2(0, -amount),
        EffectController(
          duration: oneShakeSec,
          // ↓ これで「上へ → 戻る」を1回として往復させる
          alternate: true,
          // ↓ 往復セットを times 回
          repeatCount: times,
          curve: Curves.easeOut,
        ),
      ),
    );
  }
}

```
