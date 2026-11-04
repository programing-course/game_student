# **10_左右に動く足場を作る**

## **この単元でやること**

1. 足場を決められた範囲で左右に往復させる
2. 足場の上にいるプレイヤーを、足場と一緒に動かす

`object11.dart` の「⭐️」を目印に、`object.dart` の `step` クラスを修正します。09で扱った残り時間の表示に続き、この単元では動く足場を作ります。足場の移動に必要な設定は `setting12.dart` を参照します。

## **1. 足場の移動距離と速さを設定する**

**【setting.dart】`StepData` のフィールドとコンストラクター**

`moveDistance` は開始位置から右端までの距離、`moveSpeed` は1秒あたりの移動量です。フィールドと省略可能な名前付き引数を追加します。距離の既定値は0なので、設定を省略した足場はその場に留まります。

```dart
final double moveDistance; //⭐️ 最初の位置から右へ動く距離
final double moveSpeed; //⭐️ 移動の速さ
```

```dart
this.moveDistance = 0, //⭐️
this.moveSpeed = 100, //⭐️
```

**【setting.dart】`steplist` の `idx: 1` のデータ**

ステージ1の2つ目の足場を、開始位置から右へ200の範囲で、毎秒100の速さで動かします。

```dart
moveDistance: 200, //⭐️
moveSpeed: 100, //⭐️
```

## **2. 足場の移動方向を記録する**

**【object.dart】`step` の `final StepData data;` の後**

`1` は右向き、`-1` は左向きです。初期値を `1` にして、最初は右へ動かします。

```dart
double moveDirection = 1; //⭐️
```

## **3. 足場を動かし、乗っているプレイヤーを運ぶ**

**【object.dart】`step.render()` の後**

`update(double dt)` を追加します。移動距離と速さがどちらも正なら、移動前の足場にプレイヤーが乗っているかを確認します。横方向に重なり、足元と足場の上面の差が4以内で、かつプレイヤーが上昇していないときに、足場に乗っていると判定します。

足場を `data.moveSpeed * moveDirection * dt` だけ動かし、端に着いたら位置を端に合わせて方向を反転します。プレイヤーが乗っていれば、端での補正も含めて、足場が実際に動いた距離 `movedX` をプレイヤーのX座標に足します。

```dart
//⭐️追加
@override
void update(double dt) {
  super.update(dt);

  if (data.moveDistance <= 0 || data.moveSpeed <= 0) {
    return;
  }

  final player = gameRef.player;

  // Player は Anchor.center なので、中心から端を求める
  final playerLeft = player.position.x - player.size.x / 2;
  final playerRight = player.position.x + player.size.x / 2;
  final playerBottom = player.position.y + player.size.y / 2;

  // step は Anchor.topLeft
  final stepLeft = position.x;
  final stepRight = position.x + size.x;
  final stepTop = position.y;

  // 横方向に重なっているか
  final overlapsX = playerRight > stepLeft && playerLeft < stepRight;

  // プレイヤーの足元が足場の上面にあるか
  // 計算のずれを考慮して、4以内なら乗っていると判定
  final isOnTop = (playerBottom - stepTop).abs() <= 4;

  // ジャンプして上昇している間は運ばない
  final isRiding = overlapsX && isOnTop && player.velocity.y >= 0;

  // 移動前の位置を保存
  final previousX = position.x;

  final leftLimit = data.pos_x;
  final rightLimit = data.pos_x + data.moveDistance;

  position.x += data.moveSpeed * moveDirection * dt;

  if (position.x >= rightLimit) {
    position.x = rightLimit;
    moveDirection = -1;
  } else if (position.x <= leftLimit) {
    position.x = leftLimit;
    moveDirection = 1;
  }

  // 足場が実際に動いた距離
  final movedX = position.x - previousX;

  // 乗っているプレイヤーも同じ距離だけ動かす
  if (isRiding) {
    player.position.x += movedX;
  }
}
```

## **確認すること**

- ステージ1の2つ目の足場が開始位置と、その右200の位置の間を往復する。
- 足場の上でキーを離しても、プレイヤーが足場と一緒に移動する。
- 足場からジャンプすると、上昇中は足場に運ばれない。
- 移動距離の設定を省略した1つ目の足場は、その場に留まる。

※ソースを確認してまとめています。ゲームの実行確認は行っていません。

.
..
