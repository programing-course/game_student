# **24_STAGE2を作る**

## **この単元でやること**

1. 背景を入れる
2. カメラの追従をなくす

## **1. 背景を入れる**

![stage](img/24_stage1-1.png)

### **①位置データを作成**

**【setting.dart】**

背景をデータから作る  
stage1の背景もデータから取得

```dart

class BackGroundData {
  final int idx;
  final Color color1;
  final Color color2;
  final double size_x;
  final double size_y;
  final double pos_x;
  final double pos_y;
  final String background_img;

  BackGroundData({
    required this.idx,
    required this.color1,
    required this.color2,
    required this.size_x,
    required this.size_y,
    required this.pos_x,
    required this.pos_y,
    required this.background_img,
  });
}

List<BackGroundData> BackGroundlist = [
  BackGroundData(
    idx: 0,
    color1: Color.fromARGB(255, 68, 185, 183),
    color2: Color.fromARGB(255, 203, 249, 240),
    size_x: FIELD_SIZE_X,
    size_y: FIELD_SIZE_Y,
    pos_x: 0,
    pos_y: 0,
    background_img: "",
  ),
  BackGroundData(
    idx: 1,
    color1: Color.fromARGB(255, 152, 193, 255),
    color2: Color.fromARGB(255, 152, 193, 255),
    size_x: screenSize.x,
    size_y: screenSize.y,
    pos_x: 0,
    pos_y: 0,
    background_img: "background.png",
  )
];

```

### **②オブジェクトの修正**

**【screen.dart】**

```dart

class CameraBackScreen extends RectangleComponent with HasGameRef<MainGame> {

  //⭐️データ受け取り
  CameraBackScreen(this.data);
  final BackGroundData data;

  @override
  Future<void> onLoad() async {
    //⭐️データに置き換え
    position = Vector2(data.pos_x, data.pos_y);
    size = Vector2(data.size_x, data.size_y);
    paint = Paint()..color = data.color1;
  }

  @override
  Future<void> render(Canvas canvas) async {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [data.color1, data.color2], // ⭐️データに置き換え
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }
}

```

背景に画像を表示するオブジェクト作成

```dart

class BackScreenImg extends SpriteComponent with HasGameRef<MainGame> {
  BackScreenImg(
    this.data,
    this.count_x,
  );
  final BackGroundData data;
  int count_x;

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite(data.background_img);
    size = Vector2(data.size_x, data.size_y);
    position = Vector2(data.pos_x + screenSize.x * count_x, data.pos_y);
  }

  @override
  Future<void> render(Canvas canvas) async {
    super.render(canvas);
  }
}


```

### **③インスタンス作成**

**【game.dart】**

STAGE1の呼び出し修正  
データを渡すように修正

```dart

    CameraBackScreen backscreen = CameraBackScreen(BackGroundlist[0]);
    await world.add(backscreen);

```

STAGE2の背景作成

```dart

    switch (currentStage) {
      case 0:

        //省略

      case 1:

        //⭐️背景を入れる（４つ分）
        for (int i = 0; i < 4; i++) {
          BackScreenImg _backscreenimg = BackScreenImg(BackGroundlist[1], i);
          await world.add(_backscreenimg);
        }

        
        break;
      default:
    }

```

### **④ダンジョン風にする**

**カメラの追従をなくす**

**【game.dart】**

```dart

int currentStage = 0;
bool leftflg = false;
bool rightflg = false;

//⭐️カメラ追従するしない
bool camerafollow = true;


//省略


  switch (currentStage) {
    case 0:
      //省略
      break;
    case 1:
      //背景を入れる
      for (int i = 0; i < 4; i++) {
        BackScreenImg _backscreenimg = BackScreenImg(BackGroundlist[1], i);
        await world.add(_backscreenimg);
      }
      
      //⭐️ カメラの追従なしにする
      camerafollow = false;

      break;
    default:
  }

//省略

@override
void update(double dt) {
  super.update(dt);

  // ⭐️カメラの追従の有無追加　 camerafollow条件追加
  if (player.position.x > VIEW_X_START && player.position.x < VIEW_X_END && camerafollow) {
    //プレイヤーに追従する
    cameraComponent.viewfinder.position =
        Vector2(player.position.x, Y_GROUND_POSITION);
  } else {
    if (player.position.x > VIEW_X_END) {
      // 範囲外になったら追従しない
      cameraComponent.viewfinder.position =
          Vector2(VIEW_X_END, Y_GROUND_POSITION);
    } else {
      // 範囲まで追従しない
      cameraComponent.viewfinder.position =
          Vector2(VIEW_X_START, Y_GROUND_POSITION);
    }
  }
  cameraComponent.update(dt);
}

```

**【stagetext.dart】**

カメラの追従有無を追加

**StageTextクラスの中**

```darat

@override
  void update(double dt) {
    super.update(dt);

    // ⭐️カメラの追従の有無追加追加
    if (gameRef.player.position.x > VIEW_X_START && gameRef.player.position.x < VIEW_X_END && camerafollow) {
      position.x = gameRef.player.position.x - VIEW_X_START + 10;
    }

    text = "STAGE" + (currentStage + 1).toString();
  }


```

**ScoreTextクラスの中**

```darat

@override
  void update(double dt) {
    super.update(dt);

    // ⭐️カメラの追従の有無追加追加
    if (gameRef.player.position.x > VIEW_X_START && gameRef.player.position.x < VIEW_X_END && camerafollow) {
      position.x = gameRef.player.position.x;
    }

    text = "PLAY　${player_count}　　COIN　${coin_count}";
  }


```

**countTimerクラスの中**

```darat

@override
  void update(double dt) {
    super.update(dt);

    // ⭐️カメラの追従の有無追加追加
    if (gameRef.player.position.x > VIEW_X_START && gameRef.player.position.x < VIEW_X_END && camerafollow) {
      position.x = gameRef.player.position.x + VIEW_X_START * 1.5;
    }

    // 経過時間をテキストに表示
    text = 'Time: ${elapsedTime.toStringAsFixed(1)}';
  }


```
