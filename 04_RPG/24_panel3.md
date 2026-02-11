# **24_panel3**

**①アイテム、武器、素材の表示**

**【setting.dart】**

```dart

//⭐️コメントアウトfinal Map<String, int> inventory = {};

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

  //⭐️追加↓↓↓
  ItemData(
    idx: 2,
    id: "item03",
    name: "アイテム③",
    imagePath: "item03.png",
    size_x: 50,
    size_y: 50,
    pos_x: 500,
    pos_y: 420,
    amount: 1,
  ),
  ItemData(
    idx: 3,
    id: "item04",
    name: "アイテム④",
    imagePath: "item04.png",
    size_x: 50,
    size_y: 50,
    pos_x: 500,
    pos_y: 420,
    amount: 1,
  ),
  ItemData(
    idx: 4,
    id: "weapon01",
    name: "武器①",
    imagePath: "weapon01.png",
    size_x: 50,
    size_y: 50,
    pos_x: 500,
    pos_y: 420,
    amount: 1,
  ),
  ItemData(
    idx: 5,
    id: "weapon02",
    name: "武器②",
    imagePath: "weapon02.png",
    size_x: 50,
    size_y: 50,
    pos_x: 500,
    pos_y: 420,
    amount: 1,
  ),
  ItemData(
    idx: 6,
    id: "material01",
    name: "素材①",
    imagePath: "material01.png",
    size_x: 50,
    size_y: 50,
    pos_x: 500,
    pos_y: 420,
    amount: 1,
  ),
  ItemData(
    idx: 7,
    id: "material02",
    name: "素材②",
    imagePath: "material02.png",
    size_x: 50,
    size_y: 50,
    pos_x: 500,
    pos_y: 420,
    amount: 1,
  ),
  ItemData(
    idx: 8,
    id: "material03",
    name: "素材③",
    imagePath: "material03.png",
    size_x: 50,
    size_y: 50,
    pos_x: 500,
    pos_y: 420,
    amount: 1,
  ),
];

```

**②ランダムに表示する**

**【game.dart】**

```dart

class MainGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  final BuildContext context;
  MainGame(this.context);

  // カメラコンポーネントの追加
  late final CameraComponent cameraComponent;
  Player player =
      Player("player1", PlayerList[0]);

  Teki? currentEnemy;

  //⭐️追加
  final Map<String, int> itemInventory = {};
  final Map<String, int> weaponInventory = {};
  final Map<String, int> materialInventory = {};

  //省略

  switch (scene) {
      case "main":
        for (int i = 0; i < 1; i++) {
          BackScreenImg _backscreenimg = BackScreenImg(BackGroundlist[1], i);
          await world.add(_backscreenimg);
        }
        player = Player("player1", PlayerList[0])
          ..position = Vector2(PlayerPosition.x, PlayerPosition.y);

        await world.add(player);
        for (final itemData in FieldItemList) {
          if (itemInventory.containsKey(itemData.id)) continue; //⭐️修正

          await world.add(FieldItem(itemData));
        }

        break;
      case "battle":
  }

  //省略

  //⭐️コメントアウトfinal Map<String, int> inventory = {};

  //⭐️修正
  void addItemToInventory(String id, int amount) {
    if (id.startsWith("item")) {
      itemInventory[id] = (itemInventory[id] ?? 0) + amount;
      print('itemInventory[$id] = ${itemInventory[id]}');
    } else if (id.startsWith("weapon")) {
      weaponInventory[id] = (weaponInventory[id] ?? 0) + amount;
      print('weaponInventory[$id] = ${weaponInventory[id]}');
    } else if (id.startsWith("material")) {
      materialInventory[id] = (materialInventory[id] ?? 0) + amount;
      print('materialInventory[$id] = ${materialInventory[id]}');
    }

    saveInventory();
  }

  //省略

  //⭐️修正
  Future<void> saveInventory() async {
    print("===saveInventory===${itemInventory}");
    final prefs = await SharedPreferences.getInstance();
    final jsonStringitem = jsonEncode(itemInventory);
    final jsonStringweapon = jsonEncode(weaponInventory);
    final jsonStringmaterial = jsonEncode(materialInventory);
    await prefs.setString('itemInventory', jsonStringitem);
    await prefs.setString('weaponInventory', jsonStringweapon);
    await prefs.setString('materialInventory', jsonStringmaterial);
  }

  //⭐️修正
  Future<void> loadInventory() async {
    print("===loadInventory===");
    final prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
    final jsonStringitem = prefs.getString('itemInventory');
    final jsonStringweapon = prefs.getString('weaponInventory');
    final jsonStringmaterial = prefs.getString('materialInventory');
    print("itemInventory==${itemInventory}");

    if (jsonStringitem == null) return;
    if (jsonStringweapon == null) return;
    if (jsonStringmaterial == null) return;

    final Map<String, dynamic> mapitem = jsonDecode(jsonStringitem);
    itemInventory
      ..clear()
      ..addAll(mapitem.map((k, v) => MapEntry(k, v as int)));

    final Map<String, dynamic> mapweapon = jsonDecode(jsonStringweapon);
    weaponInventory
      ..clear()
      ..addAll(mapweapon.map((k, v) => MapEntry(k, v as int)));

    final Map<String, dynamic> mapmaterial = jsonDecode(jsonStringmaterial);
    materialInventory
      ..clear()
      ..addAll(mapmaterial.map((k, v) => MapEntry(k, v as int)));
  }



```

