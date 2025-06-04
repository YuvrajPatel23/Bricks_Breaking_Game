import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';

class PlayArea extends RectangleComponent with HasGameReference<BrickBreakerGame> {
  PlayArea() : super(
    paint: Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 2.0,
    children: [RectangleHitbox()],
  );

  @override
  void onLoad() {
    size = game.size;
    position = Vector2.zero();
    super.onLoad();
  }
}