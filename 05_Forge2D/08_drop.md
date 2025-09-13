# **08_アイテムを落とす**

**①データ設定**

**【setting.dart】**

class BoxData の上に追加

```dart

//⭐️ ランダムにデータ作る用
extension BoxDataCopy on BoxData {
  BoxData copyWith({
    int? idx,
    Color? color,
    double? pos_x,
    double? pos_y,
    double? size_x,
    double? size_y,
    double? density,
    double? gravityScale,
    double? friction,
    double? restitution,
    String? item_img,
  }) {
    return BoxData(
      idx: idx ?? this.idx,
      color: color ?? this.color,
      pos_x: pos_x ?? this.pos_x,
      pos_y: pos_y ?? this.pos_y,
      size_x: size_x ?? this.size_x,
      size_y: size_y ?? this.size_y,
      density: density ?? this.density,
      gravityScale: gravityScale ?? this.gravityScale,
      friction: friction ?? this.friction,
      restitution: restitution ?? this.restitution,
      item_img: item_img ?? this.item_img,
    );
  }
}


class BoxData {
}

```

**【box.dart】**

```dart

@override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = data.color;

    //⭐️
    final width = data.size_x;
    final height = data.size_y;

    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: width, height: height),
      paint,
    );
  }

```

**【crane_game.dart】**

