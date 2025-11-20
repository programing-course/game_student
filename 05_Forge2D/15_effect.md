# **15_effect**

**①変数設定**

**【crane_game.dart】**


```dart

import 'package:flame/particles.dart' as fp;

//省略

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

    _spawnMergeParticles(pos, newColor);　//⭐️

    _onMerged();
  }

  //⭐️一番下に追加
  // === Merge Particle Effect ===
  void _spawnMergeParticles(Vector2 worldPos, Color color) {
    final paint = Paint()..color = color.withOpacity(0.8);

    add(
      ParticleSystemComponent(
        position: worldPos, // Component 側のクラス（プレフィックスなし）
        particle: fp.Particle.generate(
          // Flame パーティクルは fp. 付き
          count: 20,
          lifespan: 0.4,
          generator: (i) {
            final dir = (Vector2.random(_rng) - Vector2.all(0.5)).normalized();
            final speed = 80 + _rng.nextDouble() * 60;

            return fp.AcceleratedParticle(
              speed: dir * speed,
              acceleration: Vector2(0, 200),
              child: fp.CircleParticle(
                radius: 1.5,
                paint: paint,
              ),
            );
          },
        ),
      ),
    );
  }


```