**【item.dart】**

```dart
//⭐️追加
import 'dart:math';

Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(data.imagePath);
    size = Vector2(data.size_x, data.size_y);
    //⭐️コメントアウトposition = Vector2(data.pos_x, data.pos_y);
    anchor = Anchor.center;
    priority = 50; // playerより前に出したければ調整

    //⭐️追加
    final rand = Random();

    // ★ フィールド内ランダム位置
    final double randomX =
        rand.nextDouble() * (FIELD_SIZE_X - size.x) + size.x / 2;

    final double randomY =
        rand.nextDouble() * (FIELD_SIZE_Y - size.y) + size.y / 2;

    position = Vector2(randomX, randomY);

```

**【main.dart】**

```dart

    final invEntries = widget.game.itemInventory.entries.toList(); //⭐️修正
    final invEntriesweapon = widget.game.weaponInventory.entries.toList(); //⭐️追加
    final invEntriesmaterial = widget.game.materialInventory.entries.toList(); //⭐️追加

    return Center(
      child: Container(
        width: 900,//⭐️修正

        //省略

        // アイテム表示ボタン
        ElevatedButton(
          onPressed: () {
            setState(() => showItems = !showItems);
          },
          child: Text(showItems ? 'アイテムを隠す' : 'アイテム'),
        ),

        if (showItems) ...[
          const SizedBox(height: 8),
          const Divider(color: Color.fromARGB(137, 0, 0, 0)),
          const SizedBox(height: 8),

          //アイテム一覧
          //⭐️条件追加
          if (invEntries.isEmpty &&
              invEntriesweapon.isEmpty &&
              invEntriesmaterial.isEmpty)
            const Text('アイテムなし', style: TextStyle(color: Colors.black))
          else
            //⭐️Row追加
            Row(
              mainAxisAlignment: MainAxisAlignment.center,//⭐️追加
              children: [
                Container(
                  width: 200,//⭐️追加
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: invEntries.map((e) {
                      final id = e.key;
                      final count = e.value;

                      // FieldItemList から id に一致する ItemData を探す
                      final itemData = FieldItemList.firstWhere(
                        (it) => it.id == id,
                        orElse: () => ItemData(
                          idx: -1,
                          id: id,
                          name: id, // 見つからない時は id 表示
                          imagePath: '',
                          size_x: 0,
                          size_y: 0,
                          pos_x: 0,
                          pos_y: 0,
                        ),
                      );

                      return _buildItemRow(itemData, count);
                    }).toList(),
                  ),
                ),
                //⭐️ここから下追加
                Container(
                  width: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: invEntriesweapon.map((e) {
                      final id = e.key;
                      final count = e.value;

                      // FieldItemList から id に一致する ItemData を探す
                      final itemData = FieldItemList.firstWhere(
                        (it) => it.id == id,
                        orElse: () => ItemData(
                          idx: -1,
                          id: id,
                          name: id, // 見つからない時は id 表示
                          imagePath: '',
                          size_x: 0,
                          size_y: 0,
                          pos_x: 0,
                          pos_y: 0,
                        ),
                      );

                      return _buildItemRow(itemData, count);
                    }).toList(),
                  ),
                ),
                Container(
                  width: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: invEntriesmaterial.map((e) {
                      final id = e.key;
                      final count = e.value;

                      // FieldItemList から id に一致する ItemData を探す
                      final itemData = FieldItemList.firstWhere(
                        (it) => it.id == id,
                        orElse: () => ItemData(
                          idx: -1,
                          id: id,
                          name: id, // 見つからない時は id 表示
                          imagePath: '',
                          size_x: 0,
                          size_y: 0,
                          pos_x: 0,
                          pos_y: 0,
                        ),
                      );

                      return _buildItemRow(itemData, count);
                    }).toList(),
                  ),
                ),
              ],
            ),
        ],

        //省略

class FieldMenuOverlay extends StatelessWidget {
  final MainGame game;
  const FieldMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final entries = game.itemInventory.entries.toList(); //⭐️修正
    final entriesweapon = game.weaponInventory.entries.toList(); //⭐️追加
    final entriesmaterial = game.materialInventory.entries.toList(); //⭐️追加

    return Center(
      child: Container(
        width: 900,//⭐️追加
        padding: const EdgeInsets.all(16),
        color: Colors.black.withOpacity(0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('フィールドメニュー',
                style: TextStyle(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 12),
            //⭐️条件追加
            if (entries.isEmpty &&
                entriesweapon.isEmpty &&
                entriesmaterial.isEmpty)
              const Text('アイテムなし', style: TextStyle(color: Colors.black))
            else
              //⭐️Row追加
              Row(
                mainAxisAlignment: MainAxisAlignment.center,//⭐️追加
                children: [
                  Container(
                    width: 200,//⭐️追加
                    height: 300,//⭐️追加
                    child: Column(
                      children: entries.map((e) {
                        final id = e.key;
                        final count = e.value;

                        // FieldItemList から id に一致する ItemData を探す
                        final itemData = FieldItemList.firstWhere(
                          (it) => it.id == id,
                          orElse: () => ItemData(
                            idx: -1,
                            id: id,
                            name: id, // 見つからない時は id 表示
                            imagePath: '',
                            size_x: 0,
                            size_y: 0,
                            pos_x: 0,
                            pos_y: 0,
                          ),
                        );

                        return _buildItemRow(itemData, count);
                      }).toList(),
                    ),
                  ),
                  //⭐️ここから下追加
                  Container(
                    width: 200,
                    height: 300,
                    child: Column(
                      children: entriesweapon.map((e) {
                        final id = e.key;
                        final count = e.value;

                        // FieldItemList から id に一致する ItemData を探す
                        final itemData = FieldItemList.firstWhere(
                          (it) => it.id == id,
                          orElse: () => ItemData(
                            idx: -1,
                            id: id,
                            name: id, // 見つからない時は id 表示
                            imagePath: '',
                            size_x: 0,
                            size_y: 0,
                            pos_x: 0,
                            pos_y: 0,
                          ),
                        );

                        return _buildItemRow(itemData, count);
                      }).toList(),
                    ),
                  ),
                  Container(
                    width: 200,
                    height: 300,
                    child: Column(
                      children: entriesmaterial.map((e) {
                        final id = e.key;
                        final count = e.value;

                        // FieldItemList から id に一致する ItemData を探す
                        final itemData = FieldItemList.firstWhere(
                          (it) => it.id == id,
                          orElse: () => ItemData(
                            idx: -1,
                            id: id,
                            name: id, // 見つからない時は id 表示
                            imagePath: '',
                            size_x: 0,
                            size_y: 0,
                            pos_x: 0,
                            pos_y: 0,
                          ),
                        );

                        return _buildItemRow(itemData, count);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => game.overlays.remove('FieldMenu'),
              child: const Text('閉じる'),
            )
          ],
        ),
      ),
    );
  }

```
