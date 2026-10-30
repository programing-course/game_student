# **03_ステージ2の制限時間を表示する**

## **この単元で確認すること**

1. ステージ2で60秒のカウントダウンを表示する
2. 残り時間が0になったらゲームオーバーにする

## **比較結果**

**【stagetxt03.dart → stagetxt.dart】**

現在の2ファイルは同じ内容で、差分はありません。以下は「⭐️」コメントとコメントアウトされた旧処理を手がかりに、現在の処理をまとめたものです。

## **1. 制限時間と最初の表示を設定する**

**【stagetxt.dart】countTimer クラス**

```dart
Stopwatch _stopwatch = Stopwatch();
final double timeLimit = 60.0; //⭐️
```

`Stopwatch` で経過時間を測り、`timeLimit` に制限時間を秒単位で設定します。

**【stagetxt.dart】countTimer.onLoad() 内**

```dart
_stopwatch.start();
position = Vector2(data.pos_x, data.pos_y);
//⭐️ text = 'Time: 0.0';
//⭐️
text = currentStage == 1
    ? 'Time: ${timeLimit.toStringAsFixed(1)}'
    : 'Time: 0.0';
```

ステージ2では `Time: 60.0`、それ以外では `Time: 0.0` を表示して始めます。`toStringAsFixed(1)` は小数点以下を1桁にそろえます。

## **2. 残り時間を計算する**

**【stagetxt.dart】countTimer.update() 内**

```dart
elapsedTime = _stopwatch.elapsedMilliseconds / 1000.0;

if (StopTimer) {
  _stopwatch.stop();
  return;
}
```

ミリ秒を1000で割り、秒に換算します。`StopTimer` が `true` なら計測を止め、その後の表示更新を終了します。

**【stagetxt.dart】countTimer.update() 内の表示処理**

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

残り時間は「60秒 − 経過時間」です。例えば12.3秒経過すると47.7秒になります。`clamp(0.0, timeLimit)` で値を0〜60の範囲に収めます。

残り時間が0になり、ゲームオーバーにもゴールにもなっていなければ、タイマーを止めてゲームオーバー表示の処理を呼びます。ステージ1などでは経過時間が増える表示を使います。

## **確認すること**

- ステージ2で60.0から残り時間が減るか。
- 残り時間がマイナスにならず、0でゲームオーバーになるか。
- ステージ1では経過時間が増えるか。

※ソースを確認してまとめています。ゲームの実行確認は行っていません。
