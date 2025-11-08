# **13_物体を合体（四角）**

**①変数設定**

**【box.dart】**


```dart

//⭐️追加
import 'package:flame/components.dart';
import 'crane_game.dart';

//⭐️修正
class Box extends BodyComponent<CraneGame> with ContactCallbacks {

  //⭐️ 合体中フラグ（多重合体防止）
  bool _consumed = false;
  bool get isConsumed => _consumed;
  set consumed(bool v) => _consumed = v;


  @override
  Body createBody() {
    // bodyの種類、初期値を設定
    final bodyDef = BodyDef()
      ..type = BodyType.dynamic //動的なボディ。重力や衝突の影響を受けて動く。
      ..position = Vector2(data.pos_x, data.pos_y);

    // Boxの型を定義
    final shape = PolygonShape()..setAsBoxXY(data.size_x / 2, data.size_y / 2);

    // 摩擦や密度を設定
    final fixtureDef = FixtureDef(shape)
      ..density = data.density //密度、大きいほど重くなる
      ..friction = data.friction //摩擦係数、1に近いと滑りにくい
      ..restitution = data.restitution // ★ 反発係数（0=跳ねない, 1=完全反発）
      ..isSensor = false //⭐️
      ..userData = this; //⭐️

    // worldに登録
    final body = world.createBody(bodyDef)..createFixture(fixtureDef);

    return body;
  }

  //⭐️追加
  @override
  void beginContact(Object other, Contact contact) {
    if (other is Box && !isConsumed && !other.isConsumed) {
      final g = game;
      if (g is CraneGame) {
        g.requestMergeBox(this, other);
      }
    }
    super.beginContact(other, contact);
  }

```

**【crane_game.dart】**

一番下に追加

```dart

  // === Box merge manager ===

  // Box 用キュー
  final Set<Box> _mergeQueuedBox = {};
  static const double kBoxSizeEps = 0.5; // 一辺の一致許容

  void requestMergeBox(Box a, Box b) {
    if (a == b) return;
    if (!a.isMounted || !b.isMounted) return;
    if (_mergeQueuedBox.contains(a) || _mergeQueuedBox.contains(b)) return;
    if (!_canMergeBox(a, b)) return;

    _mergeQueuedBox.addAll([a, b]);
    a.consumed = true;
    b.consumed = true;

    Future.microtask(() => _performMergeBox(a, b));
  }

  bool _canMergeBox(Box a, Box b) {
    // 一辺長（正方形前提）。左右のコードでは size_x = size_y にしているのでそれで判定
    final sameSize = (a.data.size_x - b.data.size_x).abs() <= kBoxSizeEps &&
        (a.data.size_y - b.data.size_y).abs() <= kBoxSizeEps;

    if (!(sameSize)) return false;

    final idx = _nearestSizeIndex(a.data.size_x, kBoxSizes);
    if (idx == null) return false;
    if (idx >= kBoxSizes.length - 1) return false; // もう上段がない
    return true;
  }

  void _performMergeBox(Box a, Box b) {
    if (!a.isMounted || !b.isMounted) {
      _mergeQueuedBox.removeAll([a, b]);
      return;
    }

    final idx = _nearestSizeIndex(a.data.size_x, kBoxSizes)!;
    final nextIdx = idx + 1;

    // 生成位置は2体の中点
    final pos = (a.body.worldCenter + b.body.worldCenter)..scale(0.5);

    // 次段の一辺長と密度（=> 重さも段階アップ）
    final double newSize = kBoxSizes[nextIdx];
    final double newDensity = kBoxDensities[nextIdx];
    final color = a.data.color; // 色は維持（段に色を紐づけたいならそちらを使う）

    final BoxData newData = a.data.copyWith(
      idx: 600000 + _rng.nextInt(100000),
      pos_x: pos.x,
      pos_y: pos.y,
      size_x: newSize,
      size_y: newSize,
      density: newDensity,
      color: color,
    );

    a.removeFromParent();
    b.removeFromParent();
    add(Box(newData));

    _mergeQueuedBox.removeAll([a, b]);
  }

```
