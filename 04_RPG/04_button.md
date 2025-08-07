# **04_ボタンの表示**


**【setting.dart】**

```dart

class ButtonData {
  final int idx;
  final Color color1;
  final Color color2;
  final double size_x;
  final double size_y;
  final double pos_x;
  final double pos_y;
  final String background_img;
  final String label;

  ButtonData({
    required this.idx,
    required this.color1,
    required this.color2,
    required this.size_x,
    required this.size_y,
    required this.pos_x,
    required this.pos_y,
    required this.background_img,
    required this.label,
  });
}

List<ButtonData> Buttonlist = [
  ButtonData(
    idx: 0,
    color1: Color.fromARGB(255, 213, 43, 0),
    color2: Color.fromARGB(255, 255, 255, 255),
    size_x: 200.0,
    size_y: 50.0,
    pos_x: 50,
    pos_y: SCREENSIZE_Y / 2,
    background_img: "",
    label: "persona",
  ),
  ButtonData(
    idx: 0,
    color1: Color.fromARGB(255, 103, 92, 255),
    color2: Color.fromARGB(255, 255, 255, 255),
    size_x: 200.0,
    size_y: 50.0,
    pos_x: 50,
    pos_y: SCREENSIZE_Y / 2 + 70,
    background_img: "",
    label: "attack",
  ),
  ButtonData(
    idx: 0,
    color1: Color.fromARGB(255, 63, 173, 134),
    color2: Color.fromARGB(255, 255, 255, 255),
    size_x: 200.0,
    size_y: 50.0,
    pos_x: 50,
    pos_y: SCREENSIZE_Y / 2 + 140,
    background_img: "",
    label: "guard",
  ),
];


```

**【ui.dart】**

```dart

class Button extends RectangleComponent with HasGameRef<MainGame> {
  Button(this.data);
  final ButtonData data;

  @override
  Future<void> onLoad() async {
    position = Vector2(data.pos_x, data.pos_y);
    size = Vector2(data.size_x, data.size_y);
    paint = Paint()..color = data.color1;
    priority = 1000;

    // テキストを中央に配置
    final text = TextComponent(
      text: data.label, // ButtonData に `label` フィールドがあると仮定
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    )
      ..anchor = Anchor.center
      ..position = size / 2; // ボタンサイズの中央

    add(text);
  }

  @override
  void render(Canvas canvas) async {
    super.render(canvas);
  }
}


```

**【game.dart】**

```dart

Button _button1 = Button(Buttonlist[0]);
        await world.add(_button1);

        Button _button2 = Button(Buttonlist[1]);
        await world.add(_button2);

        Button _button3 = Button(Buttonlist[2]);
        await world.add(_button3);

```