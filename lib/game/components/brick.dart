import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import '../brick_breaker.dart';
import '../config.dart';
import 'dart:math';

class Brick extends RectangleComponent {
  final int hitsRequired;
  int hits = 0;
  final Random _random = Random();

  Brick({
    required super.position,
    required this.hitsRequired,
  }) : super(
    size: GameConfig.brickSize,
    anchor: Anchor.center,
    paint: Paint()..color = _getColor(hitsRequired),
  );

  static Color _getColor(int strength) {
    return GameConfig.brickColors[
    (strength - 1) % GameConfig.brickColors.length
    ];
  }

  Future<void> breakBrick() async {
    final game = findParent<BrickBreakerGame>()!;

    // Enhanced break effect
    game.add(ParticleSystemComponent(
      particle: Particle.generate(
        count: 25 + hitsRequired * 5,  // More particles for stronger bricks
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2(0, 200),
          speed: Vector2(
            (_random.nextDouble() * 300) * (_random.nextBool() ? 1 : -1),
            (_random.nextDouble() * 300) * (_random.nextBool() ? 1 : -1),
          ),
          position: position.clone(),
          child: CircleParticle(
            radius: 1 + _random.nextDouble() * (1 + hitsRequired * 0.5),
            paint: Paint()..color = paint!.color,
          ),
        ),
      ),
    ));

    removeFromParent();
  }

  bool hit() {
    hits++;
    if (hits >= hitsRequired) {
      breakBrick();
      return true;
    }
    return false;
  }
}