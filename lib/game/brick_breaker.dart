import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'config.dart';
import 'components/ball.dart';
import 'components/bat.dart';
import 'components/brick.dart';
import 'components/play_area.dart';
import 'systems/collision.dart';

class Level {
  final int number;
  final List<List<int>> brickLayout;
  final String description;


  Level({
    required this.number,
    required this.brickLayout,
    required this.description,
  });
}

class LevelManager {
  static List<Level> get levels => [
    Level(
      number: 1,
      description: "Basic Pattern",
      brickLayout: [
        [1, 1, 1, 1, 1, 1, 1, 1],
        [1, 2, 2, 2, 2, 2, 2, 1],
        [1, 2, 3, 3, 3, 3, 2, 1],
        [1, 2, 2, 2, 2, 2, 2, 1],
        [1, 1, 1, 1, 1, 1, 1, 1],
      ],
    ),
    Level(
      number: 2,
      description: "Diamond Formation",
      brickLayout: [
        [0, 0, 0, 3, 3, 0, 0, 0],
        [0, 0, 3, 2, 2, 3, 0, 0],
        [0, 3, 2, 1, 1, 2, 3, 0],
        [3, 2, 1, 0, 0, 1, 2, 3],
        [3, 2, 1, 0, 0, 1, 2, 3],
      ],
    ),
    Level(
      number: 3,
      description: "Hardcore Challenge",
      brickLayout: [
        [4, 4, 4, 4, 4, 4, 4, 4],
        [3, 0, 3, 0, 0, 3, 0, 3],
        [2, 2, 0, 2, 2, 0, 2, 2],
        [1, 0, 1, 0, 0, 1, 0, 1],
        [3, 3, 0, 3, 3, 0, 3, 3],
      ],
    ),
  ];
}

class BrickBreakerGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents, TapDetector, PanDetector {
  late final Bat bat;
  Ball? ball;
  late TextComponent scoreText;
  late TextComponent livesText;
  int score = 0;
  int lives = GameConfig.lives;
  late final CollisionSystem collisionSystem;
  final double brickPadding = 10;
  bool _isGameOver = false;
  bool _isBallLaunched = false;

  // Level management
  int currentLevel = 1;
  bool _isLevelComplete = false;
  bool _isGameWon = false;
  final Random _random = Random();

  // Touch control variables
  double _touchStartX = 0;
  double _batStartX = 0;

  // Keyboard control variables
  bool _moveLeft = false;
  bool _moveRight = false;
  final double _batSpeed = GameConfig.batSpeed;

  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  final ValueNotifier<int> livesNotifier = ValueNotifier(GameConfig.lives);
  final ValueNotifier<int> levelNotifier = ValueNotifier(1);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    collisionSystem = CollisionSystem(this);

    // Game area
    add(PlayArea()..size = size);

    // Create player bat
    bat = Bat(position: Vector2(size.x / 2, size.y - 50));
    add(bat);

    // Create ball (initially stationary)
    resetBall();

    // Create bricks for the first level
    _loadLevel(currentLevel);

    // Initialize notifiers
    scoreNotifier.value = score;
    livesNotifier.value = lives;
    levelNotifier.value = currentLevel;

