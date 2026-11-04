# **07_ジャンプ強化の所持数と残り時間を表示する**

## **この単元でやること**

1. コイン表示の横に、所持数と同じ数の強化アイコンを表示する
2. Qキーの案内と、強化中の残り時間を表示する

`stagetxt09.dart` の「⭐️」を目印に、`stagetxt.dart` の `ScoreText` クラスを修正します。06で追加したプレイヤーの `powerCount` と `jumpPowerRemaining` を使います。

## **1. 表示に使う変数を追加する**

**【stagetxt.dart】`ScoreText` の `final StageData data;` の後**

`powerStatus` に案内や残り時間を表示します。`displayedPowerCount` は最後にアイコンで表示した所持数です。初期値を `-1` にして、最初の更新で現在の所持数を反映します。`powerIcons` には表示中のアイコンを入れます。

```dart
late TextComponent powerStatus; //⭐️
int displayedPowerCount = -1; //⭐️
final List<SpriteComponent> powerIcons = []; //⭐️
```

## **2. アイコンの画像と案内文を準備する**

**【stagetxt.dart】`ScoreText.onLoad()` の `textRenderer` から末尾まで**

スコア文字列の `TextStyle` に `fontFamily: 'NotoSansJP'` を追加します。このフォント名は `pubspec.yaml` に登録されています。その後、`coinlist[2]` で指定した画像を読み込みます。案内文は空の状態で作り、スコアの下に表示できるよう `ScoreText` の子に追加します。

```dart
textRenderer = TextPaint(
  style: TextStyle(
    fontSize: data.font_size,
    fontWeight: FontWeight.bold,
    color: data.color,
    fontFamily: 'NotoSansJP',
  ),
);

//⭐️ setting.dart で指定したアイテム画像を読み込む
await gameRef.images.load(coinlist[2].coin_img);

//⭐️ 残り時間の表示
powerStatus = TextComponent(
  text: '',
  position: Vector2(0, data.font_size + 8),
  textRenderer: TextPaint(
    style: TextStyle(
      fontSize: 20,
      color: data.color,
    ),
  ),
);

await add(powerStatus);
```

## **3. アイコンと案内文を更新する**

**【stagetxt.dart】`ScoreText.update()` のスコア表示を更新する行の後**

強化中は残り時間を小数第1位まで表示します。強化が切れていて所持数が1個以上ならQキーの案内を出し、所持数が0なら表示を空にします。

アイコンの並びはスコア文字列の幅 `size.x` に合わせます。最初のアイコンは文字列の右端から10離し、次のアイコンは28ずつ右に置きます。

```dart
//⭐️ 所持数分のアイコンを更新
updatePowerIcons();

//⭐️ 効果時間の表示を更新
final remaining = gameRef.player.jumpPowerRemaining;

//⭐️
if (remaining > 0) {
  powerStatus.text = 'JUMP UP: 残り ${remaining.toStringAsFixed(1)}秒';
} else {
  powerStatus.text = gameRef.player.powerCount > 0 ? 'Q: ジャンプ強化を使う' : '';
}

//⭐️ コイン表示の右横にアイコンを並べる
for (int i = 0; i < powerIcons.length; i++) {
  powerIcons[i].position = Vector2(
    size.x + 10 + i * 28,
    0,
  );
}
```

## **4. 所持数が変わったときにアイコンを作り直す**

**【stagetxt.dart】`ScoreText` の `update()` の後**

`updatePowerIcons()` をクラス内に追加します。所持数が前回と同じなら処理を終えます。変わった場合は古いアイコンを取り除き、読み込み済みの画像を使って、所持数と同じ数の24×24のアイコンを作ります。

```dart
void updatePowerIcons() {
  final count = gameRef.player.powerCount;

  if (count == displayedPowerCount) {
    return;
  }

  for (final icon in powerIcons) {
    icon.removeFromParent();
  }
  powerIcons.clear();

  for (int i = 0; i < count; i++) {
    final icon = SpriteComponent(
      sprite: Sprite(
        gameRef.images.fromCache(coinlist[2].coin_img),
      ),
      size: Vector2(24, 24),
    );

    powerIcons.add(icon);
    add(icon);
  }

  displayedPowerCount = count;
}
```

## **確認すること**

- 強化アイテムを拾うと、コイン表示の右にアイコンが1個増え、下にQキーの案内が出る。
- Qキーを押すと、アイコンが1個減り、残り時間が小数第1位まで表示される。
- 強化が切れると、アイテムが残っていればQキーの案内に戻り、残っていなければ案内が消える。

ステージ1で確認する場合は、`game.dart` の `currentStage` の初期値を動作確認用に `0` にします。

※ソースを確認してまとめています。ゲームの実行確認は行っていません。

.
..
