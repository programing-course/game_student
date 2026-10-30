# **04_ボスを倒したらゴールにする**

## **この単元でやること**

1. ボスに当たったプレーヤーの弾を消す
2. ボスのHPが0になったらゴールにする
3. ボスと敵の弾を消す

ソース内の「⭐️」が付いた箇所を修正します。

## **1. これまでの衝突処理をコメントアウトする**

**【tama.dart】Playertama.onCollisionStart() 内**

```dart
//⭐️ if (other is boss) {
//   if (boss_count > 0) {
//     boss_count--;
//     gameRef.HpTextRemove();
//   }
// }
```

これまでは、ボスに弾が当たるとHPを減らし、HPバーの追加処理を呼ぶだけでした。

## **2. ゴール判定を含む処理に変更する**

**【tama.dart】Playertama.onCollisionStart() 内**

コメントアウトした処理の代わりに、次の処理を追加します。

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

      gameRef.goaltextRemove();
    }
  }
}
```

### **①プレイ中だけボスへの攻撃を受け付ける**

`!isGoal && !isGameOver` を条件に加えます。ゴール後やゲームオーバー後は、この分岐でボスのHPを減らしません。

### **②当たった弾を消し、HPを減らす**

`removeFromParent()` でプレーヤーの弾自身を消します。ボスのHPが正なら1減らし、`HpTextRemove()` を呼びます。

### **③HPが0になったらゴールにする**

`boss_count` を0にそろえ、`isGoal = true` にします。`StopTimer = true` でタイマーを止め、プレーヤーの移動も止めます。

### **④ボスと敵の弾を消す**

`other.removeFromParent()` で衝突相手のボスを消します。`whereType<Tekitama>()` でゲーム内の敵の弾を取り出し、すべて削除します。

`toList()` で対象をいったんリストにしてから、各弾の削除処理を呼びます。

### **⑤ゴール表示の処理を呼ぶ**

最後に `goaltextRemove()` を呼び、ゴール案内や記録表示などの処理へ進みます。

## **確認すること**

- ボスに当たったプレーヤーの弾が消える。
- ボスのHPが1ずつ減り、0になるとゴールになる。
- ゴール時にタイマーとプレーヤーの移動が止まる。
- ボスと画面内の敵の弾が消え、ゴール案内が表示される。

※ソースを確認してまとめています。ゲームの実行確認は行っていません。

