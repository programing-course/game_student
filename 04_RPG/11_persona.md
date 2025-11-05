# **11_persona**

**【ui.dart】**

ペルソナ選択

```dart

class Persona extends TextBoxComponent
    with HasGameRef<MainGame>, KeyboardHandler {
  List<String> options = [];
  int selectedIndex = 0;

  @override
  Future<void> onLoad() async {
    for (var i = 0; i < PersonaList.length; i++) {
      options.add(PersonaList[i]);
    }
  }

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
        _enter();
        return true;
      }
    }
    return false;
  }

  void _moveSelectionDown() {
    if (options.isEmpty) return;
    selectedIndex = (selectedIndex + 1) % options.length;
    print("選択中の項目:${options[selectedIndex]}");
  }

  void _moveSelectionUp() {
    if (options.isEmpty) return;
    selectedIndex = (selectedIndex - 1 + options.length) % options.length;
    print("選択中の項目:${options[selectedIndex]}");
  }

  void _enter() async {
    selectedPlayer.attack();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final textPainter = TextPainter(
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    const EdgeInsets padding =
        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0);

    for (int i = 0; i < options.length; i++) {
      textPainter.text = TextSpan(
        text: options[i],
        style: TextStyle(
          backgroundColor: Colors.white,
          color: i == selectedIndex ? Colors.red : Colors.black,
          fontSize: 24,
        ),
      );

      textPainter.layout();

      final double textWidth = textPainter.width + padding.horizontal;
      final double textHeight = textPainter.height + padding.vertical;
      final double xPosition = 100 - padding.left;
      final double yPosition = 200 + i * (textHeight + 10) - padding.top;

      final RRect rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(xPosition, yPosition, textWidth, textHeight),
        Radius.circular(12),
      );

      canvas.drawRRect(rrect, Paint()..color = Colors.white);
      textPainter.paint(canvas, Offset(100, 200 + i * (textHeight + 10)));
    }
  }
}

```

**【game.dart】**


```dart

@override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // 先に子へ配信 → UI(Persona) が最優先で受ける
    final r = super.onKeyEvent(event, keysPressed);
    if (r == KeyEventResult.handled) return r;

    if (scene == "battle" && _battleInitialized) {
      if (event is KeyDownEvent) {
        if (keysPressed.contains(LogicalKeyboardKey.digit1)) {
          _updateSelection(0);
          return KeyEventResult.handled;
        } else if (keysPressed.contains(LogicalKeyboardKey.digit2)) {
          _updateSelection(1);
          return KeyEventResult.handled;
        } else if (keysPressed.contains(LogicalKeyboardKey.keyE)) {
          _persona ??= Persona(); // ← 多重追加防止
          add(_persona!);
          print("Persona added");
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  Persona? _persona;
  

```

**【game.dart】**


```dart

class KeySpy extends Component with KeyboardHandler {
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // ここは絶対にイベントを消費しない
    print('[KeySpy] $event keys=$keysPressed');
    return false;
  }
}

```

**【setting.dart】**

```dart

List PersonaList = [
  "persona1",
  "persona2",
  "persona3",
];


```