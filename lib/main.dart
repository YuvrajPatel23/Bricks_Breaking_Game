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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          accentColor: Colors.green,
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 24),
          bodyLarge: TextStyle(fontSize: 20),
        ),
      ),
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
          'LevelComplete': (context, _) => LevelCompleteOverlay(game),
          'GameWon': (context, _) => GameWonOverlay(game),
        },
      ),
    );
  }
}