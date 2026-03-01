# **26_itemuse**

**①アイテムを使う**

**【game.dart】**

```dart

//MainGameの一番下に入れる

  void useItem(String id) {
    // --- ① どのインベントリか判定 ---
    Map<String, int>? targetInventory;

    if (itemInventory.containsKey(id)) {
      targetInventory = itemInventory;
    } else if (weaponInventory.containsKey(id)) {
      targetInventory = weaponInventory;
    } else if (materialInventory.containsKey(id)) {
      targetInventory = materialInventory;
    } else {
      return; // どこにもない
    }

    final count = targetInventory[id] ?? 0;
    if (count <= 0) return;

    // --- ② ItemData取得 ---
    final item = FieldItemList.firstWhere(
      (it) => it.id == id,
      orElse: () => ItemData(
        idx: -1,
        id: id,
        name: id,
        imagePath: '',
        size_x: 0,
        size_y: 0,
        pos_x: 0,
        pos_y: 0,
        type: ItemType.keyItem,
        value: 0,
      ),
    );

    // --- ③ 使用対象 ---
    final target = (scene == "battle") ? selectedPlayer : player;

    bool consumed = true;

    // --- ④ タイプ別処理 ---
    switch (item.type) {
      case ItemType.healHp:
        target.hp = (target.hp + item.value).clamp(0, target.maxHp);
        showMessage('${item.name} を使った！ HP +${item.value}');
        break;

      case ItemType.healSp:
        target.sp = (target.sp + item.value).clamp(0, target.maxSp);
        showMessage('${item.name} を使った！ SP +${item.value}');
        break;

      case ItemType.keyItem:
        showMessage('${item.name} はまだ使えない…');
        consumed = false;
        break;

      case ItemType.weapon:
        showMessage('${item.name} は装備アイテムだよ');
        consumed = false;
        break;

      case ItemType.material:
        showMessage('${item.name} は素材だよ');
        consumed = false;
        break;
    }

    if (!consumed) return;

    // --- ⑤ 消費処理 ---
    targetInventory[id] = count - 1;
    if (targetInventory[id]! <= 0) {
      targetInventory.remove(id);
    }

    // --- ⑥ 保存 ---
    target.savePlayerStatus();
    saveInventory();
  }


```

**【main.dart】**

_typeBadgeを追加
_PauseMenuOverlayState関数とFieldMenuOverlay関数の２箇所

```dart

Widget _buildItemRow(ItemData item, int count, bool showBadge) {
    //⭐️修正　GestureDetectorとonTapを追加
    return GestureDetector(
      onTap: () {
        widget.game.useItem(item.id);
        setState(() {});
      },
      child: Container(
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
      ),
    );
  }

```


```dart
//StatelessWidget→StatefulWidget

//⭐️追加
class FieldMenuOverlay extends StatefulWidget {
  final MainGame game;
  const FieldMenuOverlay({super.key, required this.game});

  @override
  State<FieldMenuOverlay> createState() => _FieldMenuOverlayState();
}

//⭐️修正
class _FieldMenuOverlayState extends State<FieldMenuOverlay> {
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

  @override
  Widget build(BuildContext context) {
    final entries = widget.game.itemInventory.entries.toList();//⭐️修正
    final entriesweapon = widget.game.weaponInventory.entries.toList();//⭐️修正
    final entriesmaterial = widget.game.materialInventory.entries.toList();//⭐️修正

    return Center(
      child: Container(
        width: 900,
        padding: const EdgeInsets.all(16),
        color: Colors.black.withOpacity(0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('フィールドメニュー',
                style: TextStyle(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 12),
            if (entries.isEmpty &&
                entriesweapon.isEmpty &&
                entriesmaterial.isEmpty)
              const Text('アイテムなし', style: TextStyle(color: Colors.black))
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 200,
                    height: 300,
                    child: Column(
                      children: entries.map((e) {
                        final id = e.key;
                        final count = e.value;
                        final showBadge = true;

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
                            type: ItemType.keyItem,
                            value: 10,
                          ),
                        );

                        return _buildItemRow(itemData, count, showBadge);
                      }).toList(),
                    ),
                  ),
                  Container(
                    width: 200,
                    height: 300,
                    child: Column(
                      children: entriesweapon.map((e) {
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
                            type: ItemType.keyItem,
                            value: 10,
                          ),
                        );

                        return _buildItemRow(itemData, count, showBadge);
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
                            type: ItemType.keyItem,
                            value: 10,
                          ),
                        );

                        return _buildItemRow(itemData, count, showBadge);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => widget.game.overlays.remove('FieldMenu'),//⭐️修正
              child: const Text('閉じる'),
            )
          ],
        ),
      ),
    );
  }

```
