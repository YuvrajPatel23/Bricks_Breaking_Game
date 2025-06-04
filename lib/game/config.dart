import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameConfig {
  // Physics
  static const double ballSpeed = 500.0;
  static const double batSpeed = 900.0;
  static const double batWidth = 120.0;
  static const double batHeight = 20.0;

  // Gameplay
  static const int lives = 3;
  static const int brickPoints = 10;

  // Sizes
  static const double ballRadius = 12.0;
  static Vector2 brickSize = Vector2(80, 30);

  // Colors
  static const Color ballColor = Colors.blue;
  static const Color batColor = Colors.green;
  static final List<Color> brickColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
  ];

  // Level configuration
  static const int totalLevels = 3;
  static const double levelCompletionFireworkCount = 50;
}