```dart

import 'package:flutter/material.dart'; //⭐️追加

//省略

late Vector2 screenSize;
final _random = math.Random();
double _timeSinceLastSpawn = 0.0;

bool leftflg = false;
bool rightflg = false;

//⭐️追加
BallData? _heldBall;
BoxData? _heldBox;

//⭐️追加
PositionComponent? _carryPreview;
final double _carryOffsetY = -40;

//⭐️追加
enum ItemKind { ball, box }

//⭐️追加
class ItemSpec {
  ItemSpec({
    required this.kind,
    required this.size, // Ball: 半径, Box: 一辺長
    required this.density,
    required this.gravityScale,
    required this.friction,
    required this.restitution,
    required this.color,
    required this.spritePath, // プレビューに使いたい画像（空なら色つき図形で表示）
  });
  final ItemKind kind;
  final double size;
  final double density;
  final double gravityScale;
  final double friction;
  final double restitution;
  final Color color;
  final String spritePath;
}
//⭐️追加

class CraneGame extends Forge2DGame with HasKeyboardHandlerComponents {
  CraneGame() : super(gravity: Vector2(0, 20.0)); // 下向き重力

  final math.Random _rng = math.Random();
  bool _droppedOnce = false;
  late final Seesaw _seesaw;
  late final Player _player;

  //⭐️ === 手持ち（追従） ===
  PositionComponent? _carryPreview; // プレビュー（Sprite でも図形でも OK）
  ItemSpec? _carrySpec;
  final double _carryOffsetY = -40;

  // 調整パラメータ
  static const int kCount = 10; // 同時に落とす個数
  static const double kSideMargin = 6; // シーソー左右端の安全マージン
  static const double kDropGap = 12; // シーソー上面から上方向オフセット
  static const double kDropBand = 10; // さらに上方向にばらつかせる帯の高さ
  static const double kRMin = 6; // 半径レンジ
  static const double kRMax = 16;
  static const double kDensityMin = 5; // 密度レンジ（質量に効く）
  static const double kDensityMax = 25;

  // ⭐️追加
  static const double kBallRMin = 6, kBallRMax = 22;
  static const double kBoxSizeMin = 20, kBoxSizeMax = 90;
  static const double kRestitutionMin = 0.1, kRestitutionMax = 0.3;
  static const double kFrictionMin = 0.3, kFrictionMax = 0.8;
  static const double kGravityScaleMin = 0.8, kGravityScaleMax = 1.8;
  static const double kFixedDensity = 10.0; // どの形状でも一定
  static const double kFixedGravityScale = 1.0; // 重力スケールも一定に

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    screenSize = size;
  }

  @override
  Future<void> onLoad() async {
    // Ground _bround = Ground(groundList[0]);
    // add(_bround);
    final seesawData = seesawList[0];
    _seesaw = Seesaw(seesawData);
    await add(_seesaw);

    //宣言は上に移動
    _player = Player();
    add(_player);

    //

    Ball _ball = Ball(ballList[0]);
    add(_ball);

    Ball _ball1 = Ball(ballList[1]);
    add(_ball1);

    _dropBallsFromAboveRandomPositions();

    //⭐️追加
    await _spawnNextCarryItem();
  }

  void _dropBallsFromAboveRandomPositions() {
    if (_droppedOnce) return;
    _droppedOnce = true;

    final double leftX =
        _seesaw.data.centerX - _seesaw.data.halfWidth + kSideMargin;
    final double rightX =
        _seesaw.data.centerX + _seesaw.data.halfWidth - kSideMargin;
    final double topY = _seesaw.data.centerY - _seesaw.data.halfHeight;
    if (rightX <= leftX) return;

    // 10個が密集しすぎないよう、横方向はバケットで分散＋各バケット内でランダム
    final double bucketW = (rightX - leftX) / kCount;
    final double baseY = topY - kDropGap;

    for (int i = 0; i < kCount; i++) {
      final double bucketL = leftX + bucketW * i;
      final double bucketR = bucketL + bucketW;
      final double x = (bucketL + 1.0) +
          (_rng.nextDouble() * ((bucketR - 1.0) - (bucketL + 1.0)));
      final double y = baseY - _rng.nextDouble() * kDropBand; // 少しだけ上方向にもランダム

      // 半径と密度をランダム化（質量 = 密度 × π × r^2）
      final double r = kRMin + (kRMax - kRMin) * _rng.nextDouble();
      final double density =
          kDensityMin + (kDensityMax - kDensityMin) * _rng.nextDouble();

      // 既存テンプレから流用（色や弾性はテンプレ準拠・必要なら上書き可）
      final template = ballList[_rng.nextInt(ballList.length)];
      final data = template.copyWith(
        idx: 1000 + i, // 一意なら何でもOK
        pos_x: x,
        pos_y: y,
        radius: r,
        density: density,
        restitution: 0.1 + _rng.nextDouble() * 0.1,
      );

      add(Ball(data));
    }
  }

  // ⭐️追加
  @override
  void update(double dt) {
    super.update(dt);
    if (_carryPreview != null && _player.isMounted) {
      _carryPreview!.position = _player.position + Vector2(0, _carryOffsetY);
      _carryPreview!.priority = _player.priority + 1;
    }
  }

  // ⭐️ === スペースで呼ばれる ===
  void dropCurrentItem() {
    if (_carryPreview == null) return;

    final dropPos = _carryPreview!.position.clone();
    _carryPreview!.removeFromParent();
    _carryPreview = null;

    if (_heldBall != null) {
      // 確定データから位置だけ更新して生成
      final d = _heldBall!;
      final data = d.copyWith(pos_x: dropPos.x, pos_y: dropPos.y);
      add(Ball(data));
      _heldBall = null;
    } else if (_heldBox != null) {
      final d = _heldBox!;
      final data = d.copyWith(pos_x: dropPos.x, pos_y: dropPos.y);
      add(Box(data));
      _heldBox = null;
    } else {
      return; // 何も持ってない
    }

    // 次を用意（ここで初めて次の乱数）
    _spawnNextCarryItem();
  }

  // ⭐️
  Future<void> _spawnNextCarryItem() async {
    // まずクリア
    _heldBall = null;
    _heldBox = null;
    _carryPreview?.removeFromParent();
    _carryPreview = null;

    final isBall = _rng.nextBool();

    if (isBall) {
      // テンプレを1つ選び、ここで最終データまで確定
      final template = ballList[_rng.nextInt(ballList.length)];

      // ★ 大きさと質量を比例させたいので density は固定値
      const kFixedDensity = 10.0;
      final radius = _rand(kBallRMin, kBallRMax);

      _heldBall = template.copyWith(
        idx: 2000 + _rng.nextInt(100000),
        pos_x: _player.position.x,
        pos_y: _player.position.y + _carryOffsetY,
        radius: radius,
        density: kFixedDensity,
        gravityScale: 1.0,
        friction: _rand(kFrictionMin, kFrictionMax),
        restitution: _rand(kRestitutionMin, kRestitutionMax),
        color: _randomNiceColor(template.color),
        // item_img は template のまま
      );

      // プレビューは「確定データ」から作る（画像が無ければ色図形）
      _carryPreview = await _makePreviewFromBall(_heldBall!);
    } else {
      final template = boxList[_rng.nextInt(boxList.length)];

      const kFixedDensity = 10.0;
      final size = _rand(kBoxSizeMin, kBoxSizeMax);

      _heldBox = template.copyWith(
        idx: 3000 + _rng.nextInt(100000),
        pos_x: _player.position.x,
        pos_y: _player.position.y + _carryOffsetY,
        size_x: size,
        size_y: size,
        density: kFixedDensity,
        gravityScale: 1.0,
        friction: _rand(kFrictionMin, kFrictionMax),
        restitution: _rand(kRestitutionMin, kRestitutionMax),
        color: _randomNiceColor(template.color),
      );

      _carryPreview = await _makePreviewFromBox(_heldBox!);
    }

    _carryPreview!.position = _player.position + Vector2(0, _carryOffsetY);
    _carryPreview!.priority = 1000;
    add(_carryPreview!);
  }

  //⭐️
  double _rand(double a, double b) => a + (b - a) * _rng.nextDouble();

  //⭐️
  Future<PositionComponent> _makePreviewFromBall(BallData data) async {
    if (data.item_img.isNotEmpty) {
      final sprite = await loadSprite(data.item_img);
      return SpriteComponent(
        sprite: sprite,
        size: Vector2.all(data.radius * 2),
        anchor: Anchor.center,
      );
    } else {
      return CircleComponent(
        radius: data.radius,
        anchor: Anchor.center,
        paint: Paint()..color = data.color,
      )..size = Vector2.all(data.radius * 2);
    }
  }

  //⭐️
  Future<PositionComponent> _makePreviewFromBox(BoxData data) async {
    if (data.item_img.isNotEmpty) {
      final sprite = await loadSprite(data.item_img);
      return SpriteComponent(
        sprite: sprite,
        size: Vector2(data.size_x, data.size_y),
        anchor: Anchor.center,
      );
    } else {
      return RectangleComponent(
        size: Vector2(data.size_x, data.size_y),
        anchor: Anchor.center,
        paint: Paint()..color = data.color,
      );
    }
  }

  //⭐️
  Vector2 _previewSizeFor(ItemSpec s) =>
      s.kind == ItemKind.ball ? Vector2.all(s.size * 2) : Vector2.all(s.size);

  // ⭐️ === 設定データを活用したランダム仕様 ===
  ItemSpec _randomItemSpecFromSettings() {
    final isBall = _rng.nextBool();

    double r(double a, double b) => a + (b - a) * _rng.nextDouble();
    final restitution = r(kRestitutionMin, kRestitutionMax);
    final friction = r(kFrictionMin, kFrictionMax);
    final gscale = r(kGravityScaleMin, kGravityScaleMax);

    if (isBall) {
      final template = ballList[_rng.nextInt(ballList.length)];
      final radius = r(kBallRMin, kBallRMax);

      return ItemSpec(
        kind: ItemKind.ball,
        size: radius,
        density: kFixedDensity,
        gravityScale: kFixedGravityScale,
        friction: friction,
        restitution: restitution,
        color: _randomNiceColor(template.color),
        spritePath: template.item_img,
      );
    } else {
      final template = boxList[_rng.nextInt(boxList.length)];
      final size = r(kBoxSizeMin, kBoxSizeMax);

      return ItemSpec(
        kind: ItemKind.box,
        size: size,
        density: kFixedDensity,
        gravityScale: kFixedGravityScale,
        friction: friction,
        restitution: restitution,
        color: _randomNiceColor(template.color),
        spritePath: template.item_img,
      );
    }
  }

  //⭐️ カラーパレットを作るなら自由に。ここでは元色を少し明度変化（超テキトー実装）。
  Color _randomNiceColor(Color base) {
    // 0.9〜1.1倍くらいで明るさをゆらす
    final f = 0.9 + _rng.nextDouble() * 0.2;
    int clamp(int v) => v.clamp(0, 255);
    return Color.fromARGB(
      base.alpha,
      clamp((base.red * f).toInt()),
      clamp((base.green * f).toInt()),
      clamp((base.blue * f).toInt()),
    );
  }
}

```