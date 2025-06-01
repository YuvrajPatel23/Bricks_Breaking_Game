import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Brick extends PositionComponent {
  final Color color;
  final double brickSize;

  Brick({
    required this.color,
    required Vector2 position,
    required this.brickSize,
  }) : super(position: position, size: Vector2.all(brickSize));

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = color;
    canvas.drawRect(size.toRect(), paint);

    final border = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(size.toRect(), border);
  }
}