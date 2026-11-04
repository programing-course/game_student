# **09_3方向弾の残り時間を表示する**

## **この単元でやること**

1. ジャンプ強化の案内の下に、3方向弾の残り時間を表示する
2. 弾の強化が切れたら、残り時間の表示を消す

`stagetxt11.dart` の「⭐️」を目印に、`stagetxt.dart` の `ScoreText` を修正します。08で追加した `shotPowerRemaining` を使います。

## **1. 3方向弾の表示に使う変数を追加する**

**【stagetxt.dart】`ScoreText` の `powerIcons` の後**

`shotStatus` は3方向弾の残り時間を表示するテキストです。`late` を付けて宣言し、`onLoad()` で中身を設定します。

```dart
late TextComponent shotStatus;
```

## **2. 残り時間を表示する行を作る**

**【stagetxt.dart】`ScoreText.onLoad()` の `await add(powerStatus);` の後**

最初は空の文字列にします。ジャンプ強化の表示は `data.font_size + 8`、3方向弾の表示は `data.font_size + 36` の位置なので、3方向弾の行がその28ピクセル下に並びます。`await add(shotStatus)` で `ScoreText` の子として追加します。

```dart
//⭐️
shotStatus = TextComponent(
  text: '',
  position: Vector2(0, data.font_size + 36),
  textRenderer: TextPaint(
    style: TextStyle(
      fontSize: 20,
      color: data.color,
      fontFamily: 'NotoSansJP',
    ),
  ),
);

await add(shotStatus);
```

**【stagetxt.dart】`ScoreText.onLoad()` のフォント設定**

11版に合わせて、07でスコア本体の `TextStyle` に追加した `fontFamily: 'NotoSansJP'` を、ジャンプ強化の案内を表示する `powerStatus` の `TextStyle` に移します。3方向弾の表示にも同じフォントを指定しています。

```dart

// 残り時間の表示
powerStatus = TextComponent(
  text: '',
  position: Vector2(0, data.font_size + 8),
  textRenderer: TextPaint(
    style: TextStyle(
      fontSize: 20,
      color: data.color,
      fontFamily: 'NotoSansJP',
    ),
  ),
);
```

## **3. 強化中だけ残り時間を表示する**

**【stagetxt.dart】`ScoreText.update()` のアイコンを並べるループの後**

プレイヤーの `shotPowerRemaining` を毎フレーム読み取ります。0より大きい間は `toStringAsFixed(1)` で小数第1位まで表示します。0になったら空の文字列に戻します。

```dart
//⭐️
final shotRemaining = gameRef.player.shotPowerRemaining;

//⭐️
shotStatus.text =
    shotRemaining > 0 ? '3方向弾：残り ${shotRemaining.toStringAsFixed(1)}秒' : '';
```

## **確認すること**

- ステージ1で弾の強化アイテムを拾うと、`3方向弾：残り 5.0秒` のような表示が出る。
- 時間が経つにつれて、表示される秒数が減る。
- 強化中にEキーを押すと3方向に発射する。約5秒で残り時間の表示が消え、Eキーで通常弾が1発出る。

※ソースを確認してまとめています。ゲームの実行確認は行っていません。

.
..
