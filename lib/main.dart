import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'BricksBreakingGame.dart';

void main() {
  final game = BricksBreakingGame();
  runApp(GameWidget(game: game));
}