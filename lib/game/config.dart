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

  // Sizes
  static Vector2 brickSize(Vector2 screenSize) {
    final width = (screenSize.x * 0.9) / 8;  // 90% of screen width divided by 8 columns
    final height = screenSize.y * 0.05;      // 5% of screen height
    return Vector2(width, height);
  }
  // static const double ballRadius = 12.0;
  // static Vector2 brickSize = Vector2(80, 30);
  static double ballRadius(Vector2 screenSize) => screenSize.y * 0.02;
  static Vector2 _brickSize(Vector2 screenSize) => Vector2(screenSize.x / 8, screenSize.y * 0.05);
  static Vector2 batSize(Vector2 screenSize) => Vector2(screenSize.x * 0.3, screenSize.y * 0.03);
}