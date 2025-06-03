import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/brick_breaker.dart';
import 'widgets/game_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brick Breaker',
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final BrickBreakerGame game;

  @override
  void initState() {
    super.initState();
    game = BrickBreakerGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<BrickBreakerGame>(
        game: game,
        overlayBuilderMap: {
          'GameOver': (context, _) => GameOverOverlay(game),
        },
      ),
    );
  }
}