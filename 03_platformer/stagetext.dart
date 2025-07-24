import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'game.dart';
import 'setting.dart';

class StageText extends TextComponent with HasGameRef<MainGame> {
  StageText(this.data);
  final StageData data;

  @override
  Future<void> onLoad() async {
    print("currentStage==${currentStage}");
    position = Vector2(data.pos_x, data.pos_y);
    // ⭐️ステージ表示データと変数
    text = "STAGE" + (currentStage + 1).toString();
    print("STAGE==${text}");
    textRenderer = TextPaint(
        style: TextStyle(
            fontSize: data.font_size,
            fontWeight: FontWeight.bold,
            color: data.color));
  }

  @override
  Future<void> render(Canvas canvas) async {
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 🔵カメラの追従の有無追加
    if (gameRef.player.position.x > VIEW_X_START &&
        gameRef.player.position.x < VIEW_X_END &&
        camerafollow) {
      position.x = gameRef.player.position.x - VIEW_X_START + 10;
    }

    text = "STAGE" + (currentStage + 1).toString();
  }
}

class ScoreText extends TextComponent with HasGameRef<MainGame> {
  ScoreText(this.data);
  final StageData data;

  @override
  Future<void> onLoad() async {
    position = Vector2(data.pos_x, data.pos_y);
    text = "PLAY　${player_count}　　COIN　${coin_count}";

    textRenderer = TextPaint(
        style: TextStyle(
            fontSize: data.font_size,
            fontWeight: FontWeight.bold,
            color: data.color));
  }

  @override
  Future<void> render(Canvas canvas) async {
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);

    //🔵カメラの追従の有無追加
    if (gameRef.player.position.x > VIEW_X_START &&
        gameRef.player.position.x < VIEW_X_END &&
        camerafollow) {
      position.x = gameRef.player.position.x;
    }

    text = "PLAY　${player_count}　　COIN　${coin_count}";
  }
}

class countTimer extends TextComponent with HasGameRef<MainGame> {
  countTimer(this.data);
  final StageData data;

  Stopwatch _stopwatch = Stopwatch(); // システムのストップウォッチを使用

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _stopwatch.start(); // ストップウォッチ開始
    position = Vector2(data.pos_x, data.pos_y);
    text = 'Time: 0.0';
    textRenderer = TextPaint(
        style: TextStyle(
            fontSize: data.font_size,
            fontWeight: FontWeight.bold,
            color: data.color));
    priority = 1000;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // システムのストップウォッチから経過時間を取得
    elapsedTime = _stopwatch.elapsedMilliseconds / 1000.0; // 秒単位に変換

    if (StopTimer) {
      _stopwatch.stop();
      return;
    }

    // 🔵カメラの追従の有無追加
    if (gameRef.player.position.x > VIEW_X_START &&
        gameRef.player.position.x < VIEW_X_END &&
        camerafollow) {
      position.x = gameRef.player.position.x + VIEW_X_START * 1.5;
    }

    // 経過時間をテキストに表示
    text = 'Time: ${elapsedTime.toStringAsFixed(1)}';
  }
}

//ゴール
class goalText extends TextComponent with HasGameRef<MainGame> {
  goalText(this.data);
  final StageData data;

  @override
  Future<void> onLoad() async {
    position = Vector2(data.pos_x, data.pos_y);
    // ⭐️修正
    text = "GOAL\nPress [R] to retry\nPress [N] to nextstage";

    textRenderer = TextPaint(
        style: TextStyle(
            fontSize: data.font_size,
            fontWeight: FontWeight.bold,
            color: data.color));
  }

  @override
  Future<void> render(Canvas canvas) async {
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}

//ゲームオーバー
class gameOverText extends TextComponent with HasGameRef<MainGame> {
  gameOverText(this.data);
  final StageData data;

  @override
  Future<void> onLoad() async {
    position = Vector2(data.pos_x, data.pos_y);
    text = "GAMEORVER\nPress [R] to retry";

    textRenderer = TextPaint(
        style: TextStyle(
            fontSize: data.font_size,
            fontWeight: FontWeight.bold,
            color: data.color));
  }

  @override
  Future<void> render(Canvas canvas) async {
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // プレイヤーの位置に合わせてScoreTextの位置を更新
    if (gameRef.player.position.x > VIEW_X_START &&
        gameRef.player.position.x < VIEW_X_END) {
      position.x = gameRef.player.position.x;
    }
    // print("${gameRef.player.velocity.x}/${position.x}");
    text = "GAMEORVER\nPress [R] to retry";
  }
}

class RecordText extends TextComponent with HasGameRef<MainGame> {
  RecordText(this.data);
  final StageData data;

  @override
  Future<void> onLoad() async {
    position = Vector2(data.pos_x, data.pos_y);
    text =
        "PB ${recordTime.toStringAsFixed(1)}   SCORE ${elapsedTime.toStringAsFixed(1)}";

    textRenderer = TextPaint(
        style: TextStyle(
            fontSize: data.font_size,
            fontWeight: FontWeight.bold,
            color: data.color));
  }

  @override
  Future<void> render(Canvas canvas) async {
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}

class TextDisplay extends TextComponent with HasGameRef<MainGame> {
  TextDisplay(this.data);
  final TextData data;

  @override
  Future<void> onLoad() async {
    position = Vector2(data.pos_x, data.pos_y);
    text = data.text;
    priority = 100;

    textRenderer = TextPaint(
        style: TextStyle(
      fontSize: data.font_size,
      fontWeight: FontWeight.bold,
      color: data.color,
      fontFamily: 'NotoSansJP',
    ));
  }

  @override
  Future<void> render(Canvas canvas) async {
    super.render(canvas);
  }
}
