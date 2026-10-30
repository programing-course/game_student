# **02_ステージ2の横幅とカメラ停止位置を変更する**

## **この単元でやること**

1. ステージ2の横幅を画面の1.5倍から2倍にする
2. 横幅に合わせてカメラの停止位置を変更する

## **比較結果**

**【setting02.dart → setting.dart】**

処理に関わる差分は、ステージ2の横幅とカメラ停止位置の倍率を `1.5` から `2` に変える2か所です。そのほかに「⭐️」コメントの追加があります。

## **1. フィールドの横幅を変更する**

**【setting.dart】FIELD_SIZE_X**

変更前：

```dart
case 1: // STAGE2
  return screenSize.x * 1.5;
```

変更後：

```dart
double get FIELD_SIZE_X {
  switch (currentStage) {
    case 0: // STAGE1
      return screenSize.x * 4;
    case 1: // STAGE2
      return screenSize.x * 2; //⭐️変更
    default:
      return screenSize.x * 4;
  }
}
```

`screenSize.x` は画面の横幅です。ステージ2を画面2枚分の横幅にします。画面幅が1000なら、1500から2000に広がります。

`get` を使う構造は番号付きファイルにもあります。今回の差分は、ステージ2で返す倍率の変更です。

## **2. カメラの停止位置を変更する**

**【setting.dart】VIEW_X_END**

変更前：

```dart
return screenSize.x * 1.5 - screenSize.x * (1 - CAMERA_POSITION_X);
```

変更後：

```dart
double get VIEW_X_END {
  // STAGE2
  if (currentStage == 1) {
    return screenSize.x * 2 - screenSize.x * (1 - CAMERA_POSITION_X); //⭐️変更
  }

  // STAGE1など
  return FIELD_SIZE_X - screenSize.x * (1 - CAMERA_POSITION_X);
}
```

`VIEW_X_END` はカメラが右方向への追従を止める位置です。フィールドを広げた分、カメラも右へ進めるようにします。

現在の `CAMERA_POSITION_X` は `0.3` です。画面幅1000の場合は次の値になります。

| 項目 | 変更前 | 変更後 |
| --- | ---: | ---: |
| ステージ2の横幅 | 1500 | 2000 |
| カメラ停止位置 | 800 | 1300 |

## **3. コメントの変更**

固定値だった設定のコメントと、`FIELD_SIZE_X` の getter の前に「⭐️」が追加されています。コメント自体は動作に影響しません。

## **確認すること**

- ステージ2の横幅が画面2枚分になるか。
- カメラが新しい停止位置まで追従するか。
- ステージ1の横幅が画面4枚分のままか。

※ソースの差分を確認してまとめています。ゲームの実行確認は行っていません。
