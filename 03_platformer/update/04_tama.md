# **04_弾が当たったときのHP処理**

## **この単元で確認すること**

1. プレーヤーの弾でボスのHPを減らす
2. 敵の弾でプレーヤーの残り数を減らす
3. プレーヤーの残り数が0になったらゲームオーバーにする

## **比較結果**

**【tama04.dart → tama.dart】**

現在の2ファイルは同じ内容で、差分はありません。以下は現在の衝突処理の説明です。敵の弾については、コメントアウトされた旧処理と対比しています。番号付きファイルからの追加・変更として確認できたものではありません。

## **1. ボスのHPを減らす**

**【tama.dart】Playertama.onCollisionStart() 内**

```dart
if (other is boss) {
  if (boss_count > 0) {
    boss_count--;
    gameRef.HpTextRemove();
  }
}
```

衝突相手が `boss` なら、`boss_count` が正のときだけ1減らします。ステージ2の開始時に10に設定されるため、10→9→8のように減ります。

`HpTextRemove()` はHPバーを追加する処理です。バーの長さは `score.dart` が描画時に `boss_count` を読んで決めます。重複追加に関する注意点は `01_game.md` に記載しています。

この分岐には、当たった弾を消す処理や、ボスのHPが0になったときにボスを消す・ゴールにする処理はありません。

## **2. プレーヤーの残り数を減らす**

### **①コメントアウトされた旧処理**

**【tama.dart】Tekitama.onCollisionStart() 内**

```dart
// if (other is Player) {
//   removeFromParent();
//   player_count--;
// }
```

旧処理として残っているコメントでは、プレーヤーに当たると弾を消し、残り数を1減らすだけでした。

### **②現在の処理**

```dart
if (other is Player && !isGameOver && !isGoal) {
  removeFromParent();
  player_count--;

  if (player_count <= 0) {
    player_count = 0;
    isGameOver = true;
    StopTimer = true;
    other.stopMovement();
    gameRef.gameoverRemove();
  }
}
```

`!isGameOver && !isGoal` により、ゲームオーバー後やゴール後は、この分岐で残り数を減らしません。

弾が当たると弾を消して残り数を1減らします。残り数が0以下になると、次の処理を行います。

1. `player_count` を0にそろえる。
2. `isGameOver` を `true` にする。
3. `StopTimer` を `true` にしてタイマーを止める。
4. `stopMovement()` でプレーヤーの移動を止める。
5. `gameoverRemove()` でゲームオーバー表示の処理を呼ぶ。

## **3. その他の衝突処理**

以下も両ファイルに共通する既存の処理です。

| プレーヤーの弾が当たった相手 | 現在の処理 |
| --- | --- |
| 障害物 `triangle` | 弾を消す |
| 通常の敵 `Teki` | 弾と敵を消す |
| ボス `boss` | HPが正なら1減らし、HPバー追加処理を呼ぶ |

## **確認すること**

- プレーヤーの弾がボスに当たるとHPが減るか。
- 敵の弾が当たると弾が消え、プレーヤーの残り数が1減るか。
- 残り数が0になると移動とタイマーが止まり、ゲームオーバー表示が出るか。
- ゴール後やゲームオーバー後に残り数が減らないか。

※ソースを確認してまとめています。ゲームの実行確認は行っていません。
