import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import '../components/ball.dart';
import '../components/bat.dart';
import '../components/brick.dart';
import '../config.dart';
import '../brick_breaker.dart';

class CollisionSystem {
  final BrickBreakerGame game;
  final Random _random = Random();

  CollisionSystem(this.game);

  void _addImpactEffect(Vector2 position, Color color) {
    // game.playSound('impact'); //uncomment after adding sound
    final particle = Particle.generate(
      count: 10,
      lifespan: 0.5,
      generator: (i) {
        final velocity = Vector2(
          (_random.nextDouble() * 200 - 100),
          (_random.nextDouble() * 200 - 100),
        );
        return AcceleratedParticle(
          acceleration: Vector2(0, 100),
          speed: velocity,
          position: position.clone(),
          child: CircleParticle(
            radius: 1 + _random.nextDouble() * 3,
            paint: Paint()..color = color,
          ),
        );
      },
    );

    game.add(ParticleSystemComponent(
      position: position,
      particle: particle,
    ));
  }

  void checkBallWallCollision(Ball ball, Vector2 gameSize) {
    if (ball.position.x <= ball.radius) {
      _addImpactEffect(Vector2(ball.radius, ball.position.y), Colors.white);
      ball.velocity = Vector2(-ball.velocity.x, ball.velocity.y);
    } else if (ball.position.x >= gameSize.x - ball.radius) {
      _addImpactEffect(Vector2(gameSize.x - ball.radius, ball.position.y), Colors.white);
      ball.velocity = Vector2(-ball.velocity.x, ball.velocity.y);
    }

    if (ball.position.y <= ball.radius) {
      _addImpactEffect(Vector2(ball.position.x, ball.radius), Colors.white);
      ball.velocity = Vector2(ball.velocity.x, -ball.velocity.y);
    }
  }


  void checkBallBatCollision(Ball ball, Bat bat) {
    final ballRect = Rect.fromCircle(
      center: ball.position.toOffset(),
      radius: ball.radius,
    );
    final batRect = Rect.fromCenter(
      center: bat.position.toOffset(),
      width: bat.size.x,
      height: bat.size.y,
    );

    if (ballRect.overlaps(batRect)) {
      _addImpactEffect(ball.position, Colors.green);

      final collisionPoint = (ball.position.x - bat.position.x) / bat.size.x;
      final normalizedPoint = (collisionPoint * 2) - 1;
      final angle = normalizedPoint * (pi / 4); // 45-degree max angle

      ball.velocity = Vector2(
        GameConfig.ballSpeed * sin(angle),
        -GameConfig.ballSpeed * cos(angle),
      );
    }
  }

  bool checkBallBrickCollision(Ball ball, Brick brick) {
    final ballRect = Rect.fromCircle(
      center: ball.position.toOffset(),
      radius: ball.radius,
    );
    final brickRect = Rect.fromCenter(
      center: brick.position.toOffset(),
      width: brick.size.x,
      height: brick.size.y,
    );

    if (ballRect.overlaps(brickRect)) {
      _addImpactEffect(ball.position, brick.paint!.color);

      final intersection = ballRect.intersect(brickRect);
      final isHorizontalHit = intersection.width < intersection.height;

      if (isHorizontalHit) {
        ball.velocity = Vector2(-ball.velocity.x, ball.velocity.y);
      } else {
        ball.velocity = Vector2(ball.velocity.x, -ball.velocity.y);
      }

      return brick.hit();
    }
    return false;
  }
}