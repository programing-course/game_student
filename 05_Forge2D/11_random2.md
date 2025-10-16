# **11_物体の個数制限**

**①変数設定**

**【crane_game.dart】**


```dart

  double leftWeight = 0.0; // 左側総重量（kg扱い）
  double rightWeight = 0.0; // 右側総重量（kg扱い）
  double seesawAngleDeg = 0.0; // シーソー角度（度）

  //⭐️追加
  static const List<double> kBallSizes = [8, 12, 16, 20, 24]; // 半径5種
  static const List<double> kBallDensities = [5.0, 8.0, 12.0, 16.0, 22.0];

  static const List<double> kBoxSizes = [24, 36, 48, 60, 72]; // 一辺長5種
  static const List<double> kBoxDensities = [6.0, 9.0, 13.0, 18.0, 25.0];

  T _choice<T>(List<T> list) => list[_rng.nextInt(list.length)];

  bool kOnlyRightBigBox = true;

```

**【crane_game.dart】**


```dart

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

    //⭐️追加
    if (kOnlyRightBigBox) {
      await _spawnNextCarryItem();
      // ★ 右側に大きい正方形を1つだけ
      _spawnOneBigRightBox();
      // 以降のスポーン系は呼ばない
      add(HudOverlay()); // HUDは必要なら残す/外す
      return;
    }

    Ball _ball = Ball(ballList[0]);
    add(_ball);

    Ball _ball1 = Ball(ballList[1]);
    add(_ball1);

    _dropBallsFromAboveRandomPositions();

    await _spawnNextCarryItem();

    add(HudOverlay());

    //⭐️追加
    _spawnOneBigRightBox();
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
      //⭐️ final double r = kRMin + (kRMax - kRMin) * _rng.nextDouble();
      //⭐️追加
      final double r = _choice(kBallSizes);
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

  //⭐️追加
  void _spawnOneBigRightBox() {
    final double rightX =
        _seesaw.data.centerX + _seesaw.data.halfWidth - kSideMargin;
    final double pivotX = _seesaw.data.centerX;
    final double topY = _seesaw.data.centerY - _seesaw.data.halfHeight;
    final double baseY = topY - kDropGap;

    double randX(double l, double r) => l + _rng.nextDouble() * (r - l);
    final double x = randX(pivotX + 10.0, rightX - 10.0);
    final double y = baseY - _rng.nextDouble() * kDropBand;

    final double size = kBoxSizeMax; // 「大きい」= 90
    final double density =
        kDensityMin + (kDensityMax - kDensityMin) * _rng.nextDouble();

    final template = boxList[_rng.nextInt(boxList.length)];
    final boxData = template.copyWith(
      idx: 910000 + _rng.nextInt(1000),
      pos_x: x,
      pos_y: y,
      size_x: size,
      size_y: size,
      density: density, // 重さランダム（= 密度ランダム）
      gravityScale: 1.0,
      restitution: 0.0, // 跳ねない
      friction: 1.0, // 滑りにくい
      color: _randomNiceColor(template.color),
    );

    add(Box(boxData));
  }

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
      //⭐️ const kFixedDensity = 10.0;
      //⭐️ final radius = _rand(kBallRMin, kBallRMax)
      //⭐️ final radius = _choice(kBallSizes);

      //⭐️追加
      final i = _rng.nextInt(kBallSizes.length);
      final radius = kBallSizes[i];
      final density = kBallDensities[i];

      _heldBall = template.copyWith(
        idx: 2000 + _rng.nextInt(100000),
        pos_x: _player.position.x,
        pos_y: _player.position.y + _carryOffsetY,
        radius: radius,
        density: density,//⭐️修正
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

      //⭐️ const kFixedDensity = 10.0;
      //⭐️ final size = _rand(kBoxSizeMin, kBoxSizeMax);

      //⭐️追加
      final i = _rng.nextInt(kBoxSizes.length);
      final size = kBoxSizes[i];
      final density = kBoxDensities[i];

      _heldBox = template.copyWith(
        idx: 3000 + _rng.nextInt(100000),
        pos_x: _player.position.x,
        pos_y: _player.position.y + _carryOffsetY,
        size_x: size,
        size_y: size,
        density: density,//⭐️修正
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

  ItemSpec _randomItemSpecFromSettings() {
    final isBall = _rng.nextBool();

    double r(double a, double b) => a + (b - a) * _rng.nextDouble();
    final restitution = r(kRestitutionMin, kRestitutionMax);
    final friction = r(kFrictionMin, kFrictionMax);
    final gscale = r(kGravityScaleMin, kGravityScaleMax);

    if (isBall) {
      final template = ballList[_rng.nextInt(ballList.length)];
      //⭐️ final radius = r(kBallRMin, kBallRMax);
      //⭐️追加
      final radius = _choice(kBallSizes);

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
      //⭐️ final size = r(kBoxSizeMin, kBoxSizeMax);
      //⭐️追加
      final size = _choice(kBoxSizes);

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

```
