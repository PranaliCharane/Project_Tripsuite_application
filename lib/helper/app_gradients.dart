import 'package:flutter/material.dart';

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF379DD3), Color(0xFF7E72FF)],
  );

  // Gradient with 55deg angle as per Figma
  static const LinearGradient primaryGradient55deg = LinearGradient(
    begin: Alignment(-0.5736, -0.8192), // 55deg angle approximation
    end: Alignment(0.5736, 0.8192),
    colors: [Color(0xFF379DD3), Color(0xFF7E72FF)],
  );
}
