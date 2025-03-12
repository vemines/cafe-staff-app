import 'package:flutter/material.dart';

extension ColorExt on Color {
  // usage: Colors.black.opacityColor(0.2)
  Color opacityColor(double opacityValue) {
    final alpha = (opacityValue.clamp(0.0, 1.0) * 255).round();
    return withAlpha(alpha);
  }
}
