# **20_panel**

**①パネルからフィールドに戻る**

**【main.dart】**

ESCパネルの一番下のボタンを修正

```dart

  ElevatedButton(
    onPressed: () async {
      await widget.game.returnToField();
    },
    child: const Text('フィールドに戻る'),
  ),


```

**【game.dart】**

```dart

  Future<void> returnToField() async {
    // メニューを閉じる
    if (overlays.isActive('PauseMenu')) {
      overlays.remove('PauseMenu');
    }

    // バトル系フラグをリセット
    isPlayerActing = false;
    isGuarding = false;
    _battleInitialized = false;

    // バトル用参照をリセット（敵/ペルソナなど）
    currentEnemy = null;
    _persona?.removeFromParent();
    _persona = null;

    // シーン変更
    scene = "main";
    CameraOn = true;

    // いま表示されてる world の中身を全部消して作り直す
    await AllRemove();
    await objectRemove();
  }

```