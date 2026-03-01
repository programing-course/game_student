# **25_panel4**

**①アイテムの機能追加**

**【setting.dart】**

```dart

//⭐️追加
enum ItemType { healHp, healSp, keyItem, weapon, material }

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
  final ItemType type;//⭐️追加
  final int value;//⭐️追加

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
    required this.type,//⭐️追加
    this.value = 0,//⭐️追加
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
    type: ItemType.healHp,//⭐️追加
    value: 30,//⭐️追加
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
    type: ItemType.healSp,//⭐️追加
    value: 15,//⭐️追加
  ),
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
    type: ItemType.keyItem,//⭐️追加
    value: 10,//⭐️追加
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
    type: ItemType.keyItem,//⭐️追加
    value: 12,//⭐️追加
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
    type: ItemType.weapon,//⭐️追加
    value: 10,//⭐️追加
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
    type: ItemType.weapon,//⭐️追加
    value: 15,//⭐️追加
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
    type: ItemType.material,//⭐️追加
    value: 120,//⭐️追加
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
    type: ItemType.material,//⭐️追加
    value: 13,//⭐️追加
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
    type: ItemType.material,//⭐️追加
    value: 10,//⭐️追加
  ),
];

```

**②種類を表示する**

**【main.dart】**

_typeBadgeを追加
_PauseMenuOverlayState関数とFieldMenuOverlay関数の２箇所

```dart

class _PauseMenuOverlayState extends State<PauseMenuOverlay> {
  bool showPlayerInfo = false;
  bool showItems = false;

  // ⭐️追加
  Widget _typeBadge(ItemType type) {
    String text;
    Color bg;

    switch (type) {
      case ItemType.healHp:
        text = 'HP';
        bg = Colors.red;
        break;
      case ItemType.healSp:
        text = 'SP';
        bg = Colors.blue;
        break;
      case ItemType.keyItem:
        text = 'KEY';
        bg = Colors.orange;
        break;
      case ItemType.weapon:
        text = 'WPN';
        bg = Colors.purple;
        break;
      case ItemType.material:
        text = 'MAT';
        bg = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  //省略

  class FieldMenuOverlay extends StatelessWidget {
  final MainGame game;
  const FieldMenuOverlay({super.key, required this.game});

  // ⭐️追加
  Widget _typeBadge(ItemType type) {
    String text;
    Color bg;

    switch (type) {
      case ItemType.healHp:
        text = 'HP';
        bg = Colors.red;
        break;
      case ItemType.healSp:
        text = 'SP';
        bg = Colors.blue;
        break;
      case ItemType.keyItem:
        text = 'KEY';
        bg = Colors.orange;
        break;
      case ItemType.weapon:
        text = 'WPN';
        bg = Colors.purple;
        break;
      case ItemType.material:
        text = 'MAT';
        bg = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

```

```dart

_PauseMenuOverlayStateの中とFieldMenuOverlayの中

  if (showItems) ...[
    const SizedBox(height: 8),
    const Divider(color: Color.fromARGB(137, 0, 0, 0)),
    const SizedBox(height: 8),

    if (invEntries.isEmpty &&
        invEntriesweapon.isEmpty &&
        invEntriesmaterial.isEmpty)
      const Text('アイテムなし', style: TextStyle(color: Colors.black))
    else
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,//⭐️修正
        children: [
          Container(
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: invEntries.map((e) {
                final id = e.key;
                final count = e.value;
                final showBadge = true;//⭐️追加

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
                    type: ItemType.keyItem,//⭐️追加
                    value: 10,//⭐️追加
                  ),
                );

                return _buildItemRow(itemData, count, showBadge);//⭐️修正
              }).toList(),
            ),
          ),
          Container(
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: invEntriesweapon.map((e) {
                final id = e.key;
                final count = e.value;
                final showBadge = false;

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
                    type: ItemType.keyItem,//⭐️追加
                    value: 10,//⭐️追加
                  ),
                );

                return _buildItemRow(itemData, count, showBadge);//⭐️修正
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
                final showBadge = false;

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
                    type: ItemType.keyItem,//⭐️追加
                    value: 10,//⭐️追加
                  ),
                );

                return _buildItemRow(itemData, count, showBadge);//⭐️修正
              }).toList(),
            ),
          ),
        ],
      ),
  ],

```


```dart

    //_buildItemRow関数2箇所ある
    //⭐️引数追加
    Widget _buildItemRow(ItemData item, int count, bool showBadge) {
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

          //⭐️追加
          if (showBadge) ...[
            _typeBadge(item.type),
            const SizedBox(width: 10),
          ],

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

```
