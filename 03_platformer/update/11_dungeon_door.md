# **11_ダンジョンの入口を作る**

## **この単元でやること**

1. ステージ2の右端に、触れると開く扉を置く
2. プレイヤーを引き継いでダンジョンに移る処理を用意する
3. ダンジョンの背景を暗くする

`object13.dart`、`game13.dart`、`screen13.dart` を参照します。13版では扉に触れると画像が切り替わります。ダンジョンへ移る呼び出しはコメントアウトされているので、移動の確認方法は末尾に記載します。

## **1. 触れると開く扉を作る**

**【object.dart】ファイル末尾**

`Door` クラスを追加します。`door1.png` を閉じた状態、`door2.png` を開いた状態に使います。`Anchor.bottomCenter` で扉の下端を地面に合わせ、フィールドの右端から150手前に置きます。

プレイヤーが触れたときに画像を切り替えます。`isOpening` で二重に開くのを防ぎます。ゲームオーバー時とゴール後は処理を終了します。タイマーは0.4秒後に1回だけ実行する設定です。

```dart
//⭐️
class Door extends SpriteComponent
    with HasGameRef<MainGame>, CollisionCallbacks {
  bool isOpening = false;
  late Sprite openedSprite;

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('door1.png');
    openedSprite = await gameRef.loadSprite('door2.png');

    size = Vector2(80, 100);
    anchor = Anchor.bottomCenter;

    // STAGE2の右端付近。扉の下端を地面に合わせる
    position = Vector2(
      FIELD_SIZE_X - 150,
      Y_GROUND_POSITION,
    );

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
          // gameRef.enterDungeon();
        },
      ),
    );
  }
}
```

## **2. ステージ2に扉を配置する**

**【game.dart】`objectRemove()` の `switch (currentStage)`**

ステージ2に当たる `case 1` の末尾に扉を追加します。ダンジョン用の `case 2` も用意します。この版のダンジョンには、共通の背景と地面が表示されます。

```dart
  await HpTextRemove();

  await world.add(Door()); //⭐️

  break;
case 2:
  // ダンジョンに配置する敵や足場はここに追加
  break;
```

## **3. ステージを作り直すときにプレイヤーを残せるようにする**

**【game.dart】`objectRemove()` の先頭からプレイヤーの追加まで**

名前付き引数 `keepPlayer` を追加します。`true` を渡すと、削除ループで今のプレイヤーを飛ばし、新しいプレイヤーも作りません。引数を省略すると既定値の `false` が使われ、従来どおり新しいプレイヤーを作ります。

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

## **4. ダンジョンに移る処理を追加する**

**【game.dart】`MainGame` クラスの末尾**

`enterDungeon()` はステージ2でだけ実行します。`currentStage` を `2` にし、ボス戦のHPバーと案内文、`timerComponent` を取り除きます。中間地点をリセットし、プレイヤーを地面の左端へ移動してから、`keepPlayer: true` でステージを作り直します。同じプレイヤーを使うので、所持している強化アイテムも引き継がれます。

```dart
//⭐️追加
Future<void> enterDungeon() async {
  if (currentStage != 1) {
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

## **5. ダンジョンの背景色を変える**

**【screen.dart】`CameraBackScreen.onLoad()` の `paint`**

`currentStage == 2` のときに暗い色を使います。

```dart
//⭐️修正
paint = Paint()
  ..color = currentStage == 2
      ? const Color(0xFF242433)
      : const Color.fromARGB(255, 110, 219, 197);
```

## **確認すること**

- ステージ2の右端に閉じた扉があり、プレイヤーが触れると開いた画像に変わる。ステージ2から始めて試す場合は、確認用に `currentStage` の初期値を `1` にする。
- ダンジョンへの移動も試す場合は、`Door` の `onTick` 内にある `gameRef.enterDungeon();` のコメントを確認用に外す。扉が開いて約0.4秒後に暗い背景へ切り替わり、プレイヤーが左端に移動する。
- 移動後は、ボスのHPバーと案内文が消え、プレイヤーの強化アイテムの所持数が引き継がれる。

※ソースを確認してまとめています。ゲームの実行確認は行っていません。

.
..
