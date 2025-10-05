# **10_ストッパー追加**

**①変数設定**

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
  //⭐️追加↓↓↓
  final double stopperThickness;
  final double stopperHeight;
  final double stopperInset;
  final double centerStopperWidth;
  final double centerStopperHeight;
  final double centerGap;

  const SeesawData(
      {required this.centerX,
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
      //⭐️追加↓↓↓
      required this.stopperThickness,
      required this.stopperHeight,
      required this.stopperInset,
      required this.centerStopperWidth,
      required this.centerStopperHeight,
      required this.centerGap});
}

/// 複数のシーソーをリストで返す（画面サイズに依存するので const にはしない）
List<SeesawData> seesawList = [
  // 画面中央・幅ほぼいっぱい
  SeesawData(
      centerX: FIELD_SIZE_X * 0.5,
      centerY: FIELD_SIZE_Y * 0.7,
      halfWidth: FIELD_SIZE_X * 0.5,
      halfHeight: 5,
      boardDensity: 5.0,
      boardFriction: 0.6,
      boardRestitution: 0.0,
      fulcrumRadius: 8.0,
      lowerAngleDeg: -20,
      upperAngleDeg: 20,
      angularDamping: 2.0,
      //⭐️追加↓↓↓
      stopperThickness: 10,
      stopperHeight: 60,
      stopperInset: 1,
      centerStopperWidth: 8.0,
      centerStopperHeight: 50,
      centerGap: 14),
];


```

**②描画**

**【seesaw.dart】**

左右に物体追加

```dart

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

    //⭐️追加　↓↓↓
    final stopperThickness = data.stopperThickness ?? 10; // X幅（world単位）
    final stopperHeight = data.stopperHeight ?? 60; // Y高さ（上向き）
    final inset = data.stopperInset ?? 1; // 端から少し内側に

    final halfT = stopperThickness / 2;
    final halfH = stopperHeight / 2;

    // 板ローカル座標での中心位置（上面は -data.halfHeight 側）
    final leftCenter = Vector2(
      -data.halfWidth + inset + halfT, // 左端から内側へ
      -data.halfHeight - halfH, // 上面のさらに上へ半分
    );
    final rightCenter = Vector2(
      data.halfWidth - inset - halfT, // 右端から内側へ
      -data.halfHeight - halfH,
    );

    //⭐️追加　↑↑↑

    return body;
  }

```

**画面にも描画**

```dart

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

    //⭐️追加　↓↓↓
    // 見た目にもストッパーを描く
    final stopperThickness = data.stopperThickness ?? 10;
    final stopperHeight = data.stopperHeight ?? 60;
    final inset = data.stopperInset ?? 1;

    // Canvas は y+ が下なので注意：上に描きたい=マイナス方向
    final halfTpx = stopperThickness / 2;
    final halfHpx = stopperHeight / 2;

    // 左
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(
          -data.halfWidth + inset + halfTpx,
          -data.halfHeight - halfHpx,
        ),
        width: stopperThickness,
        height: stopperHeight,
      ),
      paint,
    );
    // 右
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(
          data.halfWidth - inset - halfTpx,
          -data.halfHeight - halfHpx,
        ),
        width: stopperThickness,
        height: stopperHeight,
      ),
      paint,
    );
    //⭐️追加　↑↑↑

  }
}

```

真ん中にもストッパーをつける

```dart

@override
  Body createBody() {
    //省略

    // --------真ん中のストッパー
    // 全サイズ指定
    final centerStopperWidth = data.centerStopperWidth ?? 8.0; // X方向の全幅
    final centerStopperHeight = data.centerStopperHeight ?? 50.0; // Y方向の全高（上向き）
    final centerGap = data.centerGap ?? 14.0; // 支点中心を挟む左右の「内側端」までの距離

    // 半サイズへ
    final cHalfW = centerStopperWidth / 2;
    final cHalfH = centerStopperHeight / 2;

    // 板ローカルの中心から左右へオフセット
    // 支点（revolute）のアンカーは board.body.worldCenter なので、ローカル原点(0,0)が板の中心。
    // 上に突き出すので y は -(板半厚 + 半高さ)
    final centerLeft =
        Vector2(-centerGap - cHalfW, -(data.halfHeight + cHalfH));
    final centerRight =
        Vector2(centerGap + cHalfW, -(data.halfHeight + cHalfH));

    // 左（中心側）
    final cLeftShape = PolygonShape()
      ..setAsBox(cHalfW, cHalfH, centerLeft, 0.0);
    body.createFixture(FixtureDef(cLeftShape)
      ..density = data.boardDensity
      ..friction = 0.8
      ..restitution = 0.0);

    // 右（中心側）
    final cRightShape = PolygonShape()
      ..setAsBox(cHalfW, cHalfH, centerRight, 0.0);
    body.createFixture(FixtureDef(cRightShape)
      ..density = data.boardDensity
      ..friction = 0.8
      ..restitution = 0.0);

    return body;
  }


```

**画面にも描画**

``dart

@override
  void render(Canvas canvas) {
  
  //省略

  // 中央ストッパー描画（板本体の描画の後）
    final centerStopperWidth = data.centerStopperWidth ?? 8.0;
    final centerStopperHeight = data.centerStopperHeight ?? 50.0;
    final centerGap = data.centerGap ?? 14.0;

    final cHalfW = centerStopperWidth / 2;
    final cHalfH = centerStopperHeight / 2;

    // 左
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(-centerGap - cHalfW, -(data.halfHeight + cHalfH)),
        width: centerStopperWidth,
        height: centerStopperHeight,
      ),
      paint,
    );
    // 右
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerGap + cHalfW, -(data.halfHeight + cHalfH)),
        width: centerStopperWidth,
        height: centerStopperHeight,
      ),
      paint,
    );
  }
}

```

