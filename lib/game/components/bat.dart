import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config.dart';

class Bat extends RectangleComponent {
  Bat({required super.position})
      : super(
    size: Vector2(GameConfig.batWidth, GameConfig.batHeight),
    anchor: Anchor.center,
    paint: Paint()
      ..color = GameConfig.batColor,
  );
}
