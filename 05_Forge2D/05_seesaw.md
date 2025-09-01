# **05_シーソー**

**①データ設定**

**【setting.dart】**

```dart

class SeesawData {
  final double centerX;
  final double centerY;
  final double halfWidth;
  final double halfHeight;
  final double boardDensity;
  final double boardFriction;
  final double boardRestitution;
  final double fulcrumRadius;
  final double lowerAngleDeg;
  final double upperAngleDeg;
  final double angularDamping;

  const SeesawData({
    required this.centerX,
    required this.centerY,
    required this.halfWidth,
    required this.halfHeight,
    required this.boardDensity,
    required this.boardFriction,
    required this.boardRestitution,
    required this.fulcrumRadius,
    required this.lowerAngleDeg,
    required this.upperAngleDeg,
    required this.angularDamping,
  });
}

/// 複数のシーソーをリストで返す（画面サイズに依存するので const にはしない）
List<SeesawData> seesawList = [
  // 画面中央・幅ほぼいっぱい
  SeesawData(
    centerX: FIELD_SIZE_X * 0.5,
    centerY: FIELD_SIZE_Y * 0.5,
    halfWidth: FIELD_SIZE_X * 0.5,
    halfHeight: 5,
    boardDensity: 5.0,
    boardFriction: 0.6,
    boardRestitution: 0.0,
    fulcrumRadius: 8.0,
    lowerAngleDeg: -20,
    upperAngleDeg: 20,
    angularDamping: 2.0,
  ),
];

```

**【seesaw.dart】**

```dart

// seesaw.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart' show Component;
import 'package:flame_forge2d/flame_forge2d.dart';
import 'setting.dart';

/// 板（見た目も描く）
class _SeesawBoard extends BodyComponent {
  _SeesawBoard(this.data, this.color);
  final SeesawData data;
  final Color color;

  @override
  Body createBody() {
    final bd = BodyDef()
      ..type = BodyType.dynamic
      ..position = Vector2(data.centerX, data.centerY)
      ..angularDamping = data.angularDamping;

    final shape = PolygonShape()..setAsBoxXY(data.halfWidth, data.halfHeight);

    final fd = FixtureDef(shape)
      ..density = data.boardDensity
      ..friction = data.boardFriction
      ..restitution = data.boardRestitution;

    final body = world.createBody(bd)..createFixture(fd);
    return body;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = color;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: data.halfWidth * 2,
        height: data.halfHeight * 2,
      ),
      paint,
    );
  }
}

/// 支点（見た目用の小円）
class _SeesawFulcrum extends BodyComponent {
  _SeesawFulcrum(this.data, this.color);
  final SeesawData data;
  final Color color;

  @override
  Body createBody() {
    final bd = BodyDef()
      ..type = BodyType.static
      ..position = Vector2(data.centerX, data.centerY);

    // 見た目だけなら Fixture なしでもOK。接触を取りたいならFixtureを付ける。
    // ここでは地面としての干渉は不要なので小さなFixtureにしても良いし省略も可。
    final shape = CircleShape()..radius = data.fulcrumRadius;
    final fd = FixtureDef(shape)..friction = 0.8;

    final body = world.createBody(bd)..createFixture(fd);
    return body;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset.zero, data.fulcrumRadius, paint);
  }
}

class Seesaw extends Component {
  Seesaw(
    this.data, {
    this.boardColor = const Color(0xFF8D6E63),
    this.fulcrumColor = const Color(0xFF546E7A),
  });
  final SeesawData data;
  final Color boardColor;
  final Color fulcrumColor;

  late final _SeesawBoard board;
  late final _SeesawFulcrum fulcrum;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    board = _SeesawBoard(data, boardColor);
    fulcrum = _SeesawFulcrum(data, fulcrumColor);

    await add(fulcrum);
    await add(board);

    // ここがポイント：board の world を使う
    final def = RevoluteJointDef()
      ..initialize(fulcrum.body, board.body, board.body.worldCenter)
      ..enableLimit = true
      ..lowerAngle = data.lowerAngleDeg * math.pi / 180.0
      ..upperAngle = data.upperAngleDeg * math.pi / 180.0
      ..enableMotor = false;

    board.world.createJoint(RevoluteJoint(def));
  }
}

// Seesaw クラスの末尾あたりに追記（既存コードはそのままでOK）
extension SeesawAccessors on Seesaw {
  /// 中心座標（world）
  Vector2 get center => Vector2(data.centerX, data.centerY);

  /// 長さ・厚み（world）
  double get length => data.halfWidth * 2;
  double get thickness => data.halfHeight * 2;

  /// 上面Y座標（world）
  double get topY => data.centerY - data.halfHeight;

  /// 左右端X座標（world）
  double get leftX => data.centerX - data.halfWidth;
  double get rightX => data.centerX + data.halfWidth;
}




```

**【crane_game.dart】**

```dart

import 'package:flame_forge2d/flame_forge2d.dart';
import 'ground.dart';
import 'box.dart';
import 'setting.dart';
import 'ball.dart';

late Vector2 screenSize;

class CraneGame extends Forge2DGame {
  CraneGame() : super(gravity: Vector2(0, 10.0));

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    screenSize = size;
  }

  @override
  Future<void> onLoad() async {
    //add(Ground());
    //add(Box(Vector2(50, 50)));
    
    //⭐️Ground _bround = Ground(groundList[0]);
    //⭐️add(_bround);
    Seesaw　_seesaw = Seesaw(seesawList[0]);
    add(_seesaw);

    Box _box1 = Box(boxList[0]);
    add(_box1);

    Box _box2 = Box(boxList[1]);
    add(_box2);

    Ball _ball = Ball(ballList[0]);
    add(_ball);

    Ball _ball1 = Ball(ballList[1]);
    add(_ball1);
  }
}

```