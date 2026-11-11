# **11_ダンジョンの入口を作る**

## **この単元でやること**

1. ステージ1の後半に、触れると開く扉を置く
2. プレイヤーを引き継いでダンジョンへ移る
3. ダンジョンの背景を暗くする

今回は「入口と場面の切り替え」を作る回です。ダンジョンの迷路は第12回以降に作ります。図は仕組みを説明するための模式図です。

## **1. 触れると開く扉を作る**

**【setting.dart】`goallist` の後**

ゴール旗と同じように、扉の設定を `DoorData` にまとめ、`doorlist` に登録します。`size_x` と `size_y` が幅と高さ、`pos_x` と `pos_y` が位置です。画像を変えるときは、`assets/images/` に画像を置き、閉じた状態のファイル名を `closed_img`、開いた状態のファイル名を `opened_img` に指定します。

```dart
//⭐️
class DoorData {
  final int idx;
  final double size_x;
  final double size_y;
  final double pos_x;
  final double pos_y;
  final String closed_img;
  final String opened_img;

  DoorData({
    required this.idx,
    required this.size_x,
    required this.size_y,
    required this.pos_x,
    required this.pos_y,
    required this.closed_img,
    required this.opened_img,
  });
}

List<DoorData> doorlist = [
  DoorData(
    idx: 0,
    size_x: 80,
    size_y: 100,
    pos_x: screenSize.x * 4 - 150,
    pos_y: Y_GROUND_POSITION,
    closed_img: 'door1.png',
    opened_img: 'door2.png',
  ),
];
```

![扉の下辺の中央を地面に合わせる座標とサイズの図](img/11_door_anchor.svg)

**【object.dart】ファイル末尾**

コンストラクターで `DoorData` を受け取り、`onLoad()` で設定にある画像・サイズ・座標を使います。`Anchor.bottomCenter` により、この座標が扉の下辺の中央になります。プレイヤーが触れると開いた画像に切り替わり、0.4秒後にダンジョンへ移ります。

![扉への接触から画像切り替え、0.4秒待機、ダンジョンへの切り替えまでの流れ](img/11_door_flow.svg)

```dart
//⭐️
class Door extends SpriteComponent
    with HasGameRef<MainGame>, CollisionCallbacks {
  Door(this.data);
  final DoorData data;

  bool isOpening = false;
  late Sprite openedSprite;

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(data.closed_img);
    openedSprite = await gameRef.loadSprite(data.opened_img);

    size = Vector2(data.size_x, data.size_y);
    anchor = Anchor.bottomCenter;

    position = Vector2(data.pos_x, data.pos_y); //⭐️

    add(
      RectangleHitbox()..collisionType = CollisionType.passive,
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other != gameRef.player || isOpening || isGameOver || isGoal) {
      return;
    }

    isOpening = true;
    sprite = openedSprite;

    add(
      TimerComponent(
        period: 0.4,
        repeat: false,
        onTick: () {
          gameRef.enterDungeon();
        },
      ),
    );
  }
}
```

## **2. ステージ1に扉を配置する**

**【game.dart】`objectRemove()` の `switch (currentStage)`**

`case 0` がステージ1です。アイテム配置の後に、`doorlist[0]` を渡して扉を追加します。既存の扉の配置が `case 1` にある場合は、その行を `case 0` に移します。

```dart
await world.add(Door(doorlist[0])); //⭐️
```

同じ `switch` にダンジョン用の分岐を追加します。

```dart
case 2:
  // ダンジョンに配置する敵や足場はここに追加
  break;
```

![ステージ1の内部番号0とダンジョンの内部番号2で配置と背景を切り替える図](img/11_stage_switch.svg)

## **3. ステージを作り直すときにプレイヤーを残す**

**【game.dart】`objectRemove()` の先頭からプレイヤーの追加まで**

`keepPlayer: true` のときは既存のプレイヤーを削除ループで飛ばし、そのインスタンスを使い続けます。引数を省略すると、従来どおり新しいプレイヤーを作ります。

![keepPlayerがtrueならプレイヤーを残し、背景や敵などを作り直す仕組み](img/11_keep_player.svg)

`continue` は、繰り返し全体を終わらせず、今の部品の削除を飛ばして次の部品へ進む命令です。後ろの `if (!keepPlayer)` では、引き継がない場合だけ新しいプレイヤーを作ります。

```dart
//⭐️{bool keepPlayer = false}追加
  Future<void> objectRemove({bool keepPlayer = false}) async {
    final List<Component> childrenToRemove = world.children.toList();
    for (var child in childrenToRemove) {
      //⭐️追加
      if (keepPlayer && child == player) {
        continue;
      }
      child.removeFromParent();
    }
    await CameraRemove();
    CameraBackScreen backscreen = CameraBackScreen();
    await world.add(backscreen);

    Cameraground ground = Cameraground();
    await world.add(ground);

    //⭐️
    if (!keepPlayer) {
      player = Player();
      await world.add(player);
    }
```

## **4. ダンジョンへ移る処理を追加する**

**【game.dart】`MainGame` クラスの末尾**

ステージ1（`currentStage == 0`）からダンジョン（`currentStage == 2`）へ切り替えます。タイマーと中間地点をリセットし、プレイヤーを地面の左端に移してからステージを作り直します。

```dart
//⭐️追加
Future<void> enterDungeon() async {
  if (currentStage != 0) {
    return;
  }

  currentStage = 2;

  // ボス戦用の画面表示を消す
  for (final child in cameraComponent.viewport.children.toList()) {
    if (child is HpBar || child is TextDisplay) {
      child.removeFromParent();
    }
  }

  timerComponent?.removeFromParent();
  timerComponent = null;

  RetryFlg = false;
  RetryPosition = PLAYER_SIZE_X / 2;

  player.stopMovement();
  player.velocity.setZero();
  player.position = Vector2(
    PLAYER_SIZE_X / 2,
    Y_GROUND_POSITION - PLAYER_SIZE_Y / 2,
  );
  player.isOnGround = true;

  await objectRemove(keepPlayer: true);
}
```

## **5. ダンジョンの背景を暗くする**

**【screen.dart】`CameraBackScreen.onLoad()` の `paint`**

`currentStage == 2` のときに暗い背景色を使います。

```dart
//⭐️修正
paint = Paint()
  ..color = currentStage == 2
      ? const Color(0xFF242433)
      : const Color.fromARGB(255, 110, 219, 197);
```

## **確認すること**

- ステージ1の右端付近で扉に触れると、画像が切り替わる。
- 約0.4秒後に背景が暗くなり、プレイヤーがダンジョンの左端に移動する。
- ジャンプ強化アイテムの所持数が引き継がれる。

※ゲームの実行確認は行っていません。
