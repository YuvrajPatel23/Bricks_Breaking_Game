import 'dart:async';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'brick.dart';
import 'dart:developer' as dev;

class BricksBreakingGame extends FlameGame with DragCallbacks {
  final Random _random = Random();
  bool isSwapping = false;


  static const int rows = 14;
  static const int cols = 10;

  final List<Color> brickColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];

  late final PositionComponent board;
  late List<List<Brick?>> grid;

  @override
  Color backgroundColor() => const Color(0xFFEEEEEE);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final double boardWidth = cols * Brick.brickSize;
    final double boardHeight = rows * Brick.brickSize;

    final double centerX = (size.x - boardWidth) / 2;
    final double centerY = (size.y - boardHeight) / 2;
    board = PositionComponent(position: Vector2(centerX, centerY));
    add(board);

    generateGrid();
    Future.delayed(Duration(milliseconds: 1000), () async {
      await removeMatchedBricks();
    });
  }

  void generateGrid() {
    grid = List.generate(rows, (_) => List<Brick?>.filled(cols, null));

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final color = brickColors[_random.nextInt(brickColors.length)];
        final position = Vector2(col * Brick.brickSize, row * Brick.brickSize);

        final brick = Brick(
          color: color,
          position: position,
        );

        board.add(brick);
        grid[row][col] = brick;
      }
    }
  }

  Set<Point<int>> getMatchedPositions() {
    final matched = <Point<int>>{};

    for (int row = 0; row < rows; row++) {
      int col = 0;
      while (col < cols) {
        final current = grid[row][col];
        if (current == null || current.color == Colors.transparent) {
          col++;
          continue;
        }

        int end = col + 1;
        while (
        end < cols &&
            grid[row][end] != null &&
            grid[row][end]!.color == current.color
        ) {
          end++;
        }

        if (end - col >= 3) {
          for (int c = col; c < end; c++) {
            matched.add(Point(row, c));
          }
        }

        col = end;
      }
    }

    for (int col = 0; col < cols; col++) {
      int row = 0;
      while (row < rows) {
        final current = grid[row][col];
        if (current == null || current.color == Colors.transparent) {
          row++;
          continue;
        }

        int end = row + 1;
        while (
        end < rows &&
            grid[end][col] != null &&
            grid[end][col]!.color == current.color
        ) {
          end++;
        }

        if (end - row >= 3) {
          for (int r = row; r < end; r++) {
            matched.add(Point(r, col));
          }
        }

        row = end;
      }
    }

    return matched;
  }

  Future<void> removeMatchedBricks() async {
    final matched = getMatchedPositions();
    if (matched.isEmpty) return;

    for (final point in matched) {
      final brick = grid[point.x][point.y];
      brick?.removeFromParent();
      grid[point.x][point.y] = null;
    }

    await applyGravity();
    await Future.delayed(const Duration(milliseconds: 300));
    await fillTopGaps();

    await Future.delayed(Duration(milliseconds: 300));

    await removeMatchedBricks();
  }

  Future<void> applyGravity() async {
    final List<Future> animations = [];

    for (int col = 0; col < cols; col++) {
      int emptyRow = rows - 1;
      for (int row = rows - 1; row >= 0; row--) {
        if (grid[row][col] != null) {
          if (row != emptyRow) {
            final brick = grid[row][col]!;
            final newPosition = Vector2(col * Brick.brickSize, emptyRow * Brick.brickSize);

            final effect = MoveEffect.to(
              newPosition,
              EffectController(duration: 0.2),
            );

            final completer = Completer<void>();
            effect.onComplete = completer.complete;

            brick.add(effect);
            animations.add(completer.future);

            grid[emptyRow][col] = brick;
            grid[row][col] = null;
          }
          emptyRow--;
        }
      }
    }

    await Future.wait(animations);
    dev.log('Gravity animation completed');
  }

  Future<void> fillTopGaps() async {
    final List<Future> animations = [];

    for (int col = 0; col < cols; col++) {
      int emptyRows = 0;

      for (int row = rows - 1; row >= 0; row--) {
        if (grid[row][col] == null) {
          emptyRows++;
        }
      }

      for (int i = 0; i < emptyRows; i++) {
        final color = brickColors[_random.nextInt(brickColors.length)];
        final position = Vector2(col * Brick.brickSize, - (i + 1) * Brick.brickSize);

        final brick = Brick(
          color: color,
          position: position.clone(),
        );

        board.add(brick);

        final targetRow = emptyRows - 1 - i;
        final targetPosition = Vector2(col * Brick.brickSize, targetRow * Brick.brickSize);

        final effect = MoveEffect.to(
          targetPosition,
          EffectController(duration: 0.3),
        );

        final completer = Completer<void>();
        effect.onComplete = completer.complete;

        brick.add(effect);
        animations.add(completer.future);

        grid[targetRow][col] = brick;
      }
    }

    await Future.wait(animations);
    dev.log('Fill top gaps animation completed');
  }

  ({int row, int col}) getBrickRowCol(Brick brick) {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (grid[row][col] == brick) {
          return (row: row, col: col);
        }
      }
    }
    throw Exception('Brick not found in grid!');
  }

  bool isInBounds(int row, int col) {
    return row >= 0 && row < rows && col >= 0 && col < cols;
  }


  void validateGrid() {
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final brick = grid[row][col];
        if (brick != null) {
          final expectedPos = Vector2(col * Brick.brickSize, row * Brick.brickSize);
          if (brick.position != expectedPos) {
            dev.log('Position mismatch at ($row, $col): expected $expectedPos, got ${brick.position}');
            brick.position = expectedPos;
          }
        }
      }
    }
  }

  Future<void> trySwapBricks(int row1, int col1, int row2, int col2) async {
    if (isSwapping) {
      dev.log('Swap blocked: already swapping');
      return;
    }
    isSwapping = true;
    try {
      if (!isInBounds(row1, col1) || !isInBounds(row2, col2)) return;

      final brick1 = grid[row1][col1];
      final brick2 = grid[row2][col2];

      if (brick1 == null || brick2 == null) return;

      final pos1 = brick1.position.clone();
      final pos2 = brick2.position.clone();

      brick1.removeWhere((component) => component is MoveEffect);
      brick2.removeWhere((component) => component is MoveEffect);

      final completer1 = Completer<void>();
      final completer2 = Completer<void>();

      brick1.add(MoveEffect.to(pos2, EffectController(duration: 0.2))..onComplete = completer1.complete);
      brick2.add(MoveEffect.to(pos1, EffectController(duration: 0.2))..onComplete = completer2.complete);

      await Future.wait([completer1.future, completer2.future]);

      grid[row1][col1] = brick2;
      grid[row2][col2] = brick1;
      validateGrid();

      final matchedPoints = getMatchedPositions();
      if (matchedPoints.isNotEmpty) {

        final List<Future> animations = [];
        for (final point in matchedPoints) {
          final matchedBrick = grid[point.x][point.y];
          if (matchedBrick != null) {
            final completer = Completer<void>();
            matchedBrick.add(ScaleEffect.to(
              Vector2.zero(),
              EffectController(duration: 0.3),
              onComplete: () {
                matchedBrick.removeFromParent();
                grid[point.x][point.y] = null;
                completer.complete();
              },
            ));
            animations.add(completer.future);
          }
        }
        await Future.wait(animations);

        await applyGravity();
        await Future.delayed(const Duration(milliseconds: 300));
        await fillTopGaps();
        await Future.delayed(const Duration(milliseconds: 300));
        await removeMatchedBricks();
        validateGrid();
      } else {
        final completer3 = Completer<void>();
        final completer4 = Completer<void>();

        brick1.removeWhere((component) => component is MoveEffect);
        brick2.removeWhere((component) => component is MoveEffect);
        brick1.add(MoveEffect.to(pos1, EffectController(duration: 0.3))..onComplete = completer3.complete);
        brick2.add(MoveEffect.to(pos2, EffectController(duration: 0.3))..onComplete = completer4.complete);

        dev.log('Starting revert animation for brick1 to $pos1 and brick2 to $pos2');
        await Future.wait([completer3.future, completer4.future]);
        dev.log('Revert animation completed');

        grid[row1][col1] = brick1;
        grid[row2][col2] = brick2;
        brick1.position = pos1;
        brick2.position = pos2;

        dev.log('Reverted swap: brick1 to $pos1, brick2 to $pos2');
        validateGrid();
      }
    } finally {
      isSwapping = false;
    }
  }


}