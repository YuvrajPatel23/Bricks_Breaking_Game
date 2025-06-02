import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:developer' as dev;
import 'bricks_breaking_game.dart';

class Brick extends PositionComponent with DragCallbacks, HasGameReference<BricksBreakingGame> {
  final Color color;
  static const double brickSize = 35.0;

  Vector2? dragStartPosition;
  Vector2? originalPosition;

  Brick({
    required this.color,
    required Vector2 position,
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

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    dragStartPosition = event.localPosition.clone();
    originalPosition = position.clone();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (dragStartPosition != null) {
      position += event.localDelta;
    }
  }

  @override
  Future<void> onDragEnd(DragEndEvent event) async {
    super.onDragEnd(event);
    if (originalPosition != null) {
      final dropOffset = position - originalPosition!;

      if (dropOffset.length > Brick.brickSize / 2) {
        int dx = 0;
        int dy = 0;

        if (dropOffset.x.abs() > dropOffset.y.abs()) {
          dx = dropOffset.x.sign.toInt();
        } else if (dropOffset.y.abs() > 0) {
          dy = dropOffset.y.sign.toInt();
        }

        try {
          final oldRowCol = game.getBrickRowCol(this);
          final newRow = oldRowCol.row + dy;
          final newCol = oldRowCol.col + dx;

          if (game.isInBounds(newRow, newCol) && !game.isSwapping) {
            await game.trySwapBricks(oldRowCol.row, oldRowCol.col, newRow, newCol);
          } else {
            final effect = MoveEffect.to(
              originalPosition!,
              EffectController(duration: 0.3),
            );
            add(effect);
            dev.log('Invalid swap or game is swapping, reset to $originalPosition');
          }
        } catch (e) {
          final effect = MoveEffect.to(
            originalPosition!,
            EffectController(duration: 0.3),
          );
          add(effect);
          dev.log('Error in drag end: $e, reset to $originalPosition');
        }
      } else {
        final effect = MoveEffect.to(
          originalPosition!,
          EffectController(duration: 0.3),
        );
        add(effect);
        dev.log('Drag distance too small, reset to $originalPosition');
      }
      dragStartPosition = null;
      originalPosition = null;
    }
  }



}