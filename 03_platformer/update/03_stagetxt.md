# **03_制限時間とゴール表示を変更する**

## **この単元でやること**

1. ステージ2に60秒の制限時間を付ける
2. ゴール表示をプレーヤーの頭上に出す
3. 記録表示をステージ名で上書きしないようにする

ソース内の「⭐️」が付いた箇所を修正します。

## **1. 制限時間を追加する**

**【stagetxt.dart】countTimer クラス**

```dart
Stopwatch _stopwatch = Stopwatch();
final double timeLimit = 60.0; //⭐️
```

制限時間を秒単位で設定します。

## **2. 最初の時間表示を切り替える**

**【stagetxt.dart】countTimer.onLoad() 内**

これまでの表示をコメントアウトして、ステージごとに切り替えます。

```dart
//⭐️ text = 'Time: 0.0';
//⭐️
text = currentStage == 1
    ? 'Time: ${timeLimit.toStringAsFixed(1)}'
    : 'Time: 0.0';
```

ステージ2は `Time: 60.0`、それ以外は `Time: 0.0` で始まります。`toStringAsFixed(1)` は、小数点以下を1桁にそろえる処理です。

## **3. ステージ2をカウントダウンにする**

**【stagetxt.dart】countTimer.update() 内**

経過時間をそのまま表示していた行を、次の処理に置き換えます。

```dart
//⭐️ text = 'Time: ${elapsedTime.toStringAsFixed(1)}';
//⭐️
if (currentStage == 1) {
  // STAGE2：カウントダウン
  final remainingTime = (timeLimit - elapsedTime).clamp(0.0, timeLimit);

  text = 'Time: ${remainingTime.toStringAsFixed(1)}';

  if (remainingTime <= 0 && !isGameOver && !isGoal) {
    StopTimer = true;
    _stopwatch.stop();
    isGameOver = true;
    gameRef.gameoverRemove();
  }
} else {
  // STAGE1など：カウントアップ
  text = 'Time: ${elapsedTime.toStringAsFixed(1)}';
}
```

残り時間は「制限時間 − 経過時間」です。`clamp` で0〜60の範囲に収め、マイナス表示を防ぎます。

残り時間が0になったら、まだゴール・ゲームオーバーになっていない場合に計測を止め、ゲームオーバー表示の処理を呼びます。ステージ1などは、これまでどおり経過時間が増える表示です。

## **4. ゴール表示をプレーヤーの頭上に出す**

**【stagetxt.dart】goalText.onLoad() 内**

設定データの固定位置を使う処理をコメントアウトして、プレーヤーの位置から表示位置を求めます。

```dart
//⭐️ position = Vector2(data.pos_x, data.pos_y);

//⭐️ テキスト全体の下中央を基準にする
anchor = Anchor.bottomCenter;

//⭐️ プレーヤーの頭から30上に表示
position = Vector2(
  gameRef.player.position.x,
  gameRef.player.position.y - gameRef.player.size.y / 2 - 30,
);
priority = 1000;
```

`Anchor.bottomCenter` により、テキスト全体の下中央を配置の基準にします。プレーヤーの中心から高さの半分を引いて頭の位置を求め、さらに30上に表示します。`priority` は1000にして表示順を調整します。

表示位置は `onLoad()` で決めます。プレーヤーがその後動いた場合に追従させる処理は、この修正には含まれていません。

## **5. 記録表示の上書きを止める**

**【stagetxt.dart】RecordText.update() 内**

次の行をコメントアウトします。

```dart
//⭐️ text = "STAGE" + (currentStage + 1).toString();
```

毎回の更新でテキストをステージ名に置き換えないようにします。この修正は上書きを止めるもので、記録文字列を新しく設定する処理の追加ではありません。

## **確認すること**

- ステージ2で残り時間が減り、0になるとゲームオーバーになる。
- ステージ1では経過時間が増える。
- ゴール時にプレーヤーの頭上へ案内が表示される。
- RecordTextが更新時にステージ名へ変わらない。

※ソースを確認してまとめています。ゲームの実行確認は行っていません。

