# **01_ステージ2のボスと画面表示**

## **この単元で確認すること**

1. ステージ2にボスを配置する
2. 案内文とHPバーを画面に表示する

## **比較結果**

**【game01.dart → game.dart】**

現在の2ファイルは同じ内容で、差分はありません。以下は「⭐️」コメントを中心に現在の処理をまとめたものです。今回の追加・変更と確認できたものではありません。

## **1. ボスと案内文を表示する**

**【game.dart】objectRemove() の case 1**

```dart
case 1:
  // ⭐️復活
  boss _boss = boss(bosslist[0]);
  await world.add(_boss);
  //⭐️ await bossRandom();

  TextDisplay _text1 = TextDisplay(Textlist[0]);
  await cameraComponent.viewport.add(_text1); //⭐️

  boss_count = 10;
  await HpTextRemove();

  break;
```

`currentStage == 1` がステージ2です。`bosslist[0]` の設定でボスを1体作り、ゲームの世界である `world` に追加します。ランダム出現を開始する `bossRandom()` の呼び出しはコメントアウトされています。

案内文は `Textlist[0]` の「敵を１０体倒そう！」です。`viewport` に追加すると、カメラが移動しても画面内の同じ位置に表示する構成になります。

`boss_count` はここで10に設定されます。現在のコードでは、ボスの残りHPとして使われています。案内文の「10体」と実際の処理には違いがあります。

## **2. HPバーを表示する**

**【game.dart】HpTextRemove()**

```dart
Future<void> HpTextRemove() async {
  if (world.children.whereType<HpBar>().isEmpty) {
    await cameraComponent.viewport.add(HpBar()); //⭐️
  }
}
```

HPバーも `viewport` に追加します。`score.dart` の `HpBar` は、描画時に `boss_count` を読み取り、10を最大値としてバーの長さを決めます。

**現在の注意点：** 重複確認は `world.children` に対して行いますが、追加先は `viewport` です。この条件では `viewport` の既存バーを検出できないため、弾がボスに当たって再度呼ばれるとHPバーが重複する可能性があります。

## **確認すること**

- ステージ2でボスが1体配置されるか。
- カメラが移動しても案内文とHPバーの表示位置が固定されるか。

※ソースを確認してまとめています。ゲームの実行確認は行っていません。
