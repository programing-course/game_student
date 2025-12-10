# **16_attack3**

**①spaceで通常攻撃**

**【game.dart】**


```dart

  bool isGuarding = false;
  bool isPlayerActing = false; //⭐️

  //省略

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {

        //省略

      if (event.logicalKey == LogicalKeyboardKey.keyC) {
        isGuarding = true;
        print("Guard!!");
        return KeyEventResult.handled;
      }

      // ⭐️Space で通常攻撃
      if (keysPressed.contains(LogicalKeyboardKey.space)) {
        if (isPlayerActing) return KeyEventResult.handled;
        isPlayerActing = true;

        selectedPlayer.attack().whenComplete(() {
          isPlayerActing = false;
        });

        return KeyEventResult.handled;
      }

  }

```

**【ui.dart】**


```dart
@override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _moveSelectionDown();
        return true; // このコンポーネントで処理済み
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _moveSelectionUp();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        //⭐️
        if (isPlayerActing) {
          return true;
        }
        isPlayerActing = true;//⭐️

        //⭐️
        _enter().whenComplete(() {
          isPlayerActing = false;
        });
        return true;
      }
    }
    return false;
  }

```
