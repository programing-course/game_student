# **02_ステージに合わせてフィールドとカメラの範囲を変更する**

## **この単元でやること**

1. ステージごとにフィールドの横幅を切り替える
2. ステージごとにカメラの停止位置を切り替える

ソース内の「⭐️」が付いた箇所を修正します。掲載コードは現在の `setting.dart` に合わせています。

## **1. フィールドの横幅を変更する**

**【setting.dart】**

固定値の設定をコメントアウトし、ステージに合わせて値を返す getter に変更します。

```dart
//⭐️ final FIELD_SIZE_X = screenSize.x * 4;

//⭐️
double get FIELD_SIZE_X {
  switch (currentStage) {
    case 0: // STAGE1
      return screenSize.x * 4;
    case 1: // STAGE2
      return screenSize.x * 2;
    default:
      return screenSize.x * 4;
  }
}
```

`screenSize.x` は画面の横幅です。ステージ1は画面4枚分、ステージ2は画面2枚分にします。

`get` を使うと、`FIELD_SIZE_X` を参照するたびに現在の `currentStage` に応じた値を返せます。`currentStage` が0ならステージ1、1ならステージ2です。

## **2. カメラの停止位置を変更する**

**【setting.dart】**

`VIEW_X_END` も固定値の設定をコメントアウトし、getter に変更します。

```dart
//⭐️ final VIEW_X_END = FIELD_SIZE_X - screenSize.x * (1 - CAMERA_POSITION_X);

//⭐️
double get VIEW_X_END {
  // STAGE2
  if (currentStage == 1) {
    return screenSize.x * 2 - screenSize.x * (1 - CAMERA_POSITION_X);
  }

  // STAGE1など
  return FIELD_SIZE_X - screenSize.x * (1 - CAMERA_POSITION_X);
}
```

`VIEW_X_END` はカメラが右方向への追従を止める位置です。フィールドの横幅から、カメラの基準位置より右側に映る幅を引いて求めます。

画面幅1000、`CAMERA_POSITION_X = 0.3` の場合：

| 項目 | ステージ1 | ステージ2 |
| --- | ---: | ---: |
| フィールドの横幅 | 4000 | 2000 |
| カメラ停止位置 | 3300 | 1300 |

補足：`setting02.dart` のステージ2の倍率は `1.5`、現在の `setting.dart` は `2` です。掲載コードでは現在の値に統一しています。

## **確認すること**

- ステージに合わせてフィールドの横幅が切り替わる。
- カメラが各ステージの右端に合わせた位置で止まる。

※ソースを確認してまとめています。ゲームの実行確認は行っていません。

