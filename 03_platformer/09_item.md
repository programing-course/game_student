# **０９_アイテムを取得**
（目安：1回）

## **この単元でやること**

1. コインの作り方
2. コインゲット

## **1. コインの作り方**

![item](img/09_item1-1.png)
![item](img/09_item1-2.png)

### **①位置データを作成**

**【setting.dart】**

```dart

//⭐️追加
class CoinData {
  final int idx;
  final double size_x;
  final double size_y;
  final double pos_x;
  final double pos_y;
  final String coin_img;

  CoinData({
    required this.idx,
    required this.size_x,
    required this.size_y,
    required this.pos_x,
    required this.pos_y,
    required this.coin_img,
  });
}

List<CoinData> coinlist = [
  CoinData(
    idx: 0,
    size_x: 30,
    size_y: 30,
    pos_x: screenSize.x * 3 / 4 + 50,
    pos_y: screenSize.y * 1 / 3 - 45,
    coin_img: 'coin.png',
  ),
  CoinData(
    idx: 1,
    size_x: 30,
    size_y: 30,
    pos_x: screenSize.x * 0.5,
    pos_y: Y_GROUND_POSITION - 100,
    coin_img: 'coin.png',
  ),
];

```

### **②オブジェクト作成**

**【object.dat】**

一番下に追加

```dart

//⭐️追加
class coin extends SpriteComponent
    with HasGameRef<MainGame>, CollisionCallbacks {
  coin(this.data, this.count_x, this.count_y, this.gap);
  final CoinData data;
  int count_x;
  int count_y;
  double gap;

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(data.coin_img);
    size = Vector2(data.size_x, data.size_y);
    position = Vector2(data.pos_x + (gap + data.size_x) * count_x,
        data.pos_y + (gap + data.size_y) * count_y);
    anchor = Anchor.center;

    add(RectangleHitbox());
  }
}

```

### **③インスタンス作成**

**【game.dart】**

objectRemove()関数内に作る

```dart

    //⭐️追加
    coin _coin = coin(coinlist[0], 1, 1, 0);
    await world.add(_coin);
    
    //⭐️追加
    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 3; j++) {
        coin _coin1 = coin(coinlist[1], j, i, 10);
        await world.add(_coin1);
      }
    }

```

![item](img/09_item1-3.png)

## **2. コインゲット**

**【player.dart】**

```dart

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {

    //省略

    //⭐️追加
    if (other is coin) {
      other.removeFromParent();
    }

  }

```

![item](img/09_item1-4.png)