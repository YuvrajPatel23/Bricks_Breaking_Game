import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/brick_breaker.dart';

// Common overlay styles
const _titleStyle = TextStyle(
  fontSize: 40,
  color: Colors.white,
  fontWeight: FontWeight.bold,
);

const _textStyle = TextStyle(
  fontSize: 24,
  color: Colors.white,
);

const _buttonStyle = TextStyle(fontSize: 24);

const _buttonPadding = EdgeInsets.symmetric(horizontal: 40, vertical: 15);

// Base overlay structure
class BaseOverlay extends StatelessWidget {
  final List<Widget> children;
  final double width;

  const BaseOverlay({
    super.key,
    required this.children,
    this.width = 350,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: width,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }
}

// Reusable overlay components
class OverlayTitle extends StatelessWidget {
  final String text;

  const OverlayTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: _titleStyle);
  }
}

class OverlayText extends StatelessWidget {
  final String text;

  const OverlayText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: _textStyle);
  }
}

class OverlayButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const OverlayButton({
    super.key,
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: _buttonPadding,
      ),
      onPressed: onPressed,
      child: Text(text, style: _buttonStyle),
    );
  }
}

// Game Over Overlay
class GameOverOverlay extends StatelessWidget {
  final BrickBreakerGame game;

  const GameOverOverlay(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOverlay(
      children: [
        const OverlayTitle('Game Over'),
        const SizedBox(height: 20),
        OverlayText('Score: ${game.score}'),
        const SizedBox(height: 30),
        OverlayButton(
          text: 'Play Again',
          color: Colors.green,
          onPressed: game.restart,
        ),
      ],
    );
  }
}

// Level Complete Overlay
class LevelCompleteOverlay extends StatelessWidget {
  final BrickBreakerGame game;

  const LevelCompleteOverlay(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOverlay(
      children: [
        OverlayTitle('Level ${game.currentLevel} Complete!'),
        const SizedBox(height: 20),
        OverlayText('Score: ${game.score}'),
        const SizedBox(height: 30),
        OverlayButton(
          text: 'Next Level',
          color: Colors.blue,
          onPressed: game.nextLevel,
        ),
      ],
    );
  }
}

// Game Won Overlay
class GameWonOverlay extends StatelessWidget {
  final BrickBreakerGame game;

  const GameWonOverlay(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOverlay(
      width: 400,
      children: [
        const OverlayTitle('You Win!'),
        const SizedBox(height: 20),
        OverlayText('Final Score: ${game.score}'),
        const SizedBox(height: 30),
        OverlayButton(
          text: 'Play Again',
          color: Colors.purple,
          onPressed: game.restart,
        ),
      ],
    );
  }
}