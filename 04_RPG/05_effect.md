# **05_エフェクト表示**


**【setting.dart】**

```dart

class ButtonData {
  final int idx;
  final Color color1;
  final Color color2;
  final double size_x;
  final double size_y;
  final double pos_x;
  final double pos_y;
  final String background_img;
  final String label;

  ButtonData({
    required this.idx,
    required this.color1,
    required this.color2,
    required this.size_x,
    required this.size_y,
    required this.pos_x,
    required this.pos_y,
    required this.background_img,
    required this.label,
  });
}

class SpriteFrameSpec {
  final double sx; // シート上の切り出し左上X(ピクセル)
  final double sy; // シート上の切り出し左上Y(ピクセル)
  final double sw; // 切り出し幅
  final double sh; // 切り出し高さ
  final double? stepTime; // そのコマだけ再生時間を変えたい場合(省略可)

  const SpriteFrameSpec({
    required this.sx,
    required this.sy,
    required this.sw,
    required this.sh,
    this.stepTime,
  });
}

List<EffectData> Effectlist = [
  EffectData(
    idx: 0,
    color: Color.fromARGB(255, 255, 100, 100),
    size_x: 500.0,
    size_y: 500.0,
    pos_x: SCREENSIZE_X / 1.5,
    pos_y: SCREENSIZE_Y / 2,
    count: 100,
    background_img: "",
    type: EffectType.attackNormal,
  ),
  EffectData(
    idx: 1,
    color: Colors.orangeAccent,
    size_x: 120.0,
    size_y: 120.0,
    pos_x: 500,
    pos_y: 300,
    count: 35,
    background_img: "",
    type: EffectType.largeExplosion,
  ),
  EffectData(
    idx: 2,
    color: Colors.blue,
    size_x: 100.0,
    size_y: 100.0,
    pos_x: 600,
    pos_y: 400,
    count: 10,
    background_img: "",
    type: EffectType.hitSpark,
  ),
  EffectData(
    idx: 3,
    color: Colors.transparent,
    size_x: 192, size_y: 192, // 6倍拡大表示
    pos_x: SCREENSIZE_X / 2,
    pos_y: SCREENSIZE_Y / 2,
    count: 0,
    background_img: "",
    type: EffectType.spriteSlash, // 任意のスプライト系タイプ
    spriteImage: 'YellowEffect.png', // 32x32タイルのシート
    frameCount: 3, // 3コマ使う
    stepTime: 0.1, // 速めのアニメ
    frameWidth: 32,
    frameHeight: 32,
    startRow: 0, // 行モード：2行目
    startCol: 2, // 4列目からスタート（0始まり）
  ),
  EffectData(
    idx: 3,
    color: Colors.transparent,
    size_x: 192, size_y: 192, // 6倍拡大表示
    pos_x: SCREENSIZE_X / 3,
    pos_y: SCREENSIZE_Y / 3,
    count: 0,
    background_img: "",
    type: EffectType.spriteSlash, // 任意のスプライト系タイプ
    spriteImage: 'YellowEffect.png', // 32x32タイルのシート
    stepTime: 0.1, // 速めのアニメ
    frames: [
      // i=0: 32x32
      SpriteFrameSpec(sx: 2 * 32, sy: 2 * 32, sw: 32, sh: 48),
      SpriteFrameSpec(sx: 3 * 32, sy: 2 * 32, sw: 32, sh: 48),
      SpriteFrameSpec(sx: 4 * 32, sy: 2 * 32, sw: 32, sh: 48),
    ],
  )
];

```

**【effect.dart】**

