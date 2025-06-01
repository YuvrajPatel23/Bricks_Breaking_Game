import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'brick.dart';

class BricksBreakingGame extends FlameGame {
  final Random _random = Random();

  static const int rows = 14;
  static const int cols = 10;
  static const double brickSize = 35.0;

  final List<Color> brickColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];

  late final PositionComponent board;

  @override
  Color backgroundColor() => const Color(0xFFEEEEEE);

  @override
  Future<void> onLoad() async {

    final double boardWidth = cols * brickSize;
    final double boardHeight = rows * brickSize;

    final double centerX = (size.x - boardWidth) / 2;
    final double centerY = (size.y - boardHeight) / 2;
    board = PositionComponent(position: Vector2(centerX, centerY));
    add(board);

    generateGrid();
  }

  void generateGrid() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final color = brickColors[_random.nextInt(brickColors.length)];
        final position = Vector2(col * brickSize, row * brickSize);

        final brick = Brick(
          color: color,
          position: position,
          brickSize: brickSize,
        );

        board.add(brick);
      }
    }
  }
}