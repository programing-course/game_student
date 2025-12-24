# **19_backscreen**

**①背景をつける**

**【setting.dart】**

```dart

  class BackGroundData {
  final int idx;
  final Color color1;
  final Color color2;
  final double size_x;
  final double size_y;
  final double pos_x;
  final double pos_y;
  final String background_img;

  BackGroundData({
    required this.idx,
    required this.color1,
    required this.color2,
    required this.size_x,
    required this.size_y,
    required this.pos_x,
    required this.pos_y,
    required this.background_img,
  });
}

List<BackGroundData> BackGroundlist = [
  BackGroundData(
    idx: 0,
    color1: Color.fromARGB(255, 68, 185, 183),
    color2: Color.fromARGB(255, 203, 249, 240),
    size_x: FIELD_SIZE_X,
    size_y: FIELD_SIZE_Y,
    pos_x: 0,
    pos_y: 0,
    background_img: "",
  ),
  BackGroundData(
    idx: 1,
    color1: Color.fromARGB(255, 152, 193, 255),
    color2: Color.fromARGB(255, 152, 193, 255),
    size_x: SCREENSIZE_X * 2,
    size_y: SCREENSIZE_Y * 2,
    pos_x: 0,
    pos_y: 0,
    background_img: "map.png",
  ),
  BackGroundData(
    idx: 2,
    color1: Color.fromARGB(255, 154, 170, 193),
    color2: Color.fromARGB(255, 154, 170, 193),
    size_x: SCREENSIZE_X,
    size_y: SCREENSIZE_Y,
    pos_x: 0,
    pos_y: 0,
    background_img: "map.png",
  )
];


```

**【game.dart】**

```dart

Future<void> objectRemove() async {
    await CameraRemove();

    print("===scene===${scene}");
    switch (scene) {
      case "main":
        //⭐️ 背景インスタンス作成
        for (int i = 0; i < 1; i++) {
          BackScreenImg _backscreenimg = BackScreenImg(BackGroundlist[1], i);
          await world.add(_backscreenimg);
        }

        player = Player("player1", PlayerList[0]);
        await world.add(player);
        break;
      case "battle":
        //省略

        break;
      default:
    }
  }

```

**【screen.dart】**

```dart

class BackScreenImg extends SpriteComponent with HasGameRef<MainGame> {
  BackScreenImg(
    this.data,
    this.count_x,
  );
  final BackGroundData data;
  int count_x;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(data.background_img);
    size = Vector2(data.size_x, data.size_y);
    position = Vector2(data.pos_x + SCREENSIZE_X * count_x, data.pos_y);
  }

  @override
  Future<void> render(Canvas canvas) async {
    super.render(canvas);
  }
}

```
