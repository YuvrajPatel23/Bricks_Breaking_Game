import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}

extension DoubleExtensions on double {
  double clampMin(double min) => this < min ? min : this;
  double clampMax(double max) => this > max ? max : this;
}