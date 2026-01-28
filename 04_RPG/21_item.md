# **21_item**

**①アイテムの表示**

**【setting.dart】**

```dart

  class ItemData {
  final int idx;
  final String id; // 保存やインベントリ用キー 例: "ink"
  final String name; // 表示名
  final String imagePath; // Sprite画像
  final double size_x;
  final double size_y;
  final double pos_x;
  final double pos_y;
  final int amount; // 取得数（1個拾うなら1）

  ItemData({
    required this.idx,
    required this.id,
    required this.name,
    required this.imagePath,
    required this.size_x,
    required this.size_y,
    required this.pos_x,
    required this.pos_y,
    this.amount = 1,
  });
}

final List<ItemData> FieldItemList = [
  ItemData(
    idx: 0,
    id: "item01",
    name: "アイテム①",
    imagePath: "item01.png",
    size_x: 50,
    size_y: 50,
    pos_x: 300,
    pos_y: 300,
    amount: 1,
  ),
  ItemData(
    idx: 1,
    id: "item02",
    name: "アイテム②",
    imagePath: "item02.png",
    size_x: 50,
    size_y: 50,
    pos_x: 500,
    pos_y: 420,
    amount: 1,
  ),
];

```

**【item.dart】**

```dart

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'game.dart';
import 'player.dart';
import 'setting.dart';

class FieldItem extends SpriteComponent
    with HasGameRef<MainGame>, CollisionCallbacks {
  final ItemData data;

  FieldItem(this.data);

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(data.imagePath);
    size = Vector2(data.size_x, data.size_y);
    position = Vector2(data.pos_x, data.pos_y);
    anchor = Anchor.center;
    priority = 50; // playerより前に出したければ調整

    add(RectangleHitbox.relative(
      Vector2(0.8, 0.8),
      parentSize: size,
    ));
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);

    // フィールド(main)だけ拾える
    if (scene == "main" && other is Player) {
      gameRef.addItemToInventory(data.id, data.amount);
      gameRef.showMessage('${data.name} を手に入れた！');
      removeFromParent();
    }
  }
}

```

**【game.dart】**

```dart

import 'package:flame/collisions.dart';
import 'item.dart';

//⭐️HasCollisionDetection追加
class MainGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {

//省略

      case "main":
        for (int i = 0; i < 1; i++) {
          BackScreenImg _backscreenimg = BackScreenImg(BackGroundlist[1], i);
          await world.add(_backscreenimg);
        }
        player = Player("player1", PlayerList[0]);
        await world.add(player);

        //⭐️
        for (final itemData in FieldItemList) {
          await world.add(FieldItem(itemData));
        }

        break;
      case "battle":

//省略

  Future<void> spawnEnemy() async {
    final teki = await Teki.loadOrRandom();
    currentEnemy = teki;
    await world.add(teki);
  }

  //⭐️追加
  final Map<String, int> inventory = {};
  //⭐️追加
  void addItemToInventory(String id, int amount) {
    inventory[id] = (inventory[id] ?? 0) + amount;
    print('inventory[$id] = ${inventory[id]}');
  }

  //⭐️追加
  String? message;
  bool showMessageBox = false;

  void showMessage(
    String text, {
    Duration duration = const Duration(seconds: 2),
  }) async {
    message = text;
    showMessageBox = true;
    overlays.add('MessageBox');

    await Future.delayed(duration);

    overlays.remove('MessageBox');
    showMessageBox = false;
  }

```

**【main.dart】**

```dart

class _MyHomePageState extends State<MyHomePage> {
  final focusNode = FocusNode()..requestFocus();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('GAME'),
        ),
        body: GameWidget(
          game: MainGame(context),
          focusNode: focusNode,
          overlayBuilderMap: {
            'PauseMenu': (context, game) =>
                PauseMenuOverlay(game: game as MainGame),
            //⭐️追加
            'MessageBox': (context, game) =>
                MessageBoxOverlay(game: game as MainGame),
          },
        ));
  }
}

//⭐️一番下に追加
class MessageBoxOverlay extends StatelessWidget {
  final MainGame game;
  const MessageBoxOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    if (!game.showMessageBox || game.message == null) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 40),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          game.message!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

```

**【player.dart】**

```dart

//⭐️追加
import 'package:flame/collisions.dart';


//⭐️onLoadに追加
add(RectangleHitbox());

```