# **08_弾を3方向に発射する強化アイテムを追加する**

## **この単元でやること**

1. 弾の強化アイテムをステージ1に置く
2. アイテムを拾うと5秒間、Eキーで3方向に弾を発射できるようにする

10版の「⭐️」を目印に、対応するDartファイルを修正します。ゲーム側は配置を追加した `game10-1.dart` と、発射処理まで含む `game10-2.dart` を参照します。

## **1. 弾の強化アイテムを定義して配置する**

**【setting.dart｜ジャンプ強化の定数の後】**

効果時間を5秒、弾の速さを400、正面から上下に広がる角度を25度にします。

```dart
const double SHOT_POWER_SECONDS = 5.0; //⭐️
const double SHOT_POWER_SPEED = 400.0; //⭐️
const double SHOT_POWER_ANGLE = 25.0; //⭐️
```

**【setting.dart｜ItemType】**

弾の強化を表す `shotUp` を追加します。

```dart
enum ItemType {
  coin,
  jumpUp,
  shotUp, //⭐️追加
}
```

**【setting.dart｜coinlist の末尾】**

弾の強化アイテムのデータを追加します。画像には既存の `coin.png` を使います。

```dart
//⭐️追加
CoinData(
  idx: 3,
  size_x: 30,
  size_y: 30,
  pos_x: screenSize.x * 1.2,
  pos_y: Y_GROUND_POSITION - 100,
  coin_img: 'power2.png',
  type: ItemType.shotUp,
),
```

**【game.dart｜objectRemove() の case 0】**

ジャンプ強化アイテムの配置に続けて、`coinlist[3]` のアイテムを置きます。

```dart
//⭐️
await world.add(coin(coinlist[3], 0, 0, 0));
```

## **2. 拾ったときに5秒の強化を始める**

**【player.dart｜プレイヤークラスのフィールド】**

弾の強化の残り時間を秒で管理します。

```dart
double shotPowerRemaining = 0; //⭐️
```

**【player.dart｜onCollisionStart() の switch】**

`switch (other.data.type)` に `shotUp` を追加します。拾った時点で残り時間が5秒になり、アイテムは既存の `other.removeFromParent()` で消えます。

```dart
//⭐️追加
case ItemType.shotUp:
  shotPowerRemaining = SHOT_POWER_SECONDS;
  break;
```

**【player.dart｜update() のジャンプ強化タイマーの後】**

毎フレーム経過時間 `dt` を引き、負になったら0に戻します。

```dart
//⭐️
if (shotPowerRemaining > 0) {
  shotPowerRemaining -= dt;

  if (shotPowerRemaining < 0) {
    shotPowerRemaining = 0;
  }
}
```

## **3. 強化弾に発射方向を渡す**

**【tama.dart｜Playertama のコンストラクターとフィールド】**

初速度を渡せるように、省略可能な名前付き引数 `initialVelocity` を追加します。

```dart
Playertama(this.data, {this.initialVelocity}); //⭐️
final TamaData data;
final Vector2? initialVelocity; //⭐️
```

**【tama.dart｜Playertama.onLoad() の初期位置を設定した後】**

初速度をX方向とY方向に分けて代入します。`hasFried = true` にすると、通常弾用の初速度で上書きされません。

```dart
//⭐️
if (initialVelocity != null) {
  speed_x = initialVelocity!.x;
  speed_y = initialVelocity!.y;
  hasFried = true;
}
```

**【tama.dart｜Playertama.update() の重力から地面の反射まで】**

重力と地面の反射は初速度を省略した通常弾にだけ適用します。初速度を指定した強化弾は、その方向にまっすぐ進みます。

```dart
//⭐️
if (initialVelocity == null) {
  speed_y += data.gravity * delta;
}

position.x += speed_x * delta;
position.y += speed_y * delta;

//⭐️initialVelocity == null &&追加
if (initialVelocity == null && position.y >= Y_GROUND_POSITION) {
  position.y = Y_GROUND_POSITION;
  speed_y = -speed_y * bounceFactor;

  if (speed_y.abs() < 50) {
    speed_y = 0;
  }
}
```

## **4. 強化中は3方向に弾を発射する**

**【game.dart｜PlayertamaRemove()】**

Eキーから呼ばれる発射処理を置き換えます。残り時間が0以下なら通常弾を1発出します。強化中はプレイヤーの向きを基準に、正面と上下25度の方向に1発ずつ出します。角度に `pi / 180` を掛けて度からラジアンに変換し、`cos()` と `sin()` でX方向とY方向の速度を求めます。これらには既存の `import 'dart:math';` を使います。

```dart
Future<void> PlayertamaRemove() async {
  //⭐️追加
  if (player.shotPowerRemaining <= 0) {
    Playertama _playertama = Playertama(TamaDatalist[0]);
    await world.add(_playertama);
    return;
  }

  //⭐️ 強化中：左向きなら180度、右向きなら0度
  final baseAngle = leftflg ? pi : 0.0;
  final spreadAngle = SHOT_POWER_ANGLE * pi / 180;

  for (final offset in [-spreadAngle, 0.0, spreadAngle]) {
    final angle = baseAngle + offset;

    final shot = Playertama(
      TamaDatalist[0],
      initialVelocity: Vector2(
        cos(angle) * SHOT_POWER_SPEED,
        sin(angle) * SHOT_POWER_SPEED,
      ),
    );

    await world.add(shot);
  }
}
```

## **確認すること**

- ステージ1の `screenSize.x * 1.2` の位置にある強化アイテムを拾うと、その場から消える。見た目は通常コインと同じ。
- 拾ってから5秒間にEキーを押すと、正面と斜め上下に弾が飛ぶ。左右両方の向きで試す。
- 強化が切れると、Eキーで通常の弾が1発出て、地面で跳ねる。

ステージ1で試す場合は、`game.dart` の `currentStage` の初期値を動作確認用に `0` にします。

※ソースを確認してまとめています。ゲームの実行確認は行っていません。

.
..
