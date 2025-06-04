import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config.dart';

class Bat extends RectangleComponent {
  Bat({required super.position, required Vector2 screenSize})
      : super(
    size: GameConfig.batSize(screenSize),
    anchor: Anchor.center,
    paint: Paint()..color = GameConfig.batColor,
  );
}
