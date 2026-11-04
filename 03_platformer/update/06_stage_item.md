# **06_ジャンプ強化アイテムを追加する**

## **この単元でやること**

1. アイテムの種類と配置データを追加する
2. ジャンプ強化アイテムをステージ1に配置する
3. 拾ったアイテムをストックし、Qキーで5秒間ジャンプを強化する

`setting08.dart`、`game08.dart`、`player08.dart` の「⭐️」を目印に、対応する `setting.dart`、`game.dart`、`player.dart` を修正します。

## **1. アイテムの種類と配置データを追加する**

**【setting.dart】`CoinData` と `coinlist`**

`ItemType` に通常コインとジャンプ強化を定義します。`CoinData` に必須の `type` を追加し、既存の2件には `ItemType.coin` を指定します。リストの末尾に `ItemType.jumpUp` のデータを追加します。

```dart
//⭐️ 追加
enum ItemType {
  coin,
  jumpUp,
}

class CoinData {
  final int idx;
  final double size_x;
  final double size_y;
  final double pos_x;
  final double pos_y;
  final String coin_img;
  final ItemType type; //⭐️ 追加

  CoinData({
    required this.idx,
    required this.size_x,
    required this.size_y,
    required this.pos_x,
    required this.pos_y,
    required this.coin_img,
    required this.type, //⭐️
  });
}

List<CoinData> coinlist = [
  CoinData(
    idx: 0,
    size_x: 30,
    size_y: 30,
    pos_x: screenSize.x * 3 / 4 + 50,
    pos_y: screenSize.y * 1 / 3 - 45,
    coin_img: 'coin.png',
    type: ItemType.coin, //⭐️
  ),
  CoinData(
    idx: 1,
    size_x: 30,
    size_y: 30,
    pos_x: screenSize.x * 0.5,
    pos_y: Y_GROUND_POSITION - 100,
    coin_img: 'coin.png',
    type: ItemType.coin, //⭐️
  ),
  CoinData(
    idx: 2,
    size_x: 30,
    size_y: 30,
    pos_x: screenSize.x * 0.7,
    pos_y: Y_GROUND_POSITION - 100,
    coin_img: 'power.png',
    type: ItemType.jumpUp, //⭐️
  ),
];
```

## **2. ステージ1にジャンプ強化アイテムを置く**

**【game.dart】`objectRemove()` の `case 0`**

通常コインを並べるループの後に追加します。`coinlist[2]` の設定を使い、アイテムを1個だけ `world` に追加します。

```dart
//⭐️
coin powerItem = coin(coinlist[2], 0, 0, 0);
await world.add(powerItem);
```

## **3. 拾ったアイテムをストックする**

**【player.dart】プレイヤークラスのフィールド**

`powerCount` は持っている強化アイテムの数、`jumpPowerRemaining` は強化の残り時間（秒）です。どちらも0から始めます。

```dart
int powerCount = 0; //⭐️
double jumpPowerRemaining = 0; //⭐️
```

**【player.dart】`onCollisionStart()`**

通常コインを拾うと `coin_count` が1増えます。ジャンプ強化アイテムを拾うと `powerCount` が1増えます。どちらも拾った後に `removeFromParent()` で取り除きます。

```dart
//⭐️
// if (other is coin) {
//   coin_count++;
//   other.removeFromParent();
// }

//⭐️
if (other is coin) {
  switch (other.data.type) {
    case ItemType.coin:
      coin_count++;
      break;

    case ItemType.jumpUp:
      powerCount++;
      break;
  }

  other.removeFromParent();
}
```

## **4. Qキーでジャンプを強化する**

**【setting.dart】`VIEW_X_END` のゲッターの後**

強化が続く時間と、強化中に使うジャンプ力を定数にします。

```dart
const double JUMP_POWER_SECONDS = 5.0; //⭐️ 効果時間
const double JUMP_POWER_FORCE = 700.0; //⭐️ 強化中のジャンプ力
```

**【player.dart】`onKeyEvent()` のEキー処理の後**

Qキーを押したとき、アイテムを1個以上持っていて、強化が切れていれば、1個消費して残り時間を5秒にします。

```dart
//⭐️追加
if (event.logicalKey == LogicalKeyboardKey.keyQ &&
    powerCount > 0 &&
    jumpPowerRemaining <= 0) {
  powerCount--;
  jumpPowerRemaining = JUMP_POWER_SECONDS;
}
```

## **5. 強化中のジャンプ力と残り時間を処理する**

**【player.dart】`jump()`**

地面にいるとき、残り時間があれば強化中の値（700）を使い、効果が切れていれば通常の値（500）を使います。上に向かって跳ぶので、Y方向の速度には負の値を代入します。

```dart
void jump() {
  if (isOnGround) {
    //⭐️
    final force = jumpPowerRemaining > 0 ? JUMP_POWER_FORCE : jumpForce;

    velocity.y = -force; //⭐️修正
    isOnGround = false;
  }
}
```

**【player.dart】`update(double dt)` の `super.update(dt)` の直後**

フレームごとに経過時間 `dt` を引きます。残り時間が負になったら0に戻します。

```dart
//⭐️
if (jumpPowerRemaining > 0) {
  jumpPowerRemaining -= dt;

  if (jumpPowerRemaining < 0) {
    jumpPowerRemaining = 0;
  }
}
```

## **確認すること**

- 通常コインを拾うとコイン数が1増える。
- ジャンプ強化アイテムを拾うとアイテムが消え、ストックが1増える。拾った直後は通常の高さでジャンプする。
- ストックがある状態でQキーを押すと1個消費し、5秒間に開始したジャンプが高くなる。その後のジャンプは通常の高さに戻る。
- ストックがないときや強化中にQキーを押しても、新たな強化は始まらない。

08版の初期値は `currentStage = 1` です。ステージ1のアイテムを試すときは、動作確認用に初期値を `0` にします。画像素材は `assets/images/power.png` にあります。

※ソースを確認してまとめています。ゲームの実行確認は行っていません。

.
..
