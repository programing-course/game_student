# **17_panel**

**①ESCでパネルを表示**

**【main.dart】**

```dart

  class _MyHomePageState extends State<MyHomePage> {
  final focusNode = FocusNode()..requestFocus();//⭐️追加
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('GAME'),
        ),
        body: GameWidget(
          game: MainGame(context),
          focusNode: focusNode,
          //⭐️追加
          overlayBuilderMap: {
            'PauseMenu': (context, game) =>
                PauseMenuOverlay(game: game as MainGame), 
          },
        ));
  }
}

//⭐️追加
class PauseMenuOverlay extends StatelessWidget {
  final MainGame game;
  const PauseMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'メニュー',
              style:
                  TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                game.overlays.remove('PauseMenu'); //閉じる
              },
              child: const Text('閉じる'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('フィールドに戻る'),
            ),
          ],
        ),
      ),
    );
  }
}


```

**【game.dart】**


```dart
@override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
      
      //省略

      // C でガード
      if (event.logicalKey == LogicalKeyboardKey.keyC) {
        isGuarding = true;
        print("Guard!!");
        return KeyEventResult.handled;
      }

      //⭐️追加
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        
        if (overlays.isActive('PauseMenu')) {
          overlays.remove('PauseMenu');
        } else {
          overlays.add('PauseMenu');
        }

        return KeyEventResult.handled;
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }

```

**プレーヤーの情報を表示する**

**【main.dart】**

```dart

import 'player.dart';//⭐️追加


class PauseMenuOverlay extends StatefulWidget {
  final MainGame game;
  const PauseMenuOverlay({super.key, required this.game});

  @override
  State<PauseMenuOverlay> createState() => _PauseMenuOverlayState();
}

class _PauseMenuOverlayState extends State<PauseMenuOverlay> {
  bool showPlayerInfo = false; //⭐️ プレーヤー情報表示フラグ

  @override
  Widget build(BuildContext context) {
    //⭐️ グローバルの player1 / player2 を使う
    final p1 = player1;
    final p2 = player2;

    return Center(
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'メニュー',
              style:
                  TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 24),
            ),
            const SizedBox(height: 20),

            //⭐️ プレーヤー情報ボタン
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showPlayerInfo = !showPlayerInfo;
                });
              },
              child: Text(showPlayerInfo ? 'プレーヤー情報を隠す' : 'プレーヤー情報'),
            ),

            const SizedBox(height: 8),

            //⭐️ 情報表示エリア
            if (showPlayerInfo) ...[
              const Divider(color: Color.fromARGB(137, 0, 0, 0)),
              const SizedBox(height: 8),
              _buildPlayerInfoCard('プレーヤー1', p1),
              const SizedBox(height: 8),
              _buildPlayerInfoCard('プレーヤー2', p2),
            ],

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                widget.game.overlays.remove('PauseMenu');
              },
              child: const Text('閉じる'),
            ),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () {
                // TODO: タイトルに戻る処理など
              },
              child: const Text('タイトルに戻る'),
            ),
          ],
        ),
      ),
    );
  }

  //⭐️ プレーヤー1人分の情報表示用ウィジェット
  Widget _buildPlayerInfoCard(String title, Player player) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color.fromARGB(60, 0, 0, 0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'HP : ${player.hp} / ${player.maxHp}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  'SP : ${player.sp} / ${player.maxSp}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  'Lv : ${player.lv}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  'Exp: ${player.exp}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 右側：プレーヤー画像
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Image.asset(
                // ★ ここはプロジェクトのパスに合わせて調整してね
                'assets/images/${player.data.imagePath}',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


```
