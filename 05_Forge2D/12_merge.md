# **12_物体を合体**

**①変数設定**

**【ball.dart】**


```dart

//⭐️追加
import 'package:flame/components.dart';

//⭐️修正
class Ball extends BodyComponent<CraneGame> with ContactCallbacks {


  Body createBody() {
    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = Vector2(data.pos_x, data.pos_y)
      ..fixedRotation = false;

    final shape = CircleShape()..radius = data.radius;

    final fixtureDef = FixtureDef(shape)
      ..density = data.density
      ..friction = data.friction
      ..restitution = data.restitution
      ..isSensor = false
      ..userData = this; //⭐️追加

    final body = world.createBody(bodyDef);
    body.createFixture(fixtureDef); //⭐️追加
    return body;
  }

  //⭐️追加
  @override
  void beginContact(Object other, Contact contact) {
    if (other is Ball && !isConsumed && !other.isConsumed) {
      final g = game; // Component が持っている参照
      print('contact: r=${data.radius}, color=${data.color.value}');
      if (g is CraneGame) {
        // 型チェックしてからキャスト
        g.requestMerge(other1: this, other2: other);
      }
    }
    super.beginContact(other, contact);
  }

```

**【crane_game.dart】**

一番下に追加

```dart

  // ★ 合体キュー（同一ペアの多重処理を防ぐ）
  final Set<Ball> _mergeQueued = {};

  // ★ しきい値：半径の一致判定、色一致判定
  static const double kRadiusEps = 0.5;

  // ★ 合体リクエスト（Ball側から呼ばれる）
  void requestMerge({required Ball other1, required Ball other2}) {
    if (other1 == other2) return;
    if (_mergeQueued.contains(other1) || _mergeQueued.contains(other2)) return;
    if (!_canMerge(other1, other2)) return;

    // マークして次フレームで実行
    _mergeQueued.addAll([other1, other2]);
    other1.consumed = true;
    other2.consumed = true;

    // 次フレームで安全にワールド変更
    Future.microtask(() => _performMerge(other1, other2));
  }

  bool _canMerge(Ball a, Ball b) {
    final sameRadius = (a.data.radius - b.data.radius).abs() <= kRadiusEps;
    if (!sameRadius) return false;

    final idx = _nearestSizeIndex(a.data.radius, kBallSizes);
    if (idx == null) return false;
    if (idx >= kBallSizes.length - 1) return false; // もう上がない
    return true;
  }

  int? _nearestSizeIndex(double r, List<double> sizes) {
    int best = 0;
    double dist = (sizes[0] - r).abs();
    for (int i = 1; i < sizes.length; i++) {
      final d = (sizes[i] - r).abs();
      if (d < dist) {
        dist = d;
        best = i;
      }
    }
    // 近いほうが kRadiusEps 以内なら採用
    return dist <= kRadiusEps ? best : null;
  }

  void _performMerge(Ball a, Ball b) {
    // 最終チェック（既に消えてる等）
    if (!a.isMounted || !b.isMounted) {
      _mergeQueued.removeAll([a, b]);
      return;
    }

    final idx = _nearestSizeIndex(a.data.radius, kBallSizes)!;
    final nextIdx = idx + 1;

    // 生成位置は2体の中点
    final pos = (a.body.worldCenter + b.body.worldCenter)..scale(0.5);

    // 新ボールの半径・密度はプリセットの次段を使用（色は維持）
    final double newRadius = kBallSizes[nextIdx];
    final double newDensity = kBallDensities[nextIdx];
    final Color newColor = a.data.color;

    // テンプレは a から流用（その他パラメータは継承 or お好みで）
    final BallData newData = a.data.copyWith(
      idx: 500000 + _rng.nextInt(100000),
      pos_x: pos.x,
      pos_y: pos.y,
      radius: newRadius,
      density: newDensity,
      // 反発や摩擦は小さめに調整したいならここで任意に
      // restitution: min(a.data.restitution, b.data.restitution),
      // friction: max(a.data.friction, b.data.friction),
      color: newColor,
    );

    // 旧ボールを削除 → 新規追加
    a.removeFromParent();
    b.removeFromParent();
    add(Ball(newData));

    _mergeQueued.removeAll([a, b]);
  }

```