```dart

import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'dart:math';
import 'game.dart';
import 'setting.dart';

class SpriteEffect extends SpriteAnimationComponent with HasGameRef<MainGame> {
  SpriteEffect(this.data) : super(anchor: Anchor.bottomCenter);

  final EffectData data;

  @override
  Future<void> onLoad() async {
    if (data.spriteImage == null) {
      throw Exception("spriteImage が必要です。");
    }
    final image = await gameRef.images.load(data.spriteImage!);

    position = Vector2(data.pos_x, data.pos_y);
    size = Vector2(data.size_x, data.size_y);

    final frames = <SpriteAnimationFrame>[];

    if (data.frames != null && data.frames!.isNotEmpty) {
      // ===== 不規則スプライト：明示フレーム配列をそのまま使う =====
      for (final f in data.frames!) {
        frames.add(
          SpriteAnimationFrame(
            Sprite(
              image,
              srcPosition: Vector2(f.sx, f.sy),
              srcSize: Vector2(f.sw, f.sh),
            ),
            f.stepTime ?? (data.stepTime ?? 0.06),
          ),
        );
      }
    } else {
      // ===== 従来のグリッド系（startRow/startCol など） =====
      if (data.frameWidth == null ||
          data.frameHeight == null ||
          data.frameCount == null ||
          data.stepTime == null) {
        throw Exception(
            "フレーム配列が無い場合は frameWidth/Height, frameCount, stepTime が必要です。");
      }
      final fw = data.frameWidth!.toDouble();
      final fh = data.frameHeight!.toDouble();
      final imageWidth = image.width.toDouble();
      final imageHeight = image.height.toDouble();
      final framesToTake = data.frameCount!;

      if (data.startRow != null) {
        // 行モード：右へ
        final row = data.startRow!;
        final startC = (data.startCol ?? 0);
        for (int i = 0; i < framesToTake; i++) {
          final sx = (startC + i) * fw;
          final sy = row * fh;
          if (sx + fw <= imageWidth && sy + fh <= imageHeight) {
            frames.add(SpriteAnimationFrame(
              Sprite(image,
                  srcPosition: Vector2(sx, sy), srcSize: Vector2(fw, fh)),
              data.stepTime!,
            ));
          }
        }
      } else if (data.startCol != null) {
        // 列モード：下へ
        final col = data.startCol!;
        final startR = (data.startRow ?? 0);
        for (int i = 0; i < framesToTake; i++) {
          final sx = col * fw;
          final sy = (startR + i) * fh;
          if (sx + fw <= imageWidth && sy + fh <= imageHeight) {
            frames.add(SpriteAnimationFrame(
              Sprite(image,
                  srcPosition: Vector2(sx, sy), srcSize: Vector2(fw, fh)),
              data.stepTime!,
            ));
          }
        }
      } else {
        throw Exception("グリッド再生は startRow または startCol のどちらかが必要です。");
      }
    }

    animation = SpriteAnimation(frames, loop: false);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (animationTicker?.done() ?? false) removeFromParent();
  }
}

```

**【game.dart】**

```dart

        Effect _effect1 = Effect(Effectlist[0]);
        await world.add(_effect1);

        Effect _effect2 = Effect(Effectlist[1]);
        await world.add(_effect2);

```
**【effect.dart】**

```dart

class SpriteEffect extends SpriteAnimationComponent with HasGameRef<MainGame> {
  SpriteEffect(this.data) : super(anchor: Anchor.bottomCenter);

  final EffectData data;

  @override
  Future<void> onLoad() async {
    if (data.spriteImage == null) {
      throw Exception("spriteImage が必要です。");
    }
    final image = await gameRef.images.load(data.spriteImage!);

    position = Vector2(data.pos_x, data.pos_y);
    size = Vector2(data.size_x, data.size_y);

    final frames = <SpriteAnimationFrame>[];

    if (data.frames != null && data.frames!.isNotEmpty) {
      // ===== 不規則スプライト：明示フレーム配列をそのまま使う =====
      for (final f in data.frames!) {
        frames.add(
          SpriteAnimationFrame(
            Sprite(
              image,
              srcPosition: Vector2(f.sx, f.sy),
              srcSize: Vector2(f.sw, f.sh),
            ),
            f.stepTime ?? (data.stepTime ?? 0.06),
          ),
        );
      }
    } else {
      // ===== 従来のグリッド系（startRow/startCol など） =====
      if (data.frameWidth == null ||
          data.frameHeight == null ||
          data.frameCount == null ||
          data.stepTime == null) {
        throw Exception(
            "フレーム配列が無い場合は frameWidth/Height, frameCount, stepTime が必要です。");
      }
      final fw = data.frameWidth!.toDouble();
      final fh = data.frameHeight!.toDouble();
      final imageWidth = image.width.toDouble();
      final imageHeight = image.height.toDouble();
      final framesToTake = data.frameCount!;

      if (data.startRow != null) {
        // 行モード：右へ
        final row = data.startRow!;
        final startC = (data.startCol ?? 0);
        for (int i = 0; i < framesToTake; i++) {
          final sx = (startC + i) * fw;
          final sy = row * fh;
          if (sx + fw <= imageWidth && sy + fh <= imageHeight) {
            frames.add(SpriteAnimationFrame(
              Sprite(image,
                  srcPosition: Vector2(sx, sy), srcSize: Vector2(fw, fh)),
              data.stepTime!,
            ));
          }
        }
      } else if (data.startCol != null) {
        // 列モード：下へ
        final col = data.startCol!;
        final startR = (data.startRow ?? 0);
        for (int i = 0; i < framesToTake; i++) {
          final sx = col * fw;
          final sy = (startR + i) * fh;
          if (sx + fw <= imageWidth && sy + fh <= imageHeight) {
            frames.add(SpriteAnimationFrame(
              Sprite(image,
                  srcPosition: Vector2(sx, sy), srcSize: Vector2(fw, fh)),
              data.stepTime!,
            ));
          }
        }
      } else {
        throw Exception("グリッド再生は startRow または startCol のどちらかが必要です。");
      }
    }

    animation = SpriteAnimation(frames, loop: false);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (animationTicker?.done() ?? false) removeFromParent();
  }
}

```