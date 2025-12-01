# **01_スライドパズルをつくろう**

**①ディレクトリ構成**

lib/  
  　slide_puzzle_game/  
    　　-game/  
      　　　--slide_puzzle_game.dart  
      　　　--puzzle_controller.dart  
    　　-model/  
      　　　--puzzle_model.dart  
      　　　--tile_model.dart  
    　　-components/  
      　　　--tile_component.dart  
  　main.dart  

タップ入力  
　　↓  
タップ位置から index を計算  
　　↓  
その index が空白マスと隣接？  
　　├─ Yes → タイルを移動（ロジック）  
　　　　タイルComponentを移動（見た目）  
　　└─ No → 何もしない  
　　↓  
クリア状態か判定  
　　↓  
クリアなら PuzzleState.clear へ  

**【pabspec.yamal】**

```dart

dependencies:
  flutter:
    sdk: flutter
  flame: 1.30.0

```

**【main.dart】**

```dart

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'slide_puzzle_game/game/slide_puzzle_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SlidePuzzleApp());
}

class SlidePuzzleApp extends StatelessWidget {
  const SlidePuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final game = SlidePuzzleGame();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: GameWidget(game: game),
          ),
        ),
      ),
    );
  }
}


```
