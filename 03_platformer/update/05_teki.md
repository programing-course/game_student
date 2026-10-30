# **05_ボスを一定時間ごとにジャンプさせる**

## **この単元でやること**

1. ジャンプまでの時間を計測する
2. 3秒経過して地面にいるときにボスをジャンプさせる
3. クリア後やゲームオーバー後はジャンプ処理を止める

`teki07.dart` の「⭐️」が付いた箇所をもとに、`teki.dart` の **bossクラス** を修正します。通常の敵を扱う `Teki` クラスではありません。

## **1. ジャンプ用の時間を用意する**

**【teki.dart】bossクラスの変数宣言部分**

```dart
double jumpTimer = 0; //⭐️追加
```

前回のジャンプからの経過時間を秒単位で保存します。最初は0から計測を始めます。

## **2. update()にジャンプ処理を追加する**

**【teki.dart】boss.update()**

`super.update(dt);` の後、重力処理の前に「⭐️」で囲まれた処理を追加します。

```dart
@override
void update(double dt) {
  super.update(dt);

  //⭐️追加
  if (isGoal || isGameOver) return;

  jumpTimer += dt;

  // 3秒経過していて、地面にいるときにジャンプ
  if (jumpTimer >= 3.0 && isOnGround) {
    velocity.y = -jumpForce;
    isOnGround = false;
    jumpTimer = 0;
  }
  //⭐️追加ここまで

  applyGravity(dt, gravity);

  checkGroundCollision();

  if (position.x < size.x / 2) {
    removeFromParent();
  }

  position += velocity * dt;
}
```

### **①クリア後・ゲームオーバー後は処理を終了する**

```dart
if (isGoal || isGameOver) return;
```

どちらかが `true` なら、ここで `update()` を終了します。この行より後の時間計測・ジャンプ・重力・移動の処理を行わないようにします。

`super.update(dt)` はこの判定より先に呼ばれます。ここで止めるのは、この判定より後に書いたボス自身の処理です。

### **②経過時間を加算する**

```dart
jumpTimer += dt;
```

`dt` は前回の更新から経過した秒数です。毎回足して、ジャンプまでの時間を測ります。

### **③3秒以上経過し、接地していたらジャンプする**

```dart
if (jumpTimer >= 3.0 && isOnGround) {
  velocity.y = -jumpForce;
  isOnGround = false;
  jumpTimer = 0;
}
```

時間と接地状態の両方を確認します。3秒経過していても空中にいる間は、新しくジャンプしません。

画面のY座標は下向きに増えるため、`velocity.y` に負の値を設定すると上へ移動します。既存の `jumpForce` は500なので、ジャンプ開始時の縦方向の速度は `-500` です。

ジャンプを始めたら `isOnGround` を `false` にし、`jumpTimer` を0に戻します。次のジャンプまでの時間は、ジャンプ開始時から測り直します。

## **3. 重力と着地の処理につなげる**

ジャンプ後は、既存の `applyGravity()` で縦方向の速度に重力を加えます。地面に戻ると `checkGroundCollision()` が位置を補正し、縦方向の速度を0、`isOnGround` を `true` にします。

`teki07.dart` のbossクラスでは、`applyGravity()` 内の位置更新がコメントアウトされ、位置更新は `update()` の末尾で行う形になっています。

```dart
void applyGravity(double dt, double gravity) {
  if (!isOnGround && isGravity) {
    velocity.y += gravity * dt;
  }
  // position += velocity * dt;
}
```

これは「⭐️」の追加範囲外ですが、参照ファイルの動作を再現する際の関連箇所です。両方で位置を更新すると移動が二重になるため、位置更新は `update()` 側の1か所で行います。重力を使って落下させるには、ボスの設定で `gravity` が `true` になっている必要があります。

## **確認すること**

- ボスが約3秒後、地面にいる状態からジャンプする。
- ジャンプ後は重力で落下し、地面に着地する。
- 次のジャンプまで3秒以上空き、空中では追加ジャンプしない。
- クリア後やゲームオーバー後は、このupdate()内のジャンプ・移動処理が進まない。

※ソースを確認してまとめています。ゲームの実行確認は行っていません。
