# **01_ボスの配置と画面表示を変更する**

## **この単元でやること**

1. 固定位置のボスを復活させる
2. 案内文とHPバーを画面に固定する

ソース内の「⭐️」が付いた箇所を修正します。

## **1. 固定位置のボスを復活させる**

**【game.dart】objectRemove() の case 1**

ボスを作成する処理を有効に戻し、ランダム出現の呼び出しをコメントアウトします。

```dart
case 1:
  // ⭐️復活
  boss _boss = boss(bosslist[0]);
  await world.add(_boss);
  //⭐️ await bossRandom();
```

ステージ2では、`bosslist[0]` の設定位置にボスを1体配置します。

## **2. 案内文を画面に固定する**

**【game.dart】objectRemove() の case 1 の続き**

```dart
TextDisplay _text1 = TextDisplay(Textlist[0]);
await cameraComponent.viewport.add(_text1); //⭐️

boss_count = 10;
await HpTextRemove();
```

「⭐️」の行で、案内文の追加先を `cameraComponent.viewport` に変更します。ゲーム内の座標ではなく画面内の座標で表示されるため、カメラが動いても案内文が流れなくなります。

前後の `boss_count = 10` と `HpTextRemove()` は、ボスのHPを10にしてHPバーを表示する処理です。

## **3. HPバーを画面に固定する**

**【game.dart】HpTextRemove()**

```dart
Future<void> HpTextRemove() async {
  if (world.children.whereType<HpBar>().isEmpty) {
    await cameraComponent.viewport.add(HpBar()); //⭐️
  }
}
```

HPバーの追加先も `cameraComponent.viewport` に変更します。カメラが動いてもHPバーを画面内の同じ位置に表示できます。

補足：このコードの重複確認は `world.children`、追加先は `viewport` です。既存のHPバーを検出する場所が一致していないため、繰り返し呼ぶとバーが重複する可能性があります。

## **確認すること**

- ステージ2に固定位置のボスが出現する。
- カメラが動いても案内文とHPバーの画面内の位置が変わらない。

※ソースを確認してまとめています。ゲームの実行確認は行っていません。

