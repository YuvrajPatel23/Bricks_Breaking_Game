import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'bricks_breaking_game.dart';

void main() {
  final game = BricksBreakingGame();
  runApp(GameWidget(game: game));
}