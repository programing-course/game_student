# **04_ボスを倒したら専用のクリア表示を出す**

## **この単元でやること**

1. ボス専用のクリア表示を作る
2. 表示が画面の左右からはみ出さないようにする
3. ボスを倒したらゲームを止め、専用のクリア表示を出す

`stagetxt06.dart` と `tama06.dart` の「⭐️」が付いた箇所をもとに修正します。以下の変更先は、実際に読み込まれる `stagetxt.dart` と `tama.dart` です。

## **1. ボス専用のクリア表示を作る**

### **①BossClearTextクラスを追加する**

**【stagetxt.dart】末尾に追加**

```dart
//⭐️追加
class BossClearText extends TextComponent with HasGameRef<MainGame> {
  @override
  Future<void> onLoad() async {
    anchor = Anchor.bottomCenter;
    position = Vector2(
      gameRef.player.position.x,
      gameRef.player.position.y - gameRef.player.size.y / 2 - 30,
    );

    text = 'BOSS CLEAR!\nPress [R] to retry';
    textRenderer = TextPaint(
      style: const TextStyle(
        fontSize: 50,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
    priority = 1000;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final camera = gameRef.cameraComponent;
    final viewfinder = camera.viewfinder;

    // カメラに映っている範囲の左端・右端
    final visibleWidth = camera.viewport.size.x / viewfinder.zoom;
    final left = viewfinder.position.x - visibleWidth * viewfinder.anchor.x;
    final right = left + visibleWidth;

    // 文字の幅の半分と、端の余白
    final halfWidth = size.x / 2;
    const margin = 10.0;

    final minX = left + halfWidth + margin;
    final maxX = right - halfWidth - margin;

    position.x = minX <= maxX
        ? gameRef.player.position.x.clamp(minX, maxX).toDouble()
        : (left + right) / 2;

    position.y = gameRef.player.position.y - gameRef.player.size.y / 2 - 30;
  }
}
```

### **②表示内容と位置を設定する**

`BossClearText` はボスを倒したときだけ使うテキストです。「BOSS CLEAR!」と、Rキーでリトライできる案内を表示します。

`Anchor.bottomCenter` でテキスト全体の下中央を配置の基準にします。プレーヤーの中心から高さの半分と30を引き、頭上に配置します。文字は白色・太字・サイズ50とし、`priority = 1000` で表示順を調整します。

## **2. テキストが画面の左右からはみ出さないようにする**

**【stagetxt.dart】BossClearText.update()**

前項の `update()` では、毎回表示位置を調整しています。

### **①カメラに映っている範囲を求める**

`visibleWidth` は画面に映るゲーム内の横幅です。画面の横幅をカメラの拡大率 `zoom` で割って求めます。

カメラの位置と基準位置 `anchor.x` から左端 `left` を計算し、そこへ横幅を足して右端 `right` を求めます。

### **②テキストを置ける範囲を求める**

テキストの幅の半分と余白10を考慮し、中心位置を置ける範囲を `minX`〜`maxX` として求めます。

`clamp(minX, maxX)` により、プレーヤーの横位置が画面端に近い場合も、テキストをその範囲内に収めます。縦位置はプレーヤーの頭上に合わせて更新します。

テキストが画面幅より大きく、置ける範囲がない場合は、画面中央に配置します。この場合、文字を縮小する処理はないため、はみ出しを完全には防げません。

## **3. 弾のファイルから専用テキストを使えるようにする**

**【tama.dart】importを追加**

```dart
import 'stagetxt.dart'; //⭐️追加
```

`BossClearText` を作成できるように、クラスを定義したファイルを読み込みます。

## **4. ボスとの衝突処理を変更する**

### **①これまでの処理をコメントアウトする**

**【tama.dart】Playertama.onCollisionStart() 内**

```dart
//⭐️ if (other is boss) {
//   if (boss_count > 0) {
//     boss_count--;
//     gameRef.HpTextRemove();
//   }
// }
```

これまでは、ボスのHPを減らしてHPバーの追加処理を呼ぶだけでした。

### **②ボス撃破時の処理を追加する**

同じ場所に次の処理を追加します。

```dart
//⭐️修正
if (other is boss && !isGoal && !isGameOver) {
  removeFromParent();

  if (boss_count > 0) {
    boss_count--;
    gameRef.HpTextRemove();

    if (boss_count <= 0) {
      boss_count = 0;
      isGoal = true;
      StopTimer = true;
      gameRef.player.stopMovement();

      other.removeFromParent();
      gameRef.world.children
          .whereType<Tekitama>()
          .toList()
          .forEach((tama) => tama.removeFromParent());

      gameRef.world.add(BossClearText());
    }
  }
}
```

### **③プレイ中だけHPを減らす**

`!isGoal && !isGameOver` を条件に加え、クリア後やゲームオーバー後にダメージ処理が走らないようにします。ボスに当たったプレーヤーの弾は `removeFromParent()` で消し、ボスのHPが正なら1減らします。

### **④HPが0になったらクリア状態にする**

`boss_count` を0にそろえ、`isGoal = true` でクリア状態にします。`StopTimer = true` でタイマーを止め、`stopMovement()` でプレーヤーの移動を止めます。

### **⑤ボスと敵の弾を消す**

`other.removeFromParent()` でボスを削除します。さらに `whereType<Tekitama>()` でゲーム内の敵の弾を取り出し、リストにしてからすべて削除します。

### **⑥ボス専用のクリア表示を追加する**

```dart
gameRef.world.add(BossClearText());
```

ボス専用の `BossClearText` を `world` に追加します。このボス撃破処理では `goaltextRemove()` は呼びません。

## **確認すること**

- ボスに当たったプレーヤーの弾が消え、HPが1ずつ減る。
- ボスのHPが0になると、タイマーとプレーヤーの移動が止まる。
- ボスと敵の弾が消える。
- 「BOSS CLEAR!」とリトライの案内が表示される。
- プレーヤーが左右の端にいる場合も、テキストの横位置が調整される。

※ソースを確認してまとめています。ゲームの実行確認は行っていません。
