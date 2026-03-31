import 'package:flutter/material.dart';
import 'package:tripsuite_app_boilerplate/helper/app_gradients.dart';

class AppColors {
  static const primary = Color(0xFFAFD7EA);
  static const secondary = Color(0xFFFFFFFF);
  static const accent = Color(0xFF4CAF93);

  static const textPrimary = Color(0xFF1C1C1C);
  static const textSecondary = Color(0xFF7A7A7A);
  static const hint = Color(0xFFB0B0B0);

  static const error = Color(0xFFE57373);
  static const success = Color(0xFF4CAF50);

  static const blue = Color(0xFF2D6CFF);
  static const white = Color(0xFFFFFFFF);
  static const lightgrey = Color(0xFFd3d3d3);
  static const lightgreySecond = Color(0xFFf4f4f4);

  // Figma colors
  static const grey100 = Color(0xFFFFFFFF);
  static const grey300 = Color(0xFFE5E5E5);
  static const grey400 = Color(0xFFB0B0B0);
  static const grey500 = Color(0xFF999999);
  static const grey800 = Color(0xFF333333);
}

// Export gradient for easy access
extension AppThemeExtension on BuildContext {
  LinearGradient get primaryGradient => AppGradients.primaryGradient55deg;
}
