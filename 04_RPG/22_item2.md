# **22_item2**

**①アイテムの保存**

**【setting.dart】**

```dart

//⭐️
final Map<String, int> inventory = {};

```

**【main.dart】**

```dart
//⭐️
import 'setting.dart';

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
            //⭐️追加
            'FieldMenu': (context, game) =>
                FieldMenuOverlay(game: game as MainGame),
            'PauseMenu': (context, game) =>
                PauseMenuOverlay(game: game as MainGame),
            'MessageBox': (context, game) =>
                MessageBoxOverlay(game: game as MainGame),
          },
        ));
  }
}

//省略

class _PauseMenuOverlayState extends State<PauseMenuOverlay> {
  bool showPlayerInfo = false;
  bool showItems = false; // ⭐️追加：アイテム欄の開閉

  @override
  Widget build(BuildContext context) {
    // battleの時だけ player1/player2 がいる想定なら null対策してもOK
    final p1 = player1;
    final p2 = player2;

    // ⭐️ inventory（Map<String,int>）をリスト化
    final invEntries = widget.game.inventory.entries.toList();

    //省略

    if (showPlayerInfo) ...[
      const SizedBox(height: 8),
      const Divider(color: Color.fromARGB(137, 0, 0, 0)),
      const SizedBox(height: 8),
      _buildPlayerInfoCard('プレーヤー１', p1),
      const SizedBox(height: 8),
      _buildPlayerInfoCard('プレーヤー２', p2),
    ],

    // ⭐️ ▼ アイテム表示ボタン
    const SizedBox(height: 12),

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

      // ⭐️ アイテム一覧
      if (invEntries.isEmpty)
        const Text('アイテムなし', style: TextStyle(color: Colors.black))
      else
        Column(
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
    ],

    const SizedBox(height: 16),
  }

  // ⭐️ 追加：アイテム1行表示
  // _buildPlayerInfoCard関数の下あたり
  Widget _buildItemRow(ItemData item, int count) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 240, 240, 240),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          // 画像（なければ空箱）
          SizedBox(
            width: 32,
            height: 32,
            child: (item.imagePath.isNotEmpty)
                ? Image.asset('assets/images/${item.imagePath}',
                    fit: BoxFit.contain)
                : const Icon(Icons.inventory_2_outlined),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(color: Colors.black, fontSize: 14),
            ),
          ),

          Text(
            '× $count',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

//⭐️一番したに追加
class FieldMenuOverlay extends StatelessWidget {
  final MainGame game;
  const FieldMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final entries = game.inventory.entries.toList();

    return Center(
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(16),
        color: Colors.black.withOpacity(0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('フィールドメニュー',
                style: TextStyle(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 12),

            // アイテム一覧
            if (entries.isEmpty)
              const Text('アイテムなし', style: TextStyle(color: Colors.black))
            else
              Column(
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
}

```

**【game.dart】**

```dart
//⭐️
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

@override
Future<void> onLoad() async {
  super.onLoad();
  //⭐️
  await loadInventory();

  //省略
}

//省略

Future<void> objectRemove() async {
    // ここで画面に表示するオブジェクトを呼び出す

    await CameraRemove();

    print("===scene===${scene}");
    switch (scene) {
      case "main":
        for (int i = 0; i < 1; i++) {
          BackScreenImg _backscreenimg = BackScreenImg(BackGroundlist[1], i);
          await world.add(_backscreenimg);
        }
        player = Player("player1", PlayerList[0]);
        await world.add(player);
        for (final itemData in FieldItemList) {
          //⭐️追加
          if (inventory.containsKey(itemData.id)) continue;

          await world.add(FieldItem(itemData));
        }
        break;
    }
}

//省略

void addItemToInventory(String id, int amount) {
    inventory[id] = (inventory[id] ?? 0) + amount;
    print('inventory[$id] = ${inventory[id]}');

    //⭐️追加
    saveInventory();
  }


Future<void> AllRemove() async {
    final List<Component> childrenToRemove = world.children.toList();
    for (var child in childrenToRemove) {
      child.removeFromParent();
    }
  }

  //⭐️追加
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

  //省略

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    //⭐️追加
    if (scene == "main" && event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (overlays.isActive('FieldMenu')) {
          overlays.remove('FieldMenu');
        } else {
          overlays.add('FieldMenu');
        }
      }
      return super.onKeyEvent(event, keysPressed);
    }
  }

  //省略

  class KeySpy extends Component with KeyboardHandler {
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    print('[KeySpy] $event keys=$keysPressed');
    return false;
  }
}

//⭐️追加
Future<void> saveInventory() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = jsonEncode(inventory);
  await prefs.setString('inventory', jsonString);
}

//⭐️追加
Future<void> loadInventory() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('inventory');
  if (jsonString == null) return;

  final Map<String, dynamic> map = jsonDecode(jsonString);
  inventory
    ..clear()
    ..addAll(map.map((k, v) => MapEntry(k, v as int)));
}

```
