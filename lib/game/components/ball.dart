import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../config.dart';
import 'dart:math';

class Ball extends CircleComponent {
  Vector2 velocity;
  final List<CircleComponent> _trailPieces = [];
  final Random _random = Random();
  static const _maxTrailLength = 8;
  static const _trailInterval = 3;
  int _frameCount = 0;

  Ball({
    required super.position,
    required this.velocity,
    required Vector2 screenSize
  }) : super(
    radius: GameConfig.ballRadius(screenSize),
    anchor: Anchor.center,
    paint: Paint()..color = GameConfig.ballColor,
  );

  @override
  void update(double dt) {

    if(velocity.length == 0) return;

    super.update(dt);
    position += velocity * dt;
    _updateTrail(dt);
  }

  void _updateTrail(double dt) {
    _frameCount++;
    if (_frameCount % _trailInterval == 0) {
      // Create new trail piece
      final trailPiece = CircleComponent(
        radius: radius * (0.4 + _random.nextDouble() * 0.3),
        position: position.clone(),
        anchor: Anchor.center,
        paint: Paint()..color = GameConfig.ballColor.withOpacity(0.25),
      );

      // Add fade effect that automatically removes the piece
      trailPiece.add(OpacityEffect.to(
        0.0,
        LinearEffectController(0.4),
        onComplete: () {
          trailPiece.removeFromParent();
          _trailPieces.remove(trailPiece);
        },
      ));

      _trailPieces.add(trailPiece);
      parent?.add(trailPiece);
    }

    _trailPieces.removeWhere((piece) => !piece.isMounted);

    // Enforce maximum trail length
    while (_trailPieces.length > _maxTrailLength) {
      final oldest = _trailPieces.removeAt(0);
      if (oldest.isMounted) {
        oldest.removeFromParent();
      }
    }
  }

  void reset(Vector2 position, Vector2 velocity) {
    this.position = position;
    this.velocity = velocity;

    for (final piece in _trailPieces) {
      if (piece.isMounted) {
        piece.removeFromParent();
      }
    }
    _trailPieces.clear();
    _frameCount = 0;
  }

  @override
  void onRemove() {
    reset(position, velocity);
    super.onRemove();
  }
}