    // UI elements
    scoreText = TextComponent(
      text: 'Score: $score',
      position: Vector2(10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
    add(scoreText);

    livesText = TextComponent(
      text: 'Lives: $lives',
      position: Vector2(size.x - 100, 10),
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
    add(livesText);
  }

  void _loadLevel(int levelNumber) {
    // Clear existing bricks
    children.whereType<Brick>().forEach((brick) => brick.removeFromParent());

    // Load new level
    final level = LevelManager.levels.firstWhere((l) => l.number == levelNumber);
    _createBricks(level.brickLayout);

    // Reset game state for the level
    resetBall();
    _isLevelComplete = false;
    _isGameWon = false;
    overlays.remove('LevelComplete');
    overlays.remove('GameWon');

    levelNotifier.value = currentLevel;
  }

  void resetBall() {
    ball?.removeFromParent();
    ball = Ball(
      position: Vector2(bat.position.x, bat.position.y - 30),
      velocity: Vector2.zero(),
    );
    add(ball!);
    _isBallLaunched = false;
  }

  void _createBricks(List<List<int>> layout) {
    final rows = layout.length;
    final rowHeight = GameConfig.brickSize.y + brickPadding;
    final startY = 100.0;

    for (int row = 0; row < rows; row++) {
      final columns = layout[row].length;
      final totalBrickWidth = columns * GameConfig.brickSize.x;
      final totalPadding = (columns - 1) * brickPadding;
      final startX = (size.x - (totalBrickWidth + totalPadding)) / 2;

      for (int col = 0; col < columns; col++) {
        final strength = layout[row][col];
        if (strength > 0) {
          add(Brick(
            position: Vector2(
              startX + col * (GameConfig.brickSize.x + brickPadding) + GameConfig.brickSize.x / 2,
              startY + row * rowHeight,
            ),
            hitsRequired: strength,
          ));
        }
      }
    }
  }

  void _playFireworks() {
    for (int i = 0; i < GameConfig.levelCompletionFireworkCount; i++) {
      final position = Vector2(
        _random.nextDouble() * size.x,
        _random.nextDouble() * size.y,
      );
      _createFirework(position);
    }
  }

  void _createFirework(Vector2 position) {
    final particle = Particle.generate(
      count: 30,
      lifespan: 1.5,
      generator: (i) {
        final velocity = Vector2(
          (_random.nextDouble() * 400 - 200),
          (_random.nextDouble() * 400 - 200),
        );
        return AcceleratedParticle(
          acceleration: Vector2(0, 100),
          speed: velocity,
          position: position.clone(),
          child: CircleParticle(
              radius: 1 + _random.nextDouble() * 4,
              paint: Paint()
                ..color = Colors.primaries[_random.nextInt(Colors.primaries.length)]
          ),
        );
      },
    );
    add(ParticleSystemComponent(particle: particle));
  }

  void _checkLevelCompletion() {
    if (children.whereType<Brick>().isEmpty && !_isLevelComplete) {
      _isLevelComplete = true;

      // Celebration fireworks
      _playFireworks();

      if (currentLevel < GameConfig.totalLevels) {
        Future.delayed(const Duration(seconds: 2), () {
          overlays.add('LevelComplete');
        });
      } else {
        _isGameWon = true;
        Future.delayed(const Duration(seconds: 2), () {
          overlays.add('GameWon');
        });
      }
    }
  }

  @override
  void update(double dt) {
    if (_isGameOver) return;
    super.update(dt);

    // Handle keyboard movement
    if (_moveLeft || _moveRight) {
      final direction = _moveLeft ? -1 : 1;
      bat.position.x += direction * _batSpeed * dt;
      bat.position.x = bat.position.x.clamp(
        bat.size.x / 2,
        size.x - bat.size.x / 2,
      );

      if (ball != null && !_isBallLaunched) {
        ball!.position = Vector2(bat.position.x, bat.position.y - 30);
      }
    }

    if (ball != null) {
      if (_isBallLaunched) {
        collisionSystem.checkBallWallCollision(ball!, size);
        collisionSystem.checkBallBatCollision(ball!, bat);

        children.whereType<Brick>().forEach((brick) {
          if (collisionSystem.checkBallBrickCollision(ball!, brick)) {
            score += GameConfig.brickPoints;
            scoreText.text = 'Score: $score';
          }
        });

        if (ball!.position.y > size.y) {
          lives--;
          livesText.text = 'Lives: $lives';

          if (lives > 0) {
            resetBall();
          } else {
            _isGameOver = true;
            overlays.add('GameOver');
          }
        }
      } else {
        ball!.position = Vector2(bat.position.x, bat.position.y - 30);
      }
    }

    // Update score when it changes
    if (scoreNotifier.value != score) {
      scoreNotifier.value = score;
    }

    // Update lives when they change
    if (livesNotifier.value != lives) {
      livesNotifier.value = lives;
    }

    _checkLevelCompletion();
  }

  void nextLevel() {
    if (currentLevel < GameConfig.totalLevels) {
      currentLevel++;
      levelNotifier.value = currentLevel;
      _loadLevel(currentLevel);
    }
  }

  void restart() {
    currentLevel = 1;
    score = 0;
    lives = GameConfig.lives;
    _loadLevel(currentLevel);
    _isGameOver = false;
    overlays.remove('GameOver');
    overlays.remove('LevelComplete');
    overlays.remove('GameWon');
    scoreText.text = 'Score: $score';
    livesText.text = 'Lives: $lives';
    bat.position.x = size.x / 2;

    scoreNotifier.value = score;
    livesNotifier.value = lives;
    levelNotifier.value = currentLevel;
  }

  // ... existing touch and keyboard controls ...

  // Universal touch controls
  @override
  void onPanStart(DragStartInfo info) {
    if (!_isGameOver) {
      _touchStartX = _getTouchX(info);
      _batStartX = bat.position.x;
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (!_isGameOver) {
      final touchX = _getTouchX(info);
      final deltaX = touchX - _touchStartX;

      bat.position.x = (_batStartX + deltaX).clamp(
        bat.size.x / 2,
        size.x - bat.size.x / 2,
      );

      if (ball != null && !_isBallLaunched) {
        ball!.position = Vector2(bat.position.x, bat.position.y - 30);
      }
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (!_isGameOver && ball != null && !_isBallLaunched) {
      ball!.velocity = Vector2(0, -GameConfig.ballSpeed);
      _isBallLaunched = true;
    }
  }

  // Keyboard controls
  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (_isGameOver) return KeyEventResult.ignored;

    final isKeyDown = event is KeyDownEvent;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _moveLeft = isKeyDown;
    }
    else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _moveRight = isKeyDown;
    }
    else if (isKeyDown && event.logicalKey == LogicalKeyboardKey.space) {
      if (ball != null && !_isBallLaunched) {
        ball!.velocity = Vector2(0, -GameConfig.ballSpeed);
        _isBallLaunched = true;
      }
    }

    return KeyEventResult.handled;
  }

  double _getTouchX(dynamic info) {
    try {
      if (info is DragStartInfo || info is DragUpdateInfo) {
        try {
          return info.eventPosition.game.x;
        } catch (_) {}

        try {
          return info.localPosition.dx;
        } catch (_) {}

        try {
          return info.globalPosition.dx;
        } catch (_) {}
      }
    } catch (_) {}

    return bat.position.x;
  }
}