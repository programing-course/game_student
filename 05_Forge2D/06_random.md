# **06_ランダム**

**①データ設定**

**【setting.dart】**

BallDataの上に追加

```dart

// ランダムな位置にできるように
extension BallDataCopy on BallData {
  BallData copyWith({
    int? idx,
    Color? color,
    double? pos_x,
    double? pos_y,
    double? radius,
    double? density,
    double? gravityScale,
    double? friction,
    double? restitution,
    String? item_img,
  }) {
    return BallData(
      idx: idx ?? this.idx,
      color: color ?? this.color,
      pos_x: pos_x ?? this.pos_x,
      pos_y: pos_y ?? this.pos_y,
      radius: radius ?? this.radius,
      density: density ?? this.density,
      gravityScale: gravityScale ?? this.gravityScale,
      friction: friction ?? this.friction,
      restitution: restitution ?? this.restitution,
      item_img: item_img ?? this.item_img,
    );
  }
}


class BallData {
}

```

**【crane_game.dart】**

```dart

import 'package:flame_forge2d/flame_forge2d.dart';
import 'dart:math' as math;//⭐️追加
import 'dart:ui';//⭐️追加
import 'ground.dart';
import 'box.dart';
import 'setting.dart';
import 'ball.dart';
import 'seesaw.dart';

late Vector2 screenSize;
final _random = math.Random();//⭐️追加
double _timeSinceLastSpawn = 0.0;//⭐️追加

class CraneGame extends Forge2DGame {
  CraneGame() : super(gravity: Vector2(0, 10.0));

  //⭐️追加
  final math.Random _rng = math.Random();
  bool _droppedOnce = false;
  late final Seesaw _seesaw;

  // 調整パラメータ
  static const int kCount = 10; // 同時に落とす個数
  static const double kSideMargin = 6; // シーソー左右端の安全マージン
  static const double kDropGap = 12; // シーソー上面から上方向オフセット
  static const double kDropBand = 10; // さらに上方向にばらつかせる帯の高さ
  static const double kRMin = 6; // 半径レンジ
  static const double kRMax = 16;
  static const double kDensityMin = 5; // 密度レンジ（質量に効く）
  static const double kDensityMax = 25;
  //⭐️追加

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

    //⭐️追加
    _dropBallsFromAboveRandomPositions();
  }
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

```