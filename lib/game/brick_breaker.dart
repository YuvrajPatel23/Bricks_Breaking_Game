import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config.dart';
import 'components/ball.dart';
import 'components/bat.dart';
import 'components/brick.dart';
import 'components/play_area.dart';
import 'systems/collision.dart';

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

  // Touch control variables
  double _touchStartX = 0;
  double _batStartX = 0;

  // Keyboard control variables
  bool _moveLeft = false;
  bool _moveRight = false;
  final double _batSpeed = GameConfig.batSpeed;

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

    // Create bricks
    _createBricks();

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

  void resetBall() {
    ball?.removeFromParent();
    ball = Ball(
      position: Vector2(bat.position.x, bat.position.y - 30),
      velocity: Vector2.zero(),
    );
    add(ball!);
    _isBallLaunched = false;
  }

  void _createBricks() {
    const rows = 5;
    const columns = 8;
    final totalBrickWidth = columns * GameConfig.brickSize.x;
    final totalPadding = (columns - 1) * brickPadding;
    final startX = (size.x - (totalBrickWidth + totalPadding)) / 2;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < columns; col++) {
        add(Brick(
          position: Vector2(
            startX + col * (GameConfig.brickSize.x + brickPadding) + GameConfig.brickSize.x / 2,
            row * (GameConfig.brickSize.y + brickPadding) + brickPadding + 100,
          ),
          hitsRequired: row + 1,
        ));
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
  }

  void restart() {
    _isGameOver = false;
    score = 0;
    lives = GameConfig.lives;
    children.whereType<Brick>().forEach((brick) => brick.removeFromParent());
    _createBricks();
    resetBall();
    overlays.remove('GameOver');
    scoreText.text = 'Score: $score';
    livesText.text = 'Lives: $lives';

    // Reset bat to center
    bat.position.x = size.x / 2;
  }

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