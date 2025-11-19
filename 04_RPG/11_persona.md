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

**【player.dart】**

```dart

//⭐️Future<void>に変更
Future<void> attack() async {
    await gameRef.EffectRemove();

    final enemyAtk = gameRef.currentEnemy?.data.attack;
    final damage = enemyAtk ?? data.attack;

    _updateSelection(0);//⭐️追加
    await _announce('プレーヤー１の攻撃');//⭐️追加

    for (final teki in gameRef.world.children.whereType<Teki>()) {
      teki.applyDamage(damage);
      teki.hitShake();
    }

    await Future.delayed(const Duration(seconds: 3));

    _updateSelection(1);
    await _announce('プレーヤー２の攻撃');//⭐️追加

    await Future.delayed(const Duration(seconds: 2));//⭐️追加

    await gameRef.EffectRemove();//⭐️追加

    for (final teki in gameRef.world.children.whereType<Teki>()) {
      teki.applyDamage(damage);
      teki.hitShake();
    }

    //⭐️以下追加
    await Future.delayed(const Duration(seconds: 4));

    _updateSelection(0);

    await Future.delayed(const Duration(seconds: 1));

    // 敵の攻撃
    _queueEnemyCounter();

    await Future.delayed(const Duration(seconds: 3));

    _updateSelection(1);

    // 敵の攻撃
    _queueEnemyCounter();
  }

  //⭐️追加
  Future<void> _announce(String msg) async {
    final a = BattleAnnouncement(msg, duration: 1.2);
    gameRef.add(a);
    await a.completed; // 表示が消えるまで待機
  }

```

**【ui.dart】**

```dart
import 'dart:async';
import 'dart:ui';

class BattleAnnouncement extends TextComponent with HasGameRef<MainGame> {
  BattleAnnouncement(
    String text, {
    this.duration = 1.2,
  }) : super(
          text: text,
          anchor: Anchor.center,
        );

  final double duration;
  double _elapsed = 0;
  double _opacity = 1.0;
  final Completer<void> _done = Completer<void>();
  Future<void> get completed => _done.future;

  @override
  Future<void> onLoad() async {
    gameRef.camera.viewport.add(this);

    position = gameRef.size / 2;
    anchor = Anchor.center;
    priority = 1000;
    scale = Vector2.all(0.8);

    textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.w900,
        shadows: [Shadow(blurRadius: 4, offset: Offset(2, 2))],
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    // 拡大演出
    final t = (_elapsed / duration).clamp(0.0, 1.0);
    final scaleT = t < 0.25 ? (0.8 + 0.2 * (t / 0.25)) : 1.0;
    scale = Vector2.all(scaleT);

    // 不透明度フェードアウト
    _opacity = (1.0 - t).clamp(0.0, 1.0);

    // テキストのスタイル更新
    textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.white.withOpacity(_opacity),
        fontSize: 32,
        fontWeight: FontWeight.w900,
        shadows: const [Shadow(blurRadius: 4, offset: Offset(2, 2))],
      ),
    );

    if (_elapsed >= duration) {
      if (!_done.isCompleted) _done.complete();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    // TextPainter で文字サイズ取得
    final textPaint = textRenderer as TextPaint;
    final tp = textPaint.toTextPainter(text);
    tp.layout();

    final w = tp.width;
    final h = tp.height;
    const paddingH = 24.0;
    const paddingV = 12.0;

    // anchor = center 前提で、(0,0) を中央として計算
    final bgRect = Rect.fromLTWH(
      -w / 2 - paddingH / 2,
      -h / 2 - paddingV / 2,
      w + paddingH,
      h + paddingV,
    );

    final bgPaint = Paint()
      ..color =
          const Color.fromARGB(255, 255, 247, 0).withOpacity(0.6 * _opacity);

    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(12)),
      bgPaint,
    );

    // テキストも中央基準で描画（左上を -w/2, -h/2 に）
    tp.paint(canvas, Offset(-w / 2, -h / 2));
  }

  @override
  void onRemove() {
    if (!_done.isCompleted) _done.complete();
    super.onRemove();
  }
}